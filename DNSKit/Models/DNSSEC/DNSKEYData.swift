//
//  DNSKEYData.swift
//  DNSKit
//
//  Created by Blair Mitchelmore on 2020-05-01.
//  Copyright © 2020 Blair Mitchelmore. All rights reserved.
//

import Foundation

func CalculateKeyTag(_ data: Data) -> UInt16 {
    var value: UInt32 = 0
    for i in 0..<data.count {
        value += (i & 0x1 == 0x1) ? UInt32(data[i]) : UInt32(data[i]) << 8
    }
    value += (value >> 16) & 0xffff
    return UInt16(value & 0xffff)
}

public struct DNSKEYData: Hashable {
    var zk: Bool
    var revoked: Bool
    var sep: Bool
    var proto: UInt8
    var alg: DNSSECAlgorithm
    var pk: DNSSECPublicKey
    var tag: UInt16
}

extension DNSKEYData {
    func bytes() throws -> [UInt8] {
        let flag: [BytePackage] = [
            .bits(value: 0, count: 7),
            .bit(zk),
            .bit(revoked),
            .bits(value: 0, count: 6),
            .bit(sep)
        ]
        return try [
            flag.bytes(),
            [proto, alg.rawValue],
            pk.bytes
        ].flatMap { $0 }
    }
}

extension DataConsumer {
    mutating func take() throws -> DNSKEYData {
        let len: UInt16 = try take()
        let tag: UInt16 = CalculateKeyTag(try peek(len))
        return try take(len) { consumer in
            try consumer.drop(bits: 7)
            let zk: Bool = try consumer.take()
            let revoked: Bool = try consumer.take()
            try consumer.drop(bits: 6)
            let sep: Bool = try consumer.take()
            let proto: UInt8 = try consumer.take()
            let alg: DNSSECAlgorithm = try consumer.take()
            let pk: DNSSECPublicKey = try consumer.take(for: alg)
            return DNSKEYData(
                zk: zk,
                revoked: revoked,
                sep: sep,
                proto: proto,
                alg: alg,
                pk: pk,
                tag: tag
            )
        }
    }
}
