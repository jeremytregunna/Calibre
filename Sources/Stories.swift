//
//  Stories.swift
//  Calibre
//
//  Created by Jeremy Tregunna on 11/12/16.
//  Copyright © 2016 Greenshire, Inc. All rights reserved.
//

import Foundation

public class Stories<S: StateType>: Reducer {
    private let bus: Bus<Effect>
    private var manager: EffectsManager<S>!
    private weak var store: Store<S>?

    public init(store: Store<S>) {
        bus     = Bus<Effect>()
        manager = nil
        self.store = store
    }

    @discardableResult
    public func handleAction(action: Action, state: S?) -> S {
        if let store = store {
            manager = EffectsManager<S>(store: store, bus: bus)
            self.manager.handleAction(action: action)
        }
        // NB: This is safe, see Store.swift dispatch() method, this is always run after the reducers.
        return state!
    }
//    public func middleware(store: Store<S>, yield: @escaping ((Action) -> Action)) -> ((Action) -> Action) {
//        manager    = EffectsManager<S>(store: store, bus: bus)
//        return { action in
//            let action = yield(action)
//            self.manager.handleAction(action: action)
//            return action
//        }
//    }

    public func run(story: Story) {
        story.bus = bus
        call(thing: story.execute)
    }

    public func execute() {
        call(thing: manager.execute)
    }
}
