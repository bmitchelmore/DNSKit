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

extension CAAData {
    func bytes() throws -> [UInt8] {
        let byte: [BytePackage] = [
            .bit(critical),
            .bits(value: 0, count: 7)
        ]
        guard let tdata = tag.data(using: .utf8) else {
            throw DNSRequestError.invalidTag
        }
        guard let vdata = value.data(using: .utf8) else {
            throw DNSRequestError.invalidValue
        }

        let tbytes = tdata.map { $0 }
        let vbytes = vdata.map { $0 }
        let bytes = try [
            byte.bytes(),
            [UInt8(tbytes.count)],
            tbytes,
            vbytes
        ].flatMap { $0 }
        return [
            UInt16(bytes.count).bytes,
            bytes
        ].flatMap { $0 }
    }
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
