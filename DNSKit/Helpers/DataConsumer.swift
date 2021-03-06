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

    let data: Data
    private(set) var offset: Int
    private(set) var maxOffset: Int
    private var bitOffset: Int

    private(set) var bytesTotal: UInt32
    private(set) var bytesConsumed: UInt32
    var bytesRemaining: UInt32 {
        return UInt32(maxOffset - offset)
    }

    init(data: Data, startOffset: Int = 0, maxOffset: Int? = nil) throws {
        guard startOffset < data.count else {
            throw ConsumerError.outOfBounds
        }
        self.data = data
        self.offset = startOffset
        self.maxOffset = min(maxOffset ?? data.count, data.count)
        self.bitOffset = 0
        self.bytesTotal = UInt32(data.count)
        self.bytesConsumed = 0
    }

    mutating func peek() throws -> Data {
        return try peek(bytesRemaining)
    }

    mutating func take() throws -> Data {
        return try take(bytesRemaining)
    }

    func peek<I: BinaryInteger>(bits count: I) throws -> UInt8 {
        let end = bitOffset + Int(count)
        guard end <= 8 else {
            throw ConsumerError.invalidBitOffset
        }
        guard offset < maxOffset else {
            throw ConsumerError.outOfBounds
        }
        let byte = data[offset]
        let value = (byte << bitOffset) >> (8 - count)
        return value
    }

    mutating func take<I: BinaryInteger>(bits count: I) throws -> UInt8 {
        let result: UInt8 = try peek(bits: count)
        try drop(bits: count)
        return result
    }

    func peek<I: BinaryInteger>(bits count: I) throws -> UInt16 {
        let end = bitOffset + Int(count)
        guard end <= 16 else {
            throw ConsumerError.invalidBitOffset
        }
        guard offset + (end / 8) < maxOffset else {
            throw ConsumerError.outOfBounds
        }
        let bytes: UInt16 = try {
            if end <= 8 {
                let byte = data[offset]
                return UInt16(byte)
            } else {
                let bytes = Data(data[offset...(offset+1)])
                return try UInt16(networkBytes: bytes)
            }
        }()
        let value = (bytes << bitOffset) >> (16 - count)
        return value
    }

    mutating func take<I: BinaryInteger>(bits count: I) throws -> UInt16 {
        let result: UInt16 = try peek(bits: count)
        try drop(bits: count)
        return result
    }

    func peek<I: BinaryInteger>(_ count: I) throws -> Data {
        guard bitOffset == 0 else {
            throw ConsumerError.invalidBitOffset
        }
        let end = offset + Int(count)
        guard end <= maxOffset else {
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
        var end = bitOffset + Int(count)
        while end >= 8 {
            end -= 8
            try drop(1)
        }
        bitOffset = end
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

    func spinoff() throws -> DataConsumer {
        return try DataConsumer(
            data: data,
            startOffset: offset
        )
    }
}
