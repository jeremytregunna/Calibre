//
//  StoriesTests.swift
//  Calibre
//
//  Created by Jeremy Tregunna on 11/12/16.
//  Copyright © 2016 Greenshire, Inc. All rights reserved.
//

import XCTest
@testable import Calibre

struct StoriesTestState: StateType {
    var name: String? = nil
    var fetching: Bool = false
    var error: String? = nil
}

struct StoriesReducer: Reducer {
    typealias ReducerStateType = StoriesTestState

    func handleAction(action: Action, state: StoriesTestState?) -> StoriesTestState {
        var state = state ?? StoriesTestState()

        switch action {
        case _ as UserFetchRequested:
            state.fetching = true
        case let success as UserFetchSucceeded:
            state.name     = success.name
            state.fetching = false
        case let fail as UserFetchFailed:
            state.error    = fail.error
            state.fetching = false
        default: break
        }

        return state
    }
}

struct UserFetchRequested: Action {
    let identifier: String
}

struct UserFetchSucceeded: Action {
    let name: String
}

struct UserFetchFailed: Action {
    let error: String
}

class FetchUser: Story {
    let shouldFail: Bool
    weak var store: Store<StoriesTestState>?

    init(shouldFail: Bool, store: Store<StoriesTestState>) {
        self.shouldFail = shouldFail
        self.store      = store
    }
    
    override func execute() {
        while true {
            yield(effect: Wait<UserFetchRequested>())
            let call = yield(effect: Call<String, String> { done in
                if self.shouldFail {
                    done(.error(":("))
                } else {
                    done(.success("success"))
                }
            })

            if case .success(let res) = call.result! {
                yield(effect: Send(action: UserFetchSucceeded(name: res), via: store?.dispatch))
            } else {
                yield(effect: Send(action: UserFetchFailed(error: ":("), via: store?.dispatch))
            }
        }
    }
}

class StoriesTests: XCTestCase {
    var store: Store<StoriesTestState>!
    var currentExpectation: XCTestExpectation?
    var currentState: StoriesTestState!

    func newState(state: StoriesTestState) {
        currentState = state
        currentExpectation?.fulfill()
    }
    
    override func setUp() {
        super.setUp()
        store = Store<StoriesTestState>(reducer: StoriesReducer(), state: nil)
        currentState = store.state
    }
    
    override func tearDown() {
        super.tearDown()

        currentExpectation = nil
        currentState       = nil
    }

    func testFetchUserStory() {
        let expected = StoriesTestState(name: nil, fetching: true, error: nil)
        let fetch = FetchUser(shouldFail: false, store: store)

        currentExpectation = expectation(description: "fetch user")

        store.stories.run(story: fetch)
        let request = UserFetchRequested(identifier: "fetch user single")
        store.dispatch(request)

        waitForExpectations(timeout: 2.0) { error in
            XCTAssert(self.currentState.name != expected.name)
            XCTAssert(self.currentState.fetching == expected.fetching)
            XCTAssert(self.currentState.error == expected.error)
        }
    }
}
