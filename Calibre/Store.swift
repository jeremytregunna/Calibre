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

    #if swift(>=3)
        open fileprivate(set) var state: State! {
            didSet {
                subscriptions = subscriptions.filter({ $0.subscriber != nil })
                for sub in subscriptions {
                    sub.subscriber?._newState(state: sub.update?(state) ?? state)
                }
            }
        }
    #else
        public private(set) var state: State! {
            didSet {
                subscriptions = subscriptions.filter({ $0.subscriber != nil })
                for sub in subscriptions {
                    sub.subscriber?._newState(sub.update?(state) ?? state)
                }
            }
        }
    #endif

    #if swift(>=3)
        fileprivate(set) var appReducer: AnyReducer
        fileprivate(set) var subscriptions: Array<SubscriptionType> = []
    #else
        private(set) var appReducer: AnyReducer
        private(set) var subscriptions: Array<SubscriptionType> = []
    #endif

    public init(reducer: AnyReducer, state: State?) {
        appReducer = reducer
        if let state = state {
            self.state = state
        } else {
            dispatch(InitialAction())
        }
    }

    // MARK: - Swift 3.0

    public func dispatch(_ action: Action) {
        state = appReducer._handleAction(action, state: state) as! State
        if let state = state {
            for subscription in subscriptions {
                #if swift(>=3)
                    subscription.subscriber?._newState(state: state)
                #else
                    subscription.subscriber?._newState(state)
                #endif
            }
        }
    }

    #if swift(>=3)
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
    #else
    
    // MARK: - Swift 2

    public func subscribe<S: Subscriber where S.SubscriberStateType == State>(subscriber: S) {
        subscribe(subscriber, update: nil))
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

    #endif
}
