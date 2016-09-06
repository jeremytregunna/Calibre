//
//  Store.swift
//  Calibre
//
//  Created by Jeremy Tregunna on 8/31/16.
//  Copyright © 2016 Greenshire, Inc. All rights reserved.
//

import Foundation

public class Store<State: StateType> {
    typealias SubscriptionType = Subscription<State>

    public private(set) var state: State! {
        didSet {
            subscriptions = subscriptions.filter({ $0.subscriber != nil })
            for sub in subscriptions {
                sub.subscriber?._newState(sub.update?(state) ?? state)
            }
        }
    }

    private(set) var appReducer: AnyReducer
    private(set) var subscriptions: Array<SubscriptionType> = []

    public init(reducer: AnyReducer, state: State?) {
        appReducer = reducer
        if let state = state {
            self.state = state
        } else {
            dispatch(InitialAction())
        }
    }

    public func dispatch(action: Action) {
        state = appReducer._handleAction(action, state: state) as! State
        if let state = state {
            for subscription in subscriptions {
                subscription.subscriber?._newState(state)
            }
        }
    }

    public func subscribe<S: Subscriber where S.SubscriberStateType == State>(subscriber: S) {
        subscribe(subscriber, update: nil)
    }

    public func subscribe<SelectedState, S: Subscriber where S.SubscriberStateType == SelectedState>(subscriber: S, update: (State -> SelectedState)?) {
        guard isSubscribed(subscriber) == false else { return }

        subscriptions.append(Subscription(subscriber: subscriber, update: update))

        if let state = state {
            subscriber._newState(update?(state) ?? state)
        }
    }

    public func unsubscribe(subscriber: AnySubscriber) {
        if let index = subscriptions.indexOf({ return $0.subscriber === subscriber }) {
            subscriptions.removeAtIndex(index)
        }
    }

    private func isSubscribed<S: Subscriber>(subscriber: S) -> Bool {
        return subscriptions.contains({ $0.subscriber === subscriber })
    }
}
