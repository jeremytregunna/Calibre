//
//  Bus.swift
//  Calibre
//
//  Created by Jeremy Tregunna on 11/10/16.
//  Copyright © 2016 Greenshire, Inc. All rights reserved.
//

import Foundation

enum BusError: ErrorType {
    case timeout
}

class Bus<T> {
    private let queue: dispatch_queue_t
    private let semaphore: dispatch_semaphore_t
    private let timeoutDelta: Int64
    var stream: Array<T>

    init(timeout: Double = -1) {
        queue        = dispatch_queue_create("co.greenshire.library.Calibre.queues.bus", DISPATCH_QUEUE_CONCURRENT)
        semaphore    = dispatch_semaphore_create(0)
        timeoutDelta = Int64(timeout < 0 ? DISPATCH_TIME_FOREVER : UInt64(timeout * Double(NSEC_PER_SEC)))
        stream       = []
    }

    func send(value: T) {
        dispatch_barrier_async(queue) {
            self.stream.append(value)
            dispatch_semaphore_signal(self.semaphore)
        }
    }

    func receive() throws -> T {
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