//
//  AppReducer.swift
//  Calibre
//
//  Created by Jeremy Tregunna on 9/6/16.
//  Copyright © 2016 Greenshire, Inc. All rights reserved.
//

import Calibre

struct AppReducer: Reducer {
    func handleAction(action: Action, state: AppState?) -> AppState {
        return AppState(
            navigationState: NavigationReducer().handleAction(action, state: state?.navigationState),
            products: ProductsReducer().handleAction(action, state: state?.products)
        )
    }
}
