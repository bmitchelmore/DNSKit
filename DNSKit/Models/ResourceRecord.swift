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
        let typeId: UInt16 = try take()
        let `class`: DNSRecordClass = try take()
        let ttl: UInt32 = try take()
        guard let type = DNSRecordType(rawValue: typeId) else {
            let len: UInt16 = try take()
            try drop(len)
            return ResourceRecord(
                class: `class`,
                name: name.string,
                ttl: ttl,
                data: .unknown(typeId)
            )
        }
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
            try drop(2)
            let ns: DNSString = try take()
            return ResourceRecord(
                class: `class`,
                name: name.string,
                ttl: ttl,
                data: .ns(ns.string)
            )
        case .cname:
            try drop(2)
            let domain: DNSString = try take()
            return ResourceRecord(
                class: `class`,
                name: name.string,
                ttl: ttl,
                data: .cname(domain.string)
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
        case .mx:
            try drop(2)
            let preference: UInt16 = try take()
            let exchange: DNSString = try take()
            return ResourceRecord(
                class: `class`,
                name: name.string,
                ttl: ttl,
                data: .mx(preference, exchange.string)
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
        case .srv:
            var components = name.string.components(separatedBy: ".")
            let service = components.removeFirst()
            let proto = components.removeFirst()
            let name = components.joined(separator: ".")
            let srv: SRVData = try take(service: service, proto: proto)
            return ResourceRecord(
                class: `class`,
                name: name,
                ttl: ttl,
                data: .srv(srv)
            )
        case .any:
            throw DNSParseError.invalidRecordType
        case .caa:
            let caa: CAAData = try take()
            return ResourceRecord(
                class: `class`,
                name: name.string,
                ttl: ttl,
                data: .caa(caa)
            )
        }
    }
}
