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

extension ResourceRecord {
    func bytes() throws -> [UInt8] {
        if case .opt(let opt) = data {
            return try [
                DNSString(name).bytes,
                data.type.rawValue.bytes,
                opt.bytes()
            ].flatMap { $0 }
        } else if case .srv(let srv) = data {
            let combined = [
                srv.service.rawValue,
                srv.proto.rawValue,
                name
            ].joined(separator: ".")
            return [
                DNSString(combined).bytes,
                data.type.rawValue.bytes,
                `class`.rawValue.bytes,
                ttl.bytes,
                srv.bytes
            ].flatMap { $0 }
        } else {
            return try [
                DNSString(name).bytes,
                data.type.rawValue.bytes,
                `class`.rawValue.bytes,
                ttl.bytes,
                data.bytes()
            ].flatMap { $0 }
        }
    }
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
        guard let type = DNSRecordType(rawValue: typeId) else {
            let `class`: DNSRecordClass = try take()
            let ttl: UInt32 = try take()
            let len: UInt16 = try take()
            try drop(len)
            return ResourceRecord(
                class: `class`,
                name: name.string,
                ttl: ttl,
                data: .unknown(typeId)
            )
        }
        if type == .opt {
            // OPT records are a special case
            // that has a weird binary format
            // so we parse it specially here
            let udp_size: UInt16 = try take()
            let ext_rcode: UInt8 = try take()
            let edns_version: UInt8 = try take()
            let dnssec_ok: Bool = try take()
            let z: UInt16 = try take(bits: 15)
            let len: UInt16 = try take()
            if len > 0 {
                throw DNSParseError.optValuesNotSupported
            }
            let opt = OPTData(
                udp_size: udp_size,
                ext_rcode: ext_rcode,
                edns_version: edns_version,
                dnssec_ok: dnssec_ok,
                z: z
            )
            return ResourceRecord(
                class: .in, // hardcode to `in`
                name: name.string,
                ttl: 0, // hardcode to 0
                data: .opt(opt)
            )
        }
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
        case .ptr:
            try drop(2)
            let ptr: DNSString = try take()
            return ResourceRecord(
                class: `class`,
                name: name.string,
                ttl: ttl,
                data: .ptr(ptr.string)
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
            let service_str = components.removeFirst()
            let proto_str = components.removeFirst()
            let name = components.joined(separator: ".")
            guard let service = SRVService(rawValue: service_str) else {
                throw DNSParseError.unknownService(service_str)
            }
            guard let proto = SRVProto(rawValue: proto_str) else {
                throw DNSParseError.unknownProto(proto_str)
            }
            let srv: SRVData = try take(service: service, proto: proto)
            return ResourceRecord(
                class: `class`,
                name: name,
                ttl: ttl,
                data: .srv(srv)
            )
        case .ds:
            let ds: DSData = try take()
            return ResourceRecord(
                class: `class`,
                name: name.string,
                ttl: ttl,
                data: .ds(ds)
            )
        case .rrsig:
            let rrsig: RRSIGData = try take()
            return ResourceRecord(
                class: `class`,
                name: name.string,
                ttl: ttl,
                data: .rrsig(rrsig)
            )
        case .dnskey:
            let dnskey: DNSKEYData = try take()
            return ResourceRecord(
                class: `class`,
                name: name.string,
                ttl: ttl,
                data: .dnskey(dnskey)
            )
        case .opt:
            throw DNSParseError.invalidRecordType
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
