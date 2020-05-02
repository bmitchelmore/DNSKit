//
//  DNSKEYData.swift
//  DNSKit
//
//  Created by Blair Mitchelmore on 2020-05-01.
//  Copyright © 2020 Blair Mitchelmore. All rights reserved.
//

import Foundation

public struct DNSKEYData: Hashable {
    var zk: Bool
    var revoked: Bool
    var sep: Bool
    var proto: UInt8
    var alg: DNSSECAlgorithm
    var pk: DNSSECPublicKey
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
        let bytes: [UInt8] = try [
            flag.bytes(),
            [proto, alg.rawValue],
            pk.bytes
        ].flatMap { $0 }
        return [
            UInt16(bytes.count).bytes,
            bytes
        ].flatMap { $0 }
    }
}

extension DataConsumer {
    mutating func take() throws -> DNSKEYData {
        let len: UInt16 = try take()
        return try take(len) { consumer in
            try consumer.drop(bits: 7)
            let zk: Bool = try consumer.take()
            let revoked: Bool = try consumer.take()
            try consumer.drop(bits: 6)
            let sep: Bool = try consumer.take()
            let proto: UInt8 = try consumer.take()
            let alg: DNSSECAlgorithm = try consumer.take(or: DNSParseError.invalidAlgorithm) { DNSSECAlgorithm(rawValue: $0) }
            let pk: DNSSECPublicKey = try consumer.take(for: alg)
            return DNSKEYData(
                zk: zk,
                revoked: revoked,
                sep: sep,
                proto: proto,
                alg: alg,
                pk: pk
            )
        }
    }
}
