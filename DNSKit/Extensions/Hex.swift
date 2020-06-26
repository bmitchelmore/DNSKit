//
//  Hex.swift
//  DNSKit
//
//  Created by Blair Mitchelmore on 2020-04-23.
//  Copyright © 2020 Blair Mitchelmore. All rights reserved.
//

import Foundation

private let hexDigits = Array(Array("0123456789abcdef".utf16)[0...])
extension DataProtocol {
    var hex: String {
        var chars: [Unicode.UTF16.CodeUnit] = []
        chars.reserveCapacity(2 * count)
        for byte in self {
            chars.append(hexDigits[Int(byte >> 4)])
            chars.append(hexDigits[Int(byte & 15)])
        }
        return String(utf16CodeUnits: chars, count: chars.count)
    }
}

extension UInt8 {
    var hex: String {
        var chars: [Unicode.UTF16.CodeUnit] = []
        chars.reserveCapacity(2)
        chars.append(hexDigits[Int(self >> 4)])
        chars.append(hexDigits[Int(self & 15)])
        return String(utf16CodeUnits: chars, count: chars.count)
    }
}

extension UInt16 {
    var hex: String {
        var chars: [Unicode.UTF16.CodeUnit] = []
        chars.reserveCapacity(4)
        for byte in bytes {
            chars.append(hexDigits[Int(byte >> 4)])
            chars.append(hexDigits[Int(byte & 15)])
        }
        return String(utf16CodeUnits: chars, count: chars.count)
    }
}

extension UInt32 {
    var hex: String {
        var chars: [Unicode.UTF16.CodeUnit] = []
        chars.reserveCapacity(8)
        for byte in bytes {
            chars.append(hexDigits[Int(byte >> 4)])
            chars.append(hexDigits[Int(byte & 15)])
        }
        return String(utf16CodeUnits: chars, count: chars.count)
    }
}
