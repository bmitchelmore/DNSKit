//
//  DNSSECDigest.swift
//  DNSKit
//
//  Created by Blair Mitchelmore on 2020-05-02.
//  Copyright © 2020 Blair Mitchelmore. All rights reserved.
//

import Foundation

enum DNSSECDigest: UInt8, Hashable {
    case sha1 = 1
    case sha256 = 2
}

extension DNSSECDigest {
    var size: UInt8 {
        switch self {
        case .sha1: return 20
        case .sha256: return 32
        }
    }
}

extension DataConsumer {
    mutating func take() throws -> DNSSECDigest {
        return try self.take(or: DNSError.invalidDigest) { DNSSECDigest(rawValue: $0) }
    }
}
