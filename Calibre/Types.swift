//
//  Types.swift
//  Calibre
//
//  Created by Jeremy Tregunna on 8/31/16.
//  Copyright © 2016 Greenshire, Inc. All rights reserved.
//

import Foundation

func withTypes<SpecificState, Action>(_ action: Action, state genericState: StateType?, function: (_ action: Action, _ state: SpecificState?) -> SpecificState) -> StateType {
    guard let genericState = genericState else {
        return function(action, nil) as! StateType
    }

    guard let specificState = genericState as? SpecificState else {
        return genericState
    }

    return function(action, specificState) as! StateType
}
