//
//  ProductsReducer.swift
//  Calibre
//
//  Created by Jeremy Tregunna on 9/6/16.
//  Copyright © 2016 Greenshire, Inc. All rights reserved.
//

import Calibre

struct ProductsReducer: Reducer {
    func handleAction(action: Action, state: [Product]?) -> [Product] {
        var state = state ?? []

        switch action {
        case let add as AddProductAction:
            let formatter = NSNumberFormatter()
            formatter.numberStyle = .CurrencyStyle
            let formattedPrice = formatter.numberFromString(add.price) ?? NSNumber(int: 0)
            let price = Int(round(formattedPrice.doubleValue * 100.0))
            let product = Product(name: add.name, price: price)
            state += [product]
        default: break
        }

        return state
    }
}
