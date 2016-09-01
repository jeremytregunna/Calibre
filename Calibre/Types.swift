//
//  Types.swift
//  Calibre
//
//  Created by Jeremy Tregunna on 8/31/16.
//  Copyright © 2016 Greenshire, Inc. All rights reserved.
//

import Foundation

func withSpecificTypes<SpecificStateType, Action>(action: Action, state genericStateType: StateType?, @noescape function: (action: Action, state: SpecificStateType?) -> SpecificStateType) -> StateType {
    guard let genericStateType = genericStateType else {
        return function(action: action, state: nil) as! StateType
    }

    guard let specificStateType = genericStateType as? SpecificStateType else {
        return genericStateType
    }

    return function(action: action, state: specificStateType) as! StateType
}
