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
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self)
    }

    @IBAction func addSeedProductsTapped(sender: UIButton) {
        let seedProductNames = ["Bacon", "Gallo Pinto", "Potato"]
        let seedProductPrices = ["$1.28", "$5.12", "$2.56"]
        for index in 0..<seedProductNames.count {
            let addProduct = AddProductAction(name: seedProductNames[index], price: seedProductPrices[index])
            store.dispatch(addProduct)
        }
    }

    @IBAction func showProductsTapped(sender: UIButton) {
        let command = BasicCommand(target: self, action: #selector(SplashPresentable.showProducts(_:)))
        dispatch(command)
    }
}

extension SplashViewController: Subscriber {
    func newState(state: AppState) {
        print(state)
    }
}
