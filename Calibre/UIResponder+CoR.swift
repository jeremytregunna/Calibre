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
            #if swift(>=3)
                return next
            #else
                return nextResponder()
            #endif
        }
        set {
            objc_setAssociatedObject(self, &nextCommandResponderKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    #if swift(>=3)
    public func canPerformCommand(_ command: Commandable) -> Bool {
        return responds(to: command.action)
    }

    public func targetForCommand(_ command: Commandable) -> UIResponder? {
        var implementor: UIResponder? = self
        while implementor != nil {
            if let implementor = implementor, implementor.canPerformCommand(command) {
                return implementor
            }
            implementor = implementor?.nextCommandResponder
        }
        return nil
    }

    public func dispatch(_ command: Commandable?) -> Bool {
        guard let command = command else { return false }

        if command.target == nil {
            command.target = self
        }

        if let target = targetForCommand(command) {
            performCommand(command, on: target)
            return true
        }

        return false
    }

    fileprivate func performCommand(_ command: Commandable, on responder: UIResponder) {
        responder.perform(command.action, with: command)
    }
    #else
        public func canPerformCommand(command: Commandable) -> Bool {
            return respondsToSelector(command.action)
        }

        public func targetForCommand(command: Commandable) -> UIResponder? {
            var implementor: UIResponder? = self
            while implementor != nil {
                if let implementor = implementor where implementor.canPerformCommand(command) {
                    return implementor
                }
                implementor = implementor?.nextCommandResponder
            }
            return nil
        }

        public func dispatch(command: Commandable?) -> Bool {
            guard let command = command else { return false }

            if command.target == nil {
                command.target = self
            }

            if let target = targetForCommand(command) {
                performCommand(command, on: target)
                return true
            }

            return false
        }

        private func performCommand(command: Commandable, on responder: UIResponder) {
            responder.performSelector(command.action, withObject: command)
        }
    #endif
}
