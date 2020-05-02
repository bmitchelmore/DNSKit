//
//  Bytes.swift
//  DNSKit
//
//  Created by Blair Mitchelmore on 2020-04-23.
//  Copyright © 2020 Blair Mitchelmore. All rights reserved.
//

import Foundation

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

extension TXTRecord {
    var bytes: [UInt8] {
        guard let bytes = string.data(using: .utf8) else {
            return [ 0x00 ]
        }
        let count = UInt8(bytes.count)
        return [ count ] + [UInt8](bytes)
    }
}

extension DNSString {
    var bytes: [UInt8] {
        let components = string.split(separator: ".")
        return components.flatMap { component -> [UInt8] in
            guard let bytes = component.data(using: .utf8) else {
                return []
            }
            let count = UInt8(bytes.count)
            return [ count ] + [UInt8](bytes)
        } + [0x00]
    }
}

