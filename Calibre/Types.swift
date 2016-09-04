//
//  Types.swift
//  Calibre
//
//  Created by Jeremy Tregunna on 8/31/16.
//  Copyright © 2016 Greenshire, Inc. All rights reserved.
//

import Foundation

func withTypes<SpecificState, Action>(action: Action, state genericState: StateType?, @noescape function: (action: Action, state: SpecificState?) -> SpecificState) -> StateType {
    guard let genericState = genericState else {
        return function(action: action, state: nil) as! StateType
    }

    guard let specificState = genericState as? SpecificState else {
        return genericState
    }

    return function(action: action, state: specificState) as! StateType
}
