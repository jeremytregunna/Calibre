//
//  UIResponder+Navigation.swift
//  Calibre
//
//  Created by Jeremy Tregunna on 9/5/16.
//  Copyright © 2016 Greenshire, Inc. All rights reserved.
//

import UIKit

private var nextCommandResponderKey = "nextCommandResponderKey"

// XXX: Make this more Swift-y.
public extension UIResponder {
    public var nextCommandResponder: UIResponder? {
        get {
            if let responder = objc_getAssociatedObject(self, &nextCommandResponderKey) as? UIResponder {
                return responder
            }
            return nextResponder()
        }
        set {
            objc_setAssociatedObject(self, &nextCommandResponderKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    public func canPerformCommand(command: Command) -> Bool {
        return respondsToSelector(command.action)
    }

    public func targetForCommand(command: Command) -> UIResponder? {
        var implementor: UIResponder? = self
        while implementor != nil {
            if let implementor = implementor where implementor.canPerformCommand(command) {
                return implementor
            }
            implementor = implementor?.nextCommandResponder
        }
        return nil
    }

    public func sendCommand(command: Command?) -> Bool {
        guard let command = command else { return false }

        if command.responder == nil {
            command.responder = self
        }

        if let target = targetForCommand(command) {
            performCommand(command, on: target)
            return true
        }

        return false
    }

    private func performCommand(command: Command, on responder: UIResponder) {
        responder.performSelector(command.action, withObject: command, afterDelay: 0)
    }
}
