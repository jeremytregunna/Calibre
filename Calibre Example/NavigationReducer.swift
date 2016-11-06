//
//  NavigationReducer.swift
//  Calibre
//
//  Created by Jeremy Tregunna on 11/6/16.
//  Copyright © 2016 Greenshire, Inc. All rights reserved.
//

import Foundation
import Calibre

class NavigationReducer: Reducer {
    lazy var initialState: NavigationState = {
        return NavigationState(currentView: nil)
    }()
    
    func handleAction(action: Action, state: NavigationState?) -> NavigationState {
        var state = state ?? initialState
        
        switch action {
        case let push as PushViewAction:
            if let nav = push.navigationController {
                nav.pushViewController(push.view, animated: push.animated)
                state.currentView = push.view
            }
        case let present as PresentViewAction:
            present.fromView.presentViewController(present.toView, animated: present.animated) {
                state.currentView = present.toView
            }
        case let pop as PopNavigationAction:
            if pop.toRoot {
                pop.navigationController.popToRootViewControllerAnimated(pop.animated)
            } else {
                pop.navigationController.popViewControllerAnimated(pop.animated)
            }
        case let dismiss as DismissViewAction:
            state.currentView?.dismissViewControllerAnimated(dismiss.animated) {
                // This isn't sufficient. A more robust system would track which belongs to what, set `currentView` to the value of `parentView` or similar, and restore a `parentView` property on the state to the right object. But for this test, it doesn't matter.
                state.currentView = nil
            }
        default: break
        }
        
        return state
    }
}