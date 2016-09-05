//
//  Command.swift
//  Calibre
//
//  Created by Jeremy Tregunna on 9/5/16.
//  Copyright © 2016 Greenshire, Inc. All rights reserved.
//

import Foundation

public protocol Command: class {
    weak var responder: UIResponder? { get set }
    var action: Selector { get }
}
