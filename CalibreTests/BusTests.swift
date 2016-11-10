//
//  BusTests.swift
//  Calibre
//
//  Created by Jeremy Tregunna on 11/10/16.
//  Copyright © 2016 Greenshire, Inc. All rights reserved.
//

import XCTest
@testable import Calibre

class BusTests: XCTestCase {
    var bus: Bus<Int> = Bus(timeout: 1)

    func testsSendsAndReceivesValue() {
        bus.send(value: 1)
        let value = try? bus.receive()
        XCTAssert(value == 1)
    }

    func testsBusTimesOut() {
        do {
            let _ = try bus.receive()
            XCTFail("Should not get to this point")
        } catch BusError.timeout {
            // Expected
        } catch {
            XCTFail("Expected a timeout")
        }
    }
    
    func testSendMultipleValuesReceivesAllValues() {
        bus.send(value: 1)
        bus.send(value: 2)
        let first = try? bus.receive()
        XCTAssert(first == 1)
        let second = try? bus.receive()
        XCTAssert(second == 2)
    }
}
