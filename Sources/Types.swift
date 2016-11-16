//
//  Types.swift
//  Calibre
//
//  Created by Jeremy Tregunna on 8/31/16.
//  Copyright © 2016 Greenshire, Inc. All rights reserved.
//

import Foundation

public enum CalibreResult<A, B> {
    case success(A)
    case error(B)
}

private let pt_entry: @convention(c) (UnsafeMutableRawPointer) -> UnsafeMutableRawPointer? = { (ctx) in
    let np = ctx.assumingMemoryBound(to: (() -> ()).self)
    np.pointee()
    np.deinitialize()
    np.deallocate(capacity: 1)
    return nil
}

/// A `call` statement starts the execution of an action as an independent concurrent thread of control within the same address space.
public func call(thing: @escaping () -> ()){
    let p = UnsafeMutablePointer<() -> ()>.allocate(capacity: 1)
    p.initialize(to: thing)
    var t: pthread_t? = nil
    pthread_create(&t, nil, pt_entry, p)
    if let t = t {
        pthread_detach(t)
    }
}

func withTypes<SpecificState, Action>(_ action: Action, state genericState: StateType?, function: (_ action: Action, _ state: SpecificState?) -> SpecificState) -> StateType {
    guard let genericState = genericState else {
        return function(action, nil) as! StateType
    }

    guard let specificState = genericState as? SpecificState else {
        return genericState
    }

    return function(action, specificState) as! StateType
}
