//
//  Subscription.swift
//  Calibre
//
//  Created by Jeremy Tregunna on 8/31/16.
//  Copyright © 2016 Greenshire, Inc. All rights reserved.
//

import Foundation

public protocol AnySubscriber: class {
    func _newState(state: Any)
}

public protocol Subscriber: AnySubscriber {
    associatedtype SubscriberStateType

    func newState(state: SubscriberStateType)
}

extension Subscriber {
    public func _newState(state: Any) {
        if let customState = state as? SubscriberStateType {
            #if swift(>=3)
                newState(state: customState)
            #else
                newState(customState)
            #endif
        }
    }
}

struct Subscription<State: StateType> {
    #if swift(>=3)
        fileprivate(set) weak var subscriber: AnySubscriber?
    #else
        private(set) weak var subscriber: AnySubscriber?
    #endif
    let update: ((State) -> Any)?
}
