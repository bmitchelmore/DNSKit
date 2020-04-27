//
//  DNSString.swift
//  DNSKit
//
//  Created by Blair Mitchelmore on 2020-04-27.
//  Copyright © 2020 Blair Mitchelmore. All rights reserved.
//

import Foundation

struct DNSString {
    var string: String

    init(_ value: String) {
        string = value
    }
}

extension DataConsumer {
    mutating func take() throws -> DNSString {
        var segments: [String] = []
        var reading = true
        while reading {
            let head: UInt8 = try peek()
            switch head & 0xc0 {
            case 0xc0: // pointer
                let value: UInt16 = try take()
                let offset = Int(value & 0x3fff)
                var reader = try spinoff(at: offset)
                let segment: DNSString = try reader.take()
                segments.append(segment.string)
                reading = false
            default: // regular
                try drop(1)
                if head == 0 {
                    reading = false
                } else {
                    let len = head
                    let bytes: Data = try take(len)
                    guard let segment = String(bytes: bytes, encoding: .utf8) else {
                        throw ConsumerError.invalidConversion
                    }
                    segments.append(segment)
                }
                guard head > 0 else {
                    reading = false
                    break
                }
            }
        }
        let joined = segments.joined(separator: ".")
        return DNSString(joined)
    }
}
