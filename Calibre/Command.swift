//
//  Command.swift
//  Calibre
//
//  Created by Jeremy Tregunna on 11/6/16.
//  Copyright © 2016 Greenshire, Inc. All rights reserved.
//

import Foundation

public protocol Command {
    associatedtype State: StateType

    func execute(state: State, store: Store<State>)
}
