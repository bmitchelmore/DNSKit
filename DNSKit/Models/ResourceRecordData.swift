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
        case .unknown: preconditionFailure("Invalid Record Type")
        }
    }
}
