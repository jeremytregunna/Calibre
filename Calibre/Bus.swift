//
//  Bus.swift
//  Calibre
//
//  Created by Jeremy Tregunna on 11/10/16.
//  Copyright © 2016 Greenshire, Inc. All rights reserved.
//

import Foundation

public enum BusError: ErrorType {
    case timeout
}

public class Bus<T> {
    private let queue: dispatch_queue_t
    private let semaphore: dispatch_semaphore_t
    private let timeoutDelta: Int64
    private var stream: Array<T>

    /** Create a new bus.
        - parameter timeout: Read timeout in seconds. Supports subsecond values. If negative, no timeout. Default value: `-1`.
     */
    public init(timeout: Double = -1) {
        queue        = dispatch_queue_create("co.greenshire.library.Calibre.queues.bus", DISPATCH_QUEUE_CONCURRENT)
        semaphore    = dispatch_semaphore_create(0)
        timeoutDelta = Int64(timeout < 0 ? DISPATCH_TIME_FOREVER : UInt64(timeout * Double(NSEC_PER_SEC)))
        stream       = []
    }

    /** Send a value onto the bus.
        - parameter value: The value to place onto the bus.
     */
    public func send(value: T) {
        dispatch_barrier_async(queue) {
            self.stream.append(value)
            dispatch_semaphore_signal(self.semaphore)
        }
    }

    /** Receive a value over the bus.
        - returns: The next value waiting on the bus
        - throws: `BusError.timeout` if your (optional) read timeout expires before a value is available.
     */
    public func receive() throws -> T {
        var result: T? = nil
        dispatch_sync(queue) {
            let timeoutOccurred = dispatch_semaphore_wait(self.semaphore, dispatch_time(DISPATCH_TIME_NOW, self.timeoutDelta))

            if timeoutOccurred == 0 {
                // didn't timeout, means we have an item in the stream.
                result = self.stream.removeFirst()
            }
        }

        if let result = result {
            return result
        }

        throw BusError.timeout
    }
}