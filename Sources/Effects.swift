//
//  Effects.swift
//  Calibre
//
//  Created by Jeremy Tregunna on 11/11/16.
//  Copyright © 2016 Greenshire, Inc. All rights reserved.
//

import Foundation

public protocol Effect {
    func execute()
}

public protocol Waitable: Effect {
    var waiting: Bool { get }
    func handleAction(action: Action)
}

public protocol Dispatchable: Effect {
    var dispatch: ((Action) -> Void)! { get set }
}

public protocol Yieldable {
    var yield: (() -> Void)! { get set }
}

public protocol StateConvertable {
    var state: (() -> StateType)! { get set }
}

public class Wait<A: Action>: Effect, Waitable, Yieldable {
    public var yield: (() -> Void)!
    public var action: Action!

    public var waiting: Bool {
        return action == nil
    }

    public func handleAction(action: Action) {
        if let action = action as? A {
            self.action = action
            yield()
        }
    }

    public func execute() {
        // NB: Intentionally left empty, this is a waiting action.
    }
}

public class Send: Effect, Dispatchable, Yieldable {
    public var dispatch: ((Action) -> Void)!
    public var yield: (() -> Void)!

    let action: Action

    public init(action: Action, via fn: ((Action) -> Void)? = nil) {
        self.action   = action
        self.dispatch = fn
    }

    public func execute() {
        dispatch(action)
        yield()
    }
}

public class Map<S, T>: Effect, StateConvertable, Yieldable {
    public var yield: (() -> Void)!
    public var state: (() -> StateType)!
    public var result: T!

    let mapper: ((S) -> T)

    public init(mapper: @escaping ((S) -> T)) {
        self.mapper = mapper
    }

    public func execute() {
        if let state = state() as? S {
            result = mapper(state)
        }
    }
}

public class Call<S, T>: Effect, Yieldable {
    public var yield: (() -> Void)!
    public var result: CalibreResult<S, T>?

    let future: (((CalibreResult<S, T>) -> ()) -> ())

    public init(future: @escaping (((CalibreResult<S, T>) -> ()) -> ())) {
        self.future = future
    }

    public func execute() {
        future { result in
            self.result = result
            self.yield()
        }
    }
}
