//
//  ProductsListViewController.swift
//  Calibre
//
//  Created by Jeremy Tregunna on 9/6/16.
//  Copyright © 2016 Greenshire, Inc. All rights reserved.
//

import UIKit
import Calibre

class ProductsListViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let nib = UINib(nibName: NSStringFromClass(ProductsListCell.self), bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: ProductsListCell.identifier)

        self.clearsSelectionOnViewWillAppear = false
        self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        store.subscribe(self)

        tableView.reloadData()
    }

    override func viewDidDisappear(animated: Bool) {
        store.unsubscribe(self)

        super.viewDidDisappear(animated)
    }

    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
        
        let indexPath = NSIndexPath(forRow: store.state.products.count, inSection: 0)
        
        tableView.beginUpdates()
        if editing {
            tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else {
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
        tableView.endUpdates()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let productCount = store.state.products.count
        guard editing else { return productCount }
        return productCount + 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ProductsListCell.identifier, forIndexPath: indexPath) as! ProductsListCell

        if editing && indexPath.row == store.state.products.count {
            cell.titleLabel.text = "Add new product…"
            cell.priceLabel.text = ""
            cell.accessoryType = .DisclosureIndicator
        } else {
            let product = store.state.products[indexPath.row]
            cell.titleLabel.text = product.name
            cell.priceLabel.text = product.priceText
        }

        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Can add, not edit
        return false
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            store.dispatch(AddProductAction(name: "test", price: "$1.22"))
            tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }

    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }

    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if editing && indexPath.row == tableView.numberOfRowsInSection(0) - 1 {
            showAddNewItem()
        }
    }

    private func showAddNewItem() {
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

        let present = PresentViewAction(fromView: self, toView: alert)
        store.dispatch(present)
    }
}

extension ProductsListViewController: Subscriber {
    func newState(state: AppState) {
        tableView.reloadData()
    }
}
