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
    @objc func blah(command: ConcreteCommand)
}

class ConcreteCommand: NSObject, Command {
    weak var responder: UIResponder?
    var action: Selector

    init(responder: UIResponder?, action: Selector) {
        self.responder = responder
        self.action = action
    }
}
class Simple: UIViewController, Blah {
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
        let command = ConcreteCommand(responder: simple, action: #selector(Blah.blah(_:)))
        XCTAssertTrue(simple.sendCommand(command))
        XCTAssertTrue(simple.called)
    }

    func testComplexDelivery1() {
        let command = ConcreteCommand(responder: complex1, action: #selector(Blah.blah(_:)))
        XCTAssertTrue(complex1.sendCommand(command))
        XCTAssertTrue(complex1.simple.called)
    }

    func testComplexDelivery2() {
        let command = ConcreteCommand(responder: complex2, action: #selector(Blah.blah(_:)))
        XCTAssertTrue(complex2.sendCommand(command))
        XCTAssertTrue(complex2.complex1.simple.called)
    }
}
