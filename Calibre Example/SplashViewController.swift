//
//  SplashViewController.swift
//  Calibre
//
//  Created by Jeremy Tregunna on 9/6/16.
//  Copyright © 2016 Greenshire, Inc. All rights reserved.
//

import UIKit
import Calibre

class SplashViewController: UIViewController {
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        store.subscribe(self)
    }
    
    override func viewWillDisappear(animated: Bool) {
        store.unsubscribe(self)
        super.viewWillDisappear(animated)
    }

    @IBAction func addSeedProductsTapped(sender: UIButton) {
        let addSeed = AddSeeds()
        store.fire(addSeed)
    }

    @IBAction func showProductsTapped(sender: UIButton) {
        let products = ProductsListViewController()
        let push = PushViewAction(view: products, navigationController: self.navigationController)
        store.dispatch(push)
    }
}

extension SplashViewController: Subscriber {
    func newState(state: AppState) {
        print(state)
    }
}
