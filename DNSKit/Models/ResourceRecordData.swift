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
    var a: IPv4Address? {
        if case .a(let data) = self {
            return data
        }
        return nil
    }
    var ns: String? {
        if case .ns(let data) = self {
            return data
        }
        return nil
    }
    var cname: String? {
        if case .cname(let data) = self {
            return data
        }
        return nil
    }
    var soa: SOAData? {
        if case .soa(let data) = self {
            return data
        }
        return nil
    }
    var ptr: String? {
        if case .ptr(let data) = self {
            return data
        }
        return nil
    }
    var mx: (UInt16, String)? {
        if case .mx(let a, let b) = self {
            return (a, b)
        }
        return nil
    }
    var txt: String? {
        if case .txt(let data) = self {
            return data
        }
        return nil
    }
    var aaaa: IPv6Address? {
        if case .aaaa(let data) = self {
            return data
        }
        return nil
    }
    var caa: CAAData? {
        if case .caa(let data) = self {
            return data
        }
        return nil
    }
    var srv: SRVData? {
        if case .srv(let data) = self {
            return data
        }
        return nil
    }
    var opt: OPTData? {
        if case .opt(let data) = self {
            return data
        }
        return nil
    }
    var ds: DSData? {
        if case .ds(let data) = self {
            return data
        }
        return nil
    }
    var nsec: NSECData? {
        if case .nsec(let data) = self {
            return data
        }
        return nil
    }
    var rrsig: RRSIGData? {
        if case .rrsig(let data) = self {
            return data
        }
        return nil
    }
    var dnskey: DNSKEYData? {
        if case .dnskey(let data) = self {
            return data
        }
        return nil
    }
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
    func rdata() throws -> [UInt8] {
        switch self {
        case .a(let addr):
            return addr.rawValue.map { $0 }
        case .aaaa(let addr):
            return addr.rawValue.map { $0 }
        case .caa(let data):
            return try data.bytes()
        case .cname(let str):
            return DNSString(str).bytes
        case .mx(let pref, let str):
            return [
                pref.bytes,
                DNSString(str).bytes
            ].flatMap { $0 }
        case .ns(let str):
            return DNSString(str).bytes
        case .opt(let data):
            return try data.bytes()
        case .ptr(let str):
            return DNSString(str).bytes
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
    func bytes() throws -> [UInt8] {
        let data = try rdata()
        return [
            UInt16(data.count).bytes,
            data
        ].flatMap { $0 }
    }
}
