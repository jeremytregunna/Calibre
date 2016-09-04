//
//  Reducer.swift
//  Calibre
//
//  Created by Jeremy Tregunna on 8/31/16.
//  Copyright © 2016 Greenshire, Inc. All rights reserved.
//

import Foundation

typealias ReducerFunc = (action: Action, state: StateType?) -> StateType

public protocol AnyReducer {
    func _handleAction(action: Action, state: StateType?) -> StateType
}

public protocol Reducer: AnyReducer {
    associatedtype ReducerStateType

    func handleAction(action: Action, state: ReducerStateType?) -> ReducerStateType
}

extension Reducer {
    public func _handleAction(action: Action, state: StateType?) -> StateType {
        return withTypes(action, state: state, function: handleAction)
    }
}
