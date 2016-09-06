//
//  Product.swift
//  Calibre
//
//  Created by Jeremy Tregunna on 9/6/16.
//  Copyright © 2016 Greenshire, Inc. All rights reserved.
//

import Foundation

struct Product {
    let name: String
    let price: Int

    var priceText: String? {
        get {
            let formatter = NSNumberFormatter()
            formatter.numberStyle = .CurrencyStyle
            return formatter.stringFromNumber(NSNumber(double: Double(price) / 100.0))
        }
    }
}
