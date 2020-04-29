//
//  CAAData.swift
//  DNSKit
//
//  Created by Blair Mitchelmore on 2020-04-28.
//  Copyright © 2020 Blair Mitchelmore. All rights reserved.
//

import Foundation

public struct CAAData: Hashable {
    var critical: Bool
    var tag: String
    var value: String
}

extension DataConsumer {
    mutating func take() throws -> CAAData {
        let len: UInt16 = try take()
        let critical: Bool = try take()
        let _: UInt8 = try take(bits: 7)
        let tlen: UInt8 = try take()
        guard tlen > 0 else {
            throw DNSParseError.invalidTagLength
        }
        if tlen > 15 {
            logger.warn("CAA Tag Length longer than RFC recommendations")
        }
        let tdat: Data = try take(tlen)
        let vdat: Data = try take(len - UInt16(tlen) - 2)
        guard let tag: String = String(data: tdat, encoding: .utf8) else {
            throw ConsumerError.invalidConversion
        }
        guard let value: String = String(data: vdat, encoding: .utf8) else {
            throw ConsumerError.invalidConversion
        }
        return CAAData(
            critical: critical,
            tag: tag,
            value: value
        )
    }
}
