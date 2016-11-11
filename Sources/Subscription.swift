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
            newState(state: customState)
        }
    }
}

struct Subscription<State: StateType> {
    fileprivate(set) weak var subscriber: AnySubscriber?
    let update: ((State) -> Any)?
}
