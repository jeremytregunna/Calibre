//
//  PushViewAction.swift
//  UserFlow
//
//  Created by Jeremy Tregunna on 10/16/16.
//  Copyright © 2016 Greenshire, Inc. All rights reserved.
//

import UIKit
import Calibre

struct PushViewAction: Action {
    let view: UIViewController
    let navigationController: UINavigationController?
    let animated: Bool = true
}
