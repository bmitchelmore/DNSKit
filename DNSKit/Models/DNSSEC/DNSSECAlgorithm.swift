//
//  DNSSECAlgorithm.swift
//  DNSKit
//
//  Created by Blair Mitchelmore on 2020-05-01.
//  Copyright © 2020 Blair Mitchelmore. All rights reserved.
//

import Foundation

enum DNSSECAlgorithm: UInt8, Hashable {
    case rsasha256 = 8 // exp_len | exp | modulus
    case rsasha512 = 10 // exp_len | exp | modulus
    case ecdsasha256 = 13 // 2 32 bytes public key
    case ecdsasha384 = 14 // 2 48 bytes public key
    case ed25519 = 15 // 32 bytes public key
    case ed448 = 16 // 57 bytes public key
}

extension DataConsumer {
    mutating func take() throws -> DNSSECAlgorithm {
        return try self.take(or: DNSError.invalidAlgorithm) { DNSSECAlgorithm(rawValue: $0) }
    }
}
