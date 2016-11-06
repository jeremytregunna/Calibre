//
//  PresentViewAction.swift
//  UserFlow
//
//  Created by Jeremy Tregunna on 10/16/16.
//  Copyright © 2016 Greenshire, Inc. All rights reserved.
//

import UIKit
import Calibre

// This isn't wholly complete, i.e., it doesn't take into account things like transition/presentation styles.
struct PresentViewAction: Action {
    let fromView: UIViewController
    let toView: UIViewController
    let animated: Bool = true
}
