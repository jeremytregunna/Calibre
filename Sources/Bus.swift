//
//  Bus.swift
//  Calibre
//
//  Created by Jeremy Tregunna on 11/10/16.
//  Copyright © 2016 Greenshire, Inc. All rights reserved.
//

import Foundation

public enum BusError: Error {
    case timeout
}

public class Bus<T> {
    private let queue: DispatchQueue
    private let semaphore: DispatchSemaphore
    private let timeoutTime: DispatchTime
    private var stream: Array<T>

    /** Create a new bus.
        - parameter timeout: Read timeout in seconds. Supports subsecond values. If negative, no timeout. Default value: `-1`.
     */
    public init(timeout: Double = -1) {
        queue       = DispatchQueue(label: "co.greenshire.library.Calibre.queues.bus", attributes: .concurrent)
        semaphore   = DispatchSemaphore(value: 0)
        timeoutTime = timeout < 0 ? DispatchTime.distantFuture : DispatchTime.now() + timeout
        stream      = []
    }

    /** Send a value onto the bus.
        - parameter value: The value to place onto the bus.
     */
    public func send(value: T) {
        queue.async(flags: .barrier) {
            self.stream.append(value)
            self.semaphore.signal()
        }
    }

    /** Receive a value over the bus.
        - returns: The next value waiting on the bus
        - throws: `BusError.timeout` if your (optional) read timeout expires before a value is available.
     */
    public func receive() throws -> T {
        let result = try queue.sync { () -> T in
            let timeoutStatus = self.semaphore.wait(timeout: self.timeoutTime)
            switch timeoutStatus {
            case .timedOut:
                throw BusError.timeout
            case .success:
                return self.stream.removeFirst()
            }
        }
        return result
    }
}
