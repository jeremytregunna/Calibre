//
//  Navigation.swift
//  Calibre
//
//  Created by Jeremy Tregunna on 9/4/16.
//  Copyright © 2016 Jesse Squires. All rights reserved.
//  Copyright © 2016 Greenshire, Inc. All rights reserved.
//

import UIKit

public enum PresentationType {
    case Modal(NavigationStyle, UIModalPresentationStyle, UIModalTransitionStyle)
    case Popover(PopoverConfig)
    case Push
    case Show
    case ShowDetail(NavigationStyle)
    case Custom(UIViewControllerTransitioningDelegate)
}

public enum NavigationStyle {
    case None
    case WithNavigation
}

public struct PopoverConfig {
    enum Source {
        case BarButtonItem(UIBarButtonItem)
        case View(UIView)
    }
    
    let source: Source
    let arrowDirection: UIPopoverArrowDirection
    let delegate: UIPopoverPresentationControllerDelegate?
}

public struct DismissButtonConfig {
    public enum Location {
        case Left
        case Right
    }

    public enum Style {
        case Bold
        case Plain
    }

    public enum Text {
        case SystemItem(UIBarButtonSystemItem)
        case Custom(String)
    }

    public let location: Location
    public let style: Style
    public let text: Text

    public init(location: Location = .Left, style: Style = .Plain, text: Text = .SystemItem(.Cancel)) {
        self.location = location
        self.style = style
        self.text = text
    }
}

public extension UIBarButtonItem {
    public convenience init(config: DismissButtonConfig, target: AnyObject?, action: Selector) {
        if let title = config.text.title {
            self.init(title: title, style: config.style.itemStyle, target: target, action: action)
        } else {
            self.init(barButtonSystemItem: config.text.systemItem!, target: target, action: action)
        }
        self.style = config.style.itemStyle
    }
}


internal extension DismissButtonConfig.Style {
    var itemStyle: UIBarButtonItemStyle {
        switch self {
        case .Bold:
            return .Done
        case .Plain:
            return .Plain
        }
    }
}


internal extension DismissButtonConfig.Text {
    var systemItem: UIBarButtonSystemItem? {
        switch self {
        case .SystemItem(let item):
            return item
        default:
            return nil
        }
    }
    
    var title: String? {
        switch self {
        case .Custom(let str):
            return str
        default:
            return nil
        }
    }
}
