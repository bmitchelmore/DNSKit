//
//  RRSIGData.swift
//  DNSKit
//
//  Created by Blair Mitchelmore on 2020-04-30.
//  Copyright © 2020 Blair Mitchelmore. All rights reserved.
//

import Foundation

public struct RRSIGData: Hashable {
    var type: DNSRecordType
    var algorithm: DNSSECAlgorithm
    var labels: UInt8
    var ttl: UInt32
    var expiration: Date
    var inception: Date
    var tag: UInt16
    var signer: String
    var signature: Data
}

extension Date {
    var bytes: [UInt8] {
        let seconds: UInt32 = UInt32(timeIntervalSince1970)
        return seconds.bytes
    }
}

extension RRSIGData {
    var bytes: [UInt8] {
        return [
            type.rawValue.bytes,
            [algorithm.rawValue, labels],
            ttl.bytes,
            expiration.bytes,
            inception.bytes,
            tag.bytes,
            DNSString(signer).bytes,
            signature.map { $0 }
        ].flatMap { $0 }
    }
}

extension DataConsumer {
    mutating func take() throws -> Date {
        let seconds: UInt32 = try take()
        return Date(timeIntervalSince1970: TimeInterval(seconds))
    }
    mutating func take() throws -> RRSIGData {
        let len: UInt16 = try take()
        return try take(len) { consumer in
            let type: DNSRecordType = try consumer.take()
            let algorithm: DNSSECAlgorithm = try consumer.take(or: DNSParseError.invalidAlgorithm) { DNSSECAlgorithm(rawValue: $0) }
            let labels: UInt8 = try consumer.take()
            let ttl: UInt32 = try consumer.take()
            let expiration: Date = try consumer.take()
            let inception: Date = try consumer.take()
            let tag: UInt16 = try consumer.take()
            let signer: DNSString = try consumer.take()
            let signature: Data = try consumer.take()
            return RRSIGData(
                type: type,
                algorithm: algorithm,
                labels: labels,
                ttl: ttl,
                expiration: expiration,
                inception: inception,
                tag: tag,
                signer: signer.string,
                signature: signature
            )
        }
    }
}
