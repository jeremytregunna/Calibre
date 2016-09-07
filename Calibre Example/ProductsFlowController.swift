//
//  ProductsFlowController.swift
//  Calibre
//
//  Created by Jeremy Tregunna on 9/6/16.
//  Copyright © 2016 Greenshire, Inc. All rights reserved.
//

import UIKit
import Calibre

@objc protocol ProductFlow {
    func showProducts(command: Commandable)
    func showAddNewItem()
}

class ProductsFlowController: UIResponder {
    let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
        navigationController.nextCommandResponder = self
    }
}

extension ProductsFlowController: ProductFlow {
    func showProducts(command: Commandable) {
        let products = ProductsListViewController()
        navigationController.pushViewController(products, animated: true)
    }

    func showAddNewItem() {
        let alert = UIAlertController(title: "Add Product", message: "What's the product called?", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler { (field) in
            field.placeholder = "Product name"
        }

        alert.addTextFieldWithConfigurationHandler { (field) in
            field.placeholder = "$1.99"
        }

        let done = UIAlertAction(title: "Done", style: .Default) { (action) in
            if let nameField = alert.textFields?.first, let name = nameField.text,
               let priceField = alert.textFields?.last, let price = priceField.text {
                let addAction = AddProductAction(name: name, price: price)
                store.dispatch(addAction)
            }
        }

        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)

        alert.addAction(done)
        alert.addAction(cancel)

        navigationController.presentViewController(alert, animated: true, completion: nil)
    }
}
