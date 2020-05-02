//
//  DNSRecordType.swift
//  DNSKit
//
//  Created by Blair Mitchelmore on 2020-04-27.
//  Copyright © 2020 Blair Mitchelmore. All rights reserved.
//

import Foundation

public enum DNSRecordType: UInt16, Hashable {
    case a = 1
    case ns = 2
    case cname = 5
    case soa = 6
    case ptr = 12
    case mx = 15
    case txt = 16
    case aaaa = 28
    case srv = 33
    case opt = 41
    case ds = 43
    case rrsig = 46
    case dnskey = 48
    case any = 255
    case caa = 257
}

extension DataConsumer {
    mutating func take() throws -> DNSRecordType {
        return try self.take(or: DNSError.invalidResponse) { DNSRecordType(rawValue: $0) }
    }
}
