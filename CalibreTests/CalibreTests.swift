//
//  CalibreTests.swift
//  CalibreTests
//
//  Created by Jeremy Tregunna on 8/31/16.
//  Copyright © 2016 Greenshire, Inc. All rights reserved.
//

import XCTest
@testable import Calibre

struct TestState: StateType {
    var name: String
    var age: Int
}

struct ChangeNameAction: Action {
    var type: String = "ChangeName"

    let newName: String

    init(newName: String) {
        self.newName = newName
    }
}

struct BirthdayAction: Action {
    var type: String = "birthday"
}

struct CapitalizeAction: Action {}

struct CapitalizeCommand: Command {
    typealias State = TestState

    func execute(state: TestState, store: Store<TestState>) {
        let capitalize = CapitalizeAction()
        store.dispatch(capitalize)
    }
}

struct TestReducer: Reducer {
    #if swift(>=3)
    func handleAction(_ action: Action, state: TestState?) -> TestState {
        return TestState(
            name: NameReducer().handleAction(action, state: state?.name),
            age: AgeReducer().handleAction(action, state: state?.age)
        )
    }
    #else
    func handleAction(action: Action, state: TestState?) -> TestState {
        return TestState(
            name: NameReducer().handleAction(action, state: state?.name),
            age: AgeReducer().handleAction(action, state: state?.age)
        )
    }
    #endif
}

struct AgeReducer: Reducer {
    #if swift(>=3)
    func handleAction(_ action: Action, state: Int?) -> Int {
        guard let state = state else { return 0 }

        switch action {
        case _ as BirthdayAction:
            return state + 1
        default: break
        }

        return state
    }
    #else
    func handleAction(action: Action, state: Int?) -> Int {
        guard let state = state else { return 0 }
        
        switch action {
        case _ as BirthdayAction:
            return state + 1
        default: break
        }
        
        return state
    }
    #endif
}

struct NameReducer: Reducer {
    #if swift(>=3)
    func handleAction(_ action: Action, state: String?) -> String {
        guard let state = state else { return "unknown" }

        switch action {
        case let cna as ChangeNameAction:
            return cna.newName
        case _ as CapitalizeAction:
            NSLog("capitalized: \(state.uppercased())")
            return state.uppercased()
        default: break
        }

        return state
    }
    #else
    func handleAction(action: Action, state: String?) -> String {
        guard let state = state else { return "unknown" }
        
        switch action {
        case let cna as ChangeNameAction:
            return cna.newName
        case _ as CapitalizeAction:
            return state.uppercaseString
        default: break
        }
        
        return state
    }
    #endif
}

class CalibreTests: XCTestCase, Subscriber {
    typealias SubscriberStateType = TestState

    var store: Store<TestState>!
    
    func newState(state: TestState) {
    }

    override func setUp() {
        super.setUp()
        store = Store<TestState>(reducer: TestReducer(), state: nil)
    }
    
    func testInitialStateOK() {
        XCTAssert(store.state.age == 0)
        XCTAssert(store.state.name == "unknown")
    }

    func testSubscriptions() {
        XCTAssert(store.subscriptions.count == 0)
        store.subscribe(self)
        XCTAssert(store.subscriptions.count == 1)
        store.unsubscribe(self)
        XCTAssert(store.subscriptions.count == 0)
    }
    
    func testUpdatedStateOK() {
        store.dispatch(BirthdayAction())
        XCTAssert(store.state.age == 1)
        store.dispatch(ChangeNameAction(newName: "Bob McTestinstine"))
        XCTAssert(store.state.name == "Bob McTestinstine")
    }

    func testCommand() {
        let c = CapitalizeCommand()
        store.dispatch(ChangeNameAction(newName: "Bob McTestinstine"))
        store.fire(c)
        XCTAssert(store.state.name == "BOB MCTESTINSTINE")
    }
}
