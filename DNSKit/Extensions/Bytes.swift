//
//  Bytes.swift
//  DNSKit
//
//  Created by Blair Mitchelmore on 2020-04-23.
//  Copyright © 2020 Blair Mitchelmore. All rights reserved.
//

import Foundation

extension DataProtocol {
    var bytes: [UInt8] {
        return map { $0 }
    }
}

extension UInt8 {
    var bits: [Bool] {
        var bits = [Bool](repeating: false, count: 8)
        var value = self
        for i in 0...7 {
            bits[7-i] = (value & 0x1) == 0x1
            value >>= 1
        }
        return bits
    }
}

extension UInt16 {
    var bits: [Bool] {
        return bytes.flatMap { $0.bits }
    }
    var bytes: [UInt8] {
        return stride(from: 8, through: 0, by: -8).map {
            UInt8(truncatingIfNeeded: self >> UInt16($0))
        }
    }
}

extension UInt32 {
    var bytes: [UInt8] {
        return stride(from: 24, through: 0, by: -8).map {
            UInt8(truncatingIfNeeded: self >> UInt32($0))
        }
    }
}
