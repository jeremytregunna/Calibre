# Calibre

![Build status](https://circleci.com/gh/Greenshire/Calibre.svg?style=shield&circle-token=4787eb6a56cb69e12378fd73fe31bb622028aa93)

Calibre is a Redux-ish development architecture for building reactive applications.

Calibre encourages you to have one single source of truth, we call that your "app state". It gives you the tools to affect change to your app state, we call those "actions". Actions are sent to your business/application logic or other assorted middlewares which are isolated from the rest of your application, ensuring that it's easy to find all the rules that make your app tick, we call these "reducers". Finally, after your app state has been updated, it's sent to all subscribers, like your views so they can update what they display. Using these tools lets you keep data flowing in one direction, which makes your code easier to understand.

## Architecture

![alt text](https://github.com/Greenshire/Calibre/raw/master/readme-assets/architecture.png "Architecture diagram")

The key pieces in this architecture are illustrated above. Their meaning is defined below:

* Store — Provided by Calibre to manage your application state
* Actions — Provided by you, these are objects with semantic meaning to your reducers
* Reducers — Provided by you, encoding the rules that involve your application's actions, or any middleware (such as analytics)
* Commands — Provided by you. These are like Actions, but they aren't handled by any reducers. This means if you want to make a network request and update some state because of it, your command has to dispatch an action.
* View — Provided by you. These are subscribers to app state, typically your view controllers, but not exclusively your view controllers.

### State

State defines what your application knows. It may be split out in some complicated way, or be very simple. Consider:

```swift
struct AppState: StateType {
    var navigation: NavigationState
    var products: [Product]
}
```

In this example, your application state is combined of two pieces of state: An opaque object containing information about your specific navigation requirements in your app (current navigation controller and top most view controller, for instance); and an array of Product objects. These represent all the things your app knows about at any given time, at runtime.

### Store

The Store is the main coordinator object. You make exactly one of these, it can be a global variable in your AppDelegate like this:

```swift
let store = Store<AppState>(reducer: AppReducer(), state: nil)
```

It's initialized with a top level reducer. More info on that in the Reducer section below, and a nil state (you can do state restoration later, or at this time, if you want).

### Reducers

A Reducer is an object which handles an action within the domain of some section of your application state. Reducers also form a tree. Consider:

```swift
struct AppReducer: Reducer {
    func handleAction(action: Action, state: AppState?) -> AppState {
        return AppState(
            navigation: NavigationReducer().handleAction(action, state: state?.navigation),
            products: ProductsReducer().handleAction(action, state: state?.products)
        )
    }
}
```

You'd also have a `NavigationReducer` and a `ProductsReducer` that look somewhat like this:

```swift
struct NavigationReducer: Reducer {
    func handleAction(action: Action, state: NavigationState?) -> NavigationState {
        var state = state ?? initialState() // You'd implement initialState() to restore previous state or create a new NavigationState, up to you
        switch action {
        case let push as PushViewAction:
            if let nav = push.navigationController {
                nav.pushViewController(push.view, animated: push.animated)
                state.currentView = push.view
            }
        default: break
        }
        return state
    }
}

struct ProductsReducer: Reducer {
    func handleAction(action: Action, state: [Product]?) -> [Product] {
        var state = state ?? [] // Here we don't care about restoring
        switch action {
        case let add as AddProductAction:
            let product = Product(name: add.name, price: add.price)
            state += [product]
        default: break
        }
        return state
    }
}
```

We first need to set up the basics of what will be the state we're operating on, in the products reducer case, we say it's either the state we got passed in, or an empty array since our `ProductsReducer` only works on arrays of `Product` objects. Then we'll switch on the action we want, and only implement case statements for the actions we want to handle, otherwise we just return the previously configured state. If an action we want to handle is in our switch statement, we'll make the appropriate updates to our state before returning it.

### Command

When it comes to asynchronous tasks, like network requests, you really don't want to do those in reducers. They can cause an infinite loop in Store's dispatch method. Instead, you have the Command protocol to implement, where you define your state type and an execute function that does your work. See the example below:

```swift
struct SignIn: Command {
    typealias State = AppState
    let email: String
    let password: String

    func execute(state: State, store: Store<State>) {
        network.signin(email: email, password: password) { (response) in
            if let token = response.token {
                let receivedToken = ReceivedTokenAction(token: token)
                store.dispatch(receivedToken)
            }
        }
    }
}
```

It would be fired like this:

```swift
let signIn = SignIn(email: "bob@mctestinsti.ne", password: "abc123")
store.fire(signIn)
```

What's going on here is is that when you `fire` a command, the Store will call your execute function, passing in the current app state and its instance. This process bypasses passing it to the reducers, therefore you need to dispatch an action with any state change you want to make; this is why there's a `ReceivedTokenAction` above. Conceptually, after a sign in, you'll pass that token to your app state, so that you can use it to sign any future requests you make.

### View

Eventually, you want to be updated if state changes, so you can change text in a label or reload a table view. There's a couple things that have to happen here:

```swift
class MyViewController: UITableViewController, Subscriber {
    override func viewWillAppear(animated: true) {
        super.viewWillAppear(animated)
        store.subscribe(self)
    }

    override func viewWillDisappear(animated: true) {
        store.unsubscribe(self)
        super.viewWillDisappear(animated: true)
    }

    // Subscriber method
    func newState(state: AppState) {
        tableView.reloadData()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return store.state.products.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ProductsListCell", forIndexPath: indexPath) as! ProductsListCell

        let product = store.state.products[indexPath.row]
        cell.titleLabel.text = product.name
        cell.priceLabel.text = product.priceText

        return cell
    }
}
```

Quickly what's going on here is we've got a list of some products. This list of products is presented in a table view. We ask the store's state for the number of products it knows about, since it's the single source of truth. We then set up the cell as required.

Additionally we're defining a `newState` method which receives the current app state. This method is called by the Store object after state updates occur, so you always get the absolute latest application state whenever this method is called.

Finally, we need to tell the Store that we want to receive updates when we're showing, but tell it we don't want to receive them when we're not. Therefore we call `subscribe` and `unsubscribe` at the appropriate places (in the above example, `viewWillAppear` and `viewWillDisappear`; you may have other places this has to happen). Both of these operations are indempotent so they can be called as many times as are required. You can only subscribe once, and only unsubscribe once.

## Installation

CocoaPods:

```
pod "Greenshire/Calibre"
```

To use Carthage, add to your Cartfile:

```
github "Greenshire/Calibre" ~> 2.0.0
```

## License

Copyright (c) 2016 Greenshire, Inc. All Rights Reserved.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

