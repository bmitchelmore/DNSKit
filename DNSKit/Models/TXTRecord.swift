//
//  TXTRecord.swift
//  DNSKit
//
//  Created by Blair Mitchelmore on 2020-04-27.
//  Copyright © 2020 Blair Mitchelmore. All rights reserved.
//

import Foundation

struct TXTRecord {
    var string: String

    init(_ value: String) {
        string = value
    }
}

extension DataConsumer {
    mutating func take() throws -> TXTRecord {
        let len: UInt8 = try take()
        let bytes: Data = try take(len)
        guard let str = String(bytes: bytes, encoding: .utf8) else {
            throw ConsumerError.invalidConversion
        }
        return TXTRecord(str)
    }
}
