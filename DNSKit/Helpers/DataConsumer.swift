//
//  DataConsumer.swift
//  DNSKit
//
//  Created by Blair Mitchelmore on 2020-04-23.
//  Copyright © 2020 Blair Mitchelmore. All rights reserved.
//

import Foundation

struct DataConsumer {
    enum ConsumerError: Error {
        case outOfBounds
        case invalidConversion
        case invalidBitOffset
    }

    private let data: Data
    private var offset: Int
    private var bitOffset: Int

    var bytesTotal: UInt32
    var bytesConsumed: UInt32

    init(data: Data, startOffset: Int = 0) throws {
        guard startOffset < data.count else {
            throw ConsumerError.outOfBounds
        }
        self.data = data
        self.offset = startOffset
        self.bitOffset = 0
        self.bytesTotal = UInt32(data.count)
        self.bytesConsumed = 0
    }

    mutating func peek() throws -> Data {
        let remaining = data.count - offset
        return try peek(remaining)
    }

    mutating func take() throws -> Data {
        let remaining = data.count - offset
        return try take(remaining)
    }

    func peek<I: BinaryInteger>(bits count: I) throws -> UInt8 {
        let end = bitOffset + Int(count)
        guard end <= 8 else {
            throw ConsumerError.invalidBitOffset
        }
        guard offset < data.count else {
            throw ConsumerError.outOfBounds
        }
        let byte = data[offset]
        let value = (byte << bitOffset) >> (8 - count)
        return value
    }

    mutating func take<I: BinaryInteger>(bits count: I) throws -> UInt8 {
        let result = try peek(bits: count)
        try drop(bits: count)
        return result
    }

    func peek<I: BinaryInteger>(_ count: I) throws -> Data {
        guard bitOffset == 0 else {
            throw ConsumerError.invalidBitOffset
        }
        let end = offset + Int(count)
        guard end <= data.count else {
            throw ConsumerError.outOfBounds
        }
        let result = data.subdata(in: offset..<end)
        return result
    }

    mutating func take<I: BinaryInteger>(_ count: I) throws -> Data {
        let result = try peek(count)
        try drop(count)
        return result
    }

    mutating func drop<I: BinaryInteger>(bits count: I) throws {
        let end = bitOffset + Int(count)
        guard end <= 8 else {
            throw ConsumerError.invalidBitOffset
        }
        if end == 8 {
            bitOffset = 0
            try drop(1)
        } else {
            bitOffset = end
        }
    }

    mutating func drop<I: BinaryInteger>(_ count: I) throws {
        offset += Int(count)
        bytesConsumed += UInt32(count)
    }

    func spinoff<I: BinaryInteger>(at offset: I) throws -> DataConsumer {
        return try DataConsumer(
            data: data,
            startOffset: Int(offset)
        )
    }
}
