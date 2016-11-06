//
//  PopNavigationAction.swift
//  UserFlow
//
//  Created by Jeremy Tregunna on 10/16/16.
//  Copyright © 2016 Greenshire, Inc. All rights reserved.
//

import UIKit
import Calibre

struct PopNavigationAction: Action {
    let navigationController: UINavigationController
    let toRoot: Bool = false
    let animated: Bool = true
}
