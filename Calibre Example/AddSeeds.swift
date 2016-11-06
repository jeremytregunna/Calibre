//
//  AddSeeds.swift
//  Calibre
//
//  Created by Jeremy Tregunna on 11/6/16.
//  Copyright © 2016 Greenshire, Inc. All rights reserved.
//

import Foundation
import Calibre

// AddSeeds simulates some asynchronous operation. In this case we're just statically defining items for the table view, but
// in a real example, this would make a network request, and in its callback or delegate or whatever, fire an action (or actions)
// to indicate some state change.
struct AddSeeds: Command {
    typealias State = AppState
    
    func execute(state: State, store: Store<State>) {
        let seedProductNames = ["Bacon", "Gallo Pinto", "Potato"]
        let seedProductPrices = ["$1.28", "$5.12", "$2.56"]
        for index in 0..<seedProductNames.count {
            let addProduct = AddProductAction(name: seedProductNames[index], price: seedProductPrices[index])
            store.dispatch(addProduct)
        }
    }
}
