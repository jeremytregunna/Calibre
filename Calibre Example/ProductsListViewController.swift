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

        if editing {
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

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            store.dispatch(AddProductAction(name: "test", price: "$1.22"))
            tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
}

extension ProductsListViewController: Subscriber {
    func newState(state: AppState) {
        tableView.reloadData()
    }
}
