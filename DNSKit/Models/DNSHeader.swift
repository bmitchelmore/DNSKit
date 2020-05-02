//
//  DNSHeader.swift
//  DNSKit
//
//  Created by Blair Mitchelmore on 2020-04-27.
//  Copyright © 2020 Blair Mitchelmore. All rights reserved.
//

import Foundation

struct DNSHeader {
    let id: UInt16
    let qr: Bool
    let opcode: UInt8 // 4 bits
    let aa: Bool
    let tc: Bool
    let rd: Bool
    let ra: Bool
    let z: Bool
    let ad: Bool
    let cd: Bool
    let rcode: UInt8 // 4 bits
    let qdcount: UInt16
    let ancount: UInt16
    let nscount: UInt16
    let arcount: UInt16
}

extension DNSHeader {
    var headerBits: [BytePackage] {
        return [
            .bit(qr),
            .bits(value: opcode, count: 4),
            .bit(aa),
            .bit(tc),
            .bit(rd),
            .bit(ra),
            .bit(z),
            .bit(ad),
            .bit(cd),
            .bits(value: rcode, count: 4)
        ]
    }
    func bytes() throws -> [UInt8] {
        return [
            id.bytes,
            try headerBits.bytes(),
            qdcount.bytes,
            ancount.bytes,
            nscount.bytes,
            arcount.bytes
        ].flatMap { $0 }
    }
}

extension DataConsumer {
    mutating func take() throws -> DNSHeader {
        let id: UInt16 = try take()
        do {
            let qr: Bool = try take()
            let opcode: UInt8 = try take(bits: 4)
            let aa: Bool = try take()
            let tc: Bool = try take()
            let rd: Bool = try take()
            let ra: Bool = try take()
            let z: Bool = try take()
            let ad: Bool = try take()
            let cd: Bool = try take()
            let rcode: UInt8 = try take(bits: 4)
            let qdcount: UInt16 = try take()
            let ancount: UInt16 = try take()
            let nscount: UInt16 = try take()
            let arcount: UInt16 = try take()
            return DNSHeader(
                id: id,
                qr: qr,
                opcode: opcode,
                aa: aa,
                tc: tc,
                rd: rd,
                ra: ra,
                z: z,
                ad: ad,
                cd: cd,
                rcode: rcode,
                qdcount: qdcount,
                ancount: ancount,
                nscount: nscount,
                arcount: arcount
            )
        } catch {
            throw DNSParseError.invalidResponse(id, error)
        }
    }
}
