//
//  ResourceRecord.swift
//  DNSKit
//
//  Created by Blair Mitchelmore on 2020-04-27.
//  Copyright © 2020 Blair Mitchelmore. All rights reserved.
//

import Foundation
import Network

public struct ResourceRecord: Hashable {
    public let `class`: DNSRecordClass
    public let name: String
    public let ttl: UInt32
    public let data: ResourceRecordData
}

extension DataConsumer {
    mutating func take() throws -> IPv4Address {
        let len: UInt16 = try take()
        let bytes = try take(len)
        guard let ip = IPv4Address(bytes) else {
            throw ConsumerError.invalidConversion
        }
        return ip
    }

    mutating func take() throws -> IPv6Address {
        let len: UInt16 = try take()
        let bytes = try take(len)
        guard let ip = IPv6Address(bytes) else {
            throw ConsumerError.invalidConversion
        }
        return ip
    }

    mutating func take() throws -> ResourceRecord {
        let name: DNSString = try take()
        let type: DNSRecordType = try take()
        let `class`: DNSRecordClass = try take()
        let ttl: UInt32 = try take()
        switch type {
        case .a:
            let ip: IPv4Address = try take()
            return ResourceRecord(
                class: `class`,
                name: name.string,
                ttl: ttl,
                data: .a(ip)
            )
        case .ns:
            let ns: DNSString = try take()
            return ResourceRecord(
                class: `class`,
                name: name.string,
                ttl: ttl,
                data: .ns(ns.string)
            )
        case .soa:
            try drop(2)
            let soa: SOAData = try take()
            return ResourceRecord(
                class: `class`,
                name: name.string,
                ttl: ttl,
                data: .soa(soa)
            )
        case .txt:
            // len is redundant because TXTRecord
            // include a length byte as a prefix
            try drop(2)
            let txt: TXTRecord = try take()
            return ResourceRecord(
                class: `class`,
                name: name.string,
                ttl: ttl,
                data: .txt(txt.string)
            )
        case .aaaa:
            let ip: IPv6Address = try take()
            return ResourceRecord(
                class: `class`,
                name: name.string,
                ttl: ttl,
                data: .aaaa(ip)
            )
        }
    }
}
