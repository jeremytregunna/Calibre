//
//  SplashViewController.swift
//  Calibre
//
//  Created by Jeremy Tregunna on 9/6/16.
//  Copyright © 2016 Greenshire, Inc. All rights reserved.
//

import UIKit
import Calibre

@objc protocol SplashPresentable {
    func showProducts(command: Commandable)
}

class SplashViewController: UIViewController {
    @IBOutlet var showProductsButton: UIButton!

    @IBAction func showProductsTapped(sender: UIButton) {
        let command = BasicCommand(target: self, action: #selector(SplashPresentable.showProducts(_:)))
        dispatch(command)
    }
}
