//
//  Command.swift
//  Calibre
//
//  Created by Jeremy Tregunna on 9/5/16.
//  Copyright © 2016 Greenshire, Inc. All rights reserved.
//

import Foundation

@objc public protocol Commandable: class {
    weak var target: UIResponder? { get set }
    var action: Selector { get }
}

#if swift(>=3)
open class BasicCommand: Commandable {
    @objc open weak var target: UIResponder?
    @objc open fileprivate(set) var action: Selector

    public required init(target: UIResponder?, action: Selector) {
        self.target = target
        self.action = action
    }
}
#else
    public class BasicCommand: Commandable {
        @objc public weak var target: UIResponder?
        @objc public private(set) var action: Selector
    
        public required init(target: UIResponder?, action: Selector) {
            self.target = target
            self.action = action
        }
    }
#endif
