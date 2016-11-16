//
//  Action.swift
//  Calibre
//
//  Created by Jeremy Tregunna on 8/31/16.
//  Copyright © 2016 Greenshire, Inc. All rights reserved.
//

import Foundation

public protocol Action {}

public protocol ActionCreator {
    func execute() -> Action
}

public struct InitialAction: Action {}
