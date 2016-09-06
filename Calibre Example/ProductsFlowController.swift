//
//  ProductsFlowController.swift
//  Calibre
//
//  Created by Jeremy Tregunna on 9/6/16.
//  Copyright © 2016 Greenshire, Inc. All rights reserved.
//

import UIKit
import Calibre

class ProductsFlowController: UIResponder {
    let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
    }
}

extension ProductsFlowController: SplashPresentable {
    func showProducts(command: Commandable) {
        let products = ProductsListViewController()
        products.nextCommandResponder = self
        navigationController.pushViewController(products, animated: true)
    }
}
