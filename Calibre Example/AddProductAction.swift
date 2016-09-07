//
//  AddProductAction.swift
//  Calibre
//
//  Created by Jeremy Tregunna on 9/6/16.
//  Copyright © 2016 Greenshire, Inc. All rights reserved.
//

import Calibre

struct AddProductAction: Action {
    let name: String
    let price: String

    init(name: String, price: String) {
        self.name = name
        self.price = price
    }
}
