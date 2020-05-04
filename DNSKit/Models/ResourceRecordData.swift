//
//  ResourceRecordData.swift
//  DNSKit
//
//  Created by Blair Mitchelmore on 2020-04-27.
//  Copyright © 2020 Blair Mitchelmore. All rights reserved.
//

import Foundation
import Network

public enum ResourceRecordData: Hashable {
    case a(IPv4Address)
    case ns(String)
    case cname(String)
    case soa(SOAData)
    case ptr(String)
    case mx(UInt16, String)
    case txt(String)
    case aaaa(IPv6Address)
    case caa(CAAData)
    case srv(SRVData)
    case opt(OPTData)
    case ds(DSData)
    case nsec(NSECData)
    case rrsig(RRSIGData)
    case dnskey(DNSKEYData)
    case unknown(UInt16)
}

extension ResourceRecordData {
    var type: DNSRecordType {
        switch self {
        case .a: return .a
        case .aaaa: return .aaaa
        case .caa: return .caa
        case .cname: return .cname
        case .mx: return .mx
        case .ns: return .ns
        case .soa: return .soa
        case .ptr: return .ptr
        case .txt: return .txt
        case .srv: return .srv
        case .opt: return .opt
        case .ds: return .ds
        case .nsec: return .nsec
        case .rrsig: return .rrsig
        case .dnskey: return .dnskey
        case .unknown: preconditionFailure("Invalid Record Type")
        }
    }
}

extension ResourceRecordData {
    func bytes() throws -> [UInt8] {
        switch self {
        case .a(let addr):
            return [
                UInt16(addr.rawValue.count).bytes,
                addr.rawValue.map { $0 }
            ].flatMap { $0 }
        case .aaaa(let addr):
            return [
                UInt16(addr.rawValue.count).bytes,
                addr.rawValue.map { $0 }
            ].flatMap { $0 }
        case .caa(let data):
            return try data.bytes()
        case .cname(let str):
            let bytes = DNSString(str).bytes
            return [
                UInt16(bytes.count).bytes,
                bytes
            ].flatMap { $0 }
        case .mx(let pref, let str):
            let bytes = [
                pref.bytes,
                DNSString(str).bytes
            ].flatMap { $0 }
            return [
                UInt16(bytes.count).bytes,
                bytes
            ].flatMap { $0 }
        case .ns(let str):
            let bytes = DNSString(str).bytes
            return [
                UInt16(bytes.count).bytes,
                bytes
            ].flatMap { $0 }
        case .opt(let data):
            return try data.bytes()
        case .ptr(let str):
            let bytes = DNSString(str).bytes
            return [
                UInt16(bytes.count).bytes,
                bytes
            ].flatMap { $0 }
        case .soa(let data):
            return data.bytes
        case .srv(let data):
            return data.bytes
        case .txt(let str):
            return TXTRecord(str).bytes
        case .rrsig(let data):
            return data.bytes
        case .nsec(let data):
            return try data.bytes()
        case .ds(let data):
            return data.bytes
        case .dnskey(let data):
            return try data.bytes()
        case .unknown(let type):
            throw DNSRequestError.unknownType(type)
        }

    }
}
