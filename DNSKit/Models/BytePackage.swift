//
//  BytePackage.swift
//  DNSKit
//
//  Created by Blair Mitchelmore on 2020-04-27.
//  Copyright © 2020 Blair Mitchelmore. All rights reserved.
//

import Foundation

enum BytePackageError: Error {
    case invalidBitOffset
}

enum BytePackage {
    case bit(Bool)
    case bits(value: UInt8, count: UInt8)
    case bits16(value: UInt16, count: UInt8)
}

extension Array where Element == BytePackage {
    func bytes() throws -> [UInt8] {
        var bytes: [UInt8] = []
        var offset: UInt8 = 0
        var byte: UInt8 = 0
        for item in self {
            switch item {
            case .bit(let value):
                byte <<= 1
                byte |= (value == true ? 1 : 0)
                offset += 1
                if offset == 8 {
                    bytes.append(byte)
                    offset = 0
                }
            case .bits(value: let value, count: let count):
                for bit in value.bits[(8-Int(count))...] {
                    byte <<= 1
                    byte |= UInt8(bit == true ? 1 : 0)
                    offset += 1
                    if offset == 8 {
                        bytes.append(byte)
                        byte = 0
                        offset = 0
                    }
                }
            case .bits16(value: let value, count: let count):
                for bit in value.bits[(16-Int(count))...] {
                    byte <<= 1
                    byte |= UInt8(bit == true ? 1 : 0)
                    offset += 1
                    if offset == 8 {
                        bytes.append(byte)
                        byte = 0
                        offset = 0
                    }
                }
            }
        }
        if offset != 0 {
            throw BytePackageError.invalidBitOffset
        }
        return bytes
    }
}
