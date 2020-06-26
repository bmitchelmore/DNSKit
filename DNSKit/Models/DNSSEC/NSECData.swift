//
//  NSECData.swift
//  DNSKit
//
//  Created by Blair Mitchelmore on 2020-05-03.
//  Copyright © 2020 Blair Mitchelmore. All rights reserved.
//

import Foundation

public struct NSECData: Hashable {
    var name: String
    var types: Set<DNSRecordType>
}

extension NSECData {
    private func typesBytes() throws -> [UInt8] {
        var windows: [UInt8:Set<UInt8>] = [:]
        for type in DNSRecordType.allCases {
            guard types.contains(type) else { continue }
            let window = UInt8(type.rawValue >> 8)
            let bit = UInt8(type.rawValue & 0xff)
            windows[window] = windows[window] ?? []
            windows[window]?.insert(bit)
        }

        var bytes: [UInt8] = []
        let sorted = windows.sorted { $0.key < $1.key }
        for item in sorted {
            let window = item.key
            let bits = item.value
            bytes.append(window)
            guard let highest = bits.max() else {
                throw DNSError.invalidNSECBitmap
            }
            let size = UInt8(bits.count / 8)
            var package = [BytePackage](repeating: .bit(false), count: Int(size))
            for i in 0...highest {
                if bits.contains(i) {
                    package[Int(i)] = .bit(true)
                }
            }
            bytes.append(size)
            try bytes.append(contentsOf: package.bytes())
        }
        return bytes
    }
    func bytes() throws -> [UInt8] {
        return try [
            DNSString(name).bytes,
            typesBytes()
        ].flatMap { $0 }
    }
}

extension DataConsumer {
    mutating func take() throws -> NSECData {
        let len: UInt16 = try take()
        return try take(len) { consumer in
            let name: DNSString = try consumer.take()
            var types: Set<DNSRecordType> = []
            repeat {
                let window: UInt8 = try consumer.take()
                let size: UInt8 = try consumer.take()
                for i in 0..<size*8 {
                    let isSet: Bool = try consumer.take()
                    guard isSet else {
                        continue
                    }
                    let typeId: UInt16 = (UInt16(window) << 8) | UInt16(i)
                    guard let type = DNSRecordType(rawValue: typeId) else {
                        logger.warn("Unknown Record Type found in NSEC bitmask: \(typeId)")
                        continue
                    }
                    types.insert(type)
                }
            } while consumer.bytesRemaining != 0
            return NSECData(
                name: name.string,
                types: types
            )
        }
    }
}
