//
//  DataConsumerExtensions.swift
//  DNSKit
//
//  Created by Blair Mitchelmore on 2020-04-23.
//  Copyright © 2020 Blair Mitchelmore. All rights reserved.
//

import Foundation
import Network

extension DataConsumer {
    mutating func peek() throws -> Bool {
        let value: UInt8 = try peek(bits: 1)
        return value == 1
    }

    mutating func take() throws -> Bool {
        let value: UInt8 = try take(bits: 1)
        return value == 1
    }

    mutating func peek() throws -> UInt8 {
        return try peek(1)[0]
    }

    mutating func peek() throws -> UInt16 {
        return try UInt16(networkBytes: peek(2))
    }

    mutating func peek() throws -> UInt32 {
        return try UInt32(networkBytes: peek(4))
    }

    mutating func take() throws -> UInt8 {
        let value: UInt8 = try peek()
        try drop(1)
        return value
    }

    mutating func take() throws -> UInt16 {
        let value: UInt16 = try peek()
        try drop(2)
        return value
    }

    mutating func take() throws -> UInt32 {
        let value: UInt32 = try peek()
        try drop(4)
        return value
    }

    mutating func take<T>(_ count: UInt16, processor: (inout DataConsumer) throws -> T) throws -> T {
        var bytes = try DataConsumer(data: data, startOffset: offset, maxOffset: offset + Int(count))
        let result = try processor(&bytes)
        guard count == bytes.bytesConsumed else {
            logger.error(ConsumerError.invalidConversion, "failed to convert \(count) bytes (\(data.hex)) to \(T.self)")
            throw ConsumerError.invalidConversion
        }
        try drop(count)
        return result
    }

    mutating func take<T>(or error: Error, processor: (UInt8) -> T?) throws -> T {
        let byte: UInt8 = try peek()
        guard let result = processor(byte) else {
            logger.error(error, "failed to convert 1 byte (\(byte.hex)) to \(T.self)")
            throw error
        }
        try drop(1)
        return result
    }

    mutating func take<T>(or error: Error, processor: (UInt16) -> T?) throws -> T {
        let byte: UInt16 = try peek()
        guard let result = processor(byte) else {
            logger.error(error, "failed to convert 2 bytes (\(byte.hex)) to \(T.self)")
            throw error
        }
        try drop(2)
        return result
    }
}

