//
//  Store.swift
//  Calibre
//
//  Created by Jeremy Tregunna on 8/31/16.
//  Copyright © 2016 Greenshire, Inc. All rights reserved.
//

import Foundation

public final class Store<State: StateType> {
    typealias SubscriptionType = Subscription<State>

    open fileprivate(set) var state: State! {
        didSet {
            subscriptions = subscriptions.filter({ $0.subscriber != nil })
            for sub in subscriptions {
                sub.subscriber?._newState(state: sub.update?(state) ?? state)
            }
        }
    }

    fileprivate(set) var appReducer: AnyReducer
    fileprivate(set) var subscriptions: Array<SubscriptionType> = []

    public init(reducer: AnyReducer, state: State?) {
        appReducer = reducer
        if let state = state {
            self.state = state
        } else {
            dispatch(InitialAction())
        }
    }

    public func dispatch(creator: ActionCreator) {
        let action = creator.execute()
        dispatch(action)
    }

    public func dispatch(_ action: Action) {
        state = appReducer._handleAction(action: action, state: state) as! State
        if let state = state {
            DispatchQueue.main.async {
                for subscription in self.subscriptions {
                    subscription.subscriber?._newState(state: state)
                }
            }
        }
    }

    public func subscribe<S: Subscriber>(_ subscriber: S) where S.SubscriberStateType == State {
        subscribe(subscriber, update: nil)
    }

    public func subscribe<SelectedState, S: Subscriber>(_ subscriber: S, update: ((State) -> SelectedState)?) where S.SubscriberStateType == SelectedState {
        guard isSubscribed(subscriber) == false else { return }

        subscriptions.append(Subscription(subscriber: subscriber, update: update))

        if let state = state {
            subscriber._newState(state: update?(state) ?? state)
        }
    }

    public func unsubscribe(_ subscriber: AnySubscriber) {
        if let index = subscriptions.index(where: { return $0.subscriber === subscriber }) {
            subscriptions.remove(at: index)
        }
    }

    fileprivate func isSubscribed<S: Subscriber>(_ subscriber: S) -> Bool {
        return subscriptions.contains(where: { $0.subscriber === subscriber })
    }
}
