//
//  Story.swift
//  Calibre
//
//  Created by Jeremy Tregunna on 11/11/16.
//  Copyright © 2016 Greenshire, Inc. All rights reserved.
//

import Foundation

public class Story {
    internal var bus: Bus<Effect>!
    private var mutex = pthread_mutex_t()

    public init() {
        bus = nil
        pthread_mutex_init(&mutex, nil)
    }
    
    deinit {
        pthread_mutex_destroy(&mutex)
    }

    @discardableResult
    public func yield<T>(effect: T) -> T where T: Yieldable, T: Effect {
        var effect = effect
        effect.yield = unlock

        lock {
            self.bus.send(value: effect)
            self.lock()
        }

        return effect
    }

    public func execute() {
        // NB: Intentially left empty.
    }

    private func lock() {
        pthread_mutex_lock(&mutex)
    }

    private func lock(fn: (() -> ())) {
        lock()
        fn()
        unlock()
    }

    private func unlock() {
        pthread_mutex_unlock(&mutex)
    }
}
