//
//  CommandChainTests.swift
//  Calibre
//
//  Created by Jeremy Tregunna on 9/5/16.
//  Copyright © 2016 Greenshire, Inc. All rights reserved.
//

import XCTest
@testable import Calibre

@objc protocol Blah: class {
    func blah(command: ConcreteCommand)
}

class ConcreteCommand: NSObject, Command {
    weak var target: UIResponder?
    var action: Selector

    init(target: UIResponder?, action: Selector) {
        self.target = target
        self.action = action
    }
}
class Simple: UIResponder, Blah {
    var called: Bool = false
    @objc func blah(command: ConcreteCommand) {
        called = true
    }
}

class Complex1: UIViewController {
    let simple: Simple

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        simple = Simple()
        super.init(nibName: nil, bundle: nil)
        nextCommandResponder = simple
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class Complex2: UIViewController {
    let complex1: Complex1
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        complex1 = Complex1()
        super.init(nibName: nil, bundle: nil)
        nextCommandResponder = complex1
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class CommandChainTests: XCTestCase {
    var simple: Simple!
    var complex1: Complex1!
    var complex2: Complex2!
    
    override func setUp() {
        super.setUp()

        simple = Simple()
        complex1 = Complex1()
        complex2 = Complex2()
    }

    func testSimpleDelivery() {
        let command = ConcreteCommand(target: simple, action: #selector(Blah.blah(_:)))
        XCTAssertTrue(simple.dispatch(command))
        XCTAssertTrue(simple.called)
    }

    func testComplexDelivery1() {
        let command = ConcreteCommand(target: complex1, action: #selector(Blah.blah(_:)))
        XCTAssertTrue(complex1.dispatch(command))
        XCTAssertTrue(complex1.simple.called)
    }

    func testComplexDelivery2() {
        let command = ConcreteCommand(target: complex2, action: #selector(Blah.blah(_:)))
        XCTAssertTrue(complex2.dispatch(command))
        XCTAssertTrue(complex2.complex1.simple.called)
    }
}
