//
//  EffectsManager.swift
//  Calibre
//
//  Created by Jeremy Tregunna on 11/11/16.
//  Copyright © 2016 Greenshire, Inc. All rights reserved.
//

import Foundation

class EffectsManager<S: StateType>: Effect {
    let store: Store<S>
    let bus: Bus<Effect>
    var waiters: [Waitable]

    init(store: Store<S>, bus: Bus<Effect>) {
        self.store   = store
        self.bus     = bus
        self.waiters = []
    }

    func handleAction(action: Action) {
        waiters = waiters.filter { (effect) in
            effect.handleAction(action: action)
            return effect.waiting
        }
    }

    func execute() {
        while let effect = try? bus.receive() {
            switch effect {
            case let w as Waitable:
                if w.waiting {
                    waiters.append(w)
                }
            case var d as Dispatchable:
                d.dispatch = store.dispatch
            case var st as StateConvertable:
                st.state = { self.store.state }
            default: break
            }

            effect.execute()
        }
    }
}
