//
//  Reducer.swift
//  Calibre
//
//  Created by Jeremy Tregunna on 8/31/16.
//  Copyright © 2016 Greenshire, Inc. All rights reserved.
//

import Foundation

#if swift(>=3)
    typealias ReducerFunc = (_ action: Action, _ state: StateType?) -> StateType
#else
    typealias ReducerFunc = (action: Action, state: StateType?) -> StateType
#endif

public protocol AnyReducer {
    #if swift(>=3)
        func _handleAction(_ action: Action, state: StateType?) -> StateType
    #else
        func _handleAction(action: Action, state: StateType?) -> StateType
    #endif
}

public protocol Reducer: AnyReducer {
    associatedtype ReducerStateType

    #if swift(>=3)
        func handleAction(_ action: Action, state: ReducerStateType?) -> ReducerStateType
    #else
        func handleAction(action: Action, state: ReducerStateType?) -> ReducerStateType
    #endif
}

extension Reducer {
    #if swift(>=3)
        public func _handleAction(_ action: Action, state: StateType?) -> StateType {
            return withTypes(action, state: state, function: handleAction)
        }
    #else
        public func _handleAction(action: Action, state: StateType?) -> StateType {
            return withTypes(action, state: state, function: handleAction)
        }
    #endif
}
