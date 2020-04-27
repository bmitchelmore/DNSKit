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
    case soa = 6
    case txt = 16
    case aaaa = 28
}

extension DataConsumer {
    mutating func take() throws -> DNSRecordType {
        return try self.take(or: DNSError.invalidResponse) { DNSRecordType(rawValue: $0) }
    }
}