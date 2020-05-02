//
//  OPTData.swift
//  DNSKit
//
//  Created by Blair Mitchelmore on 2020-04-30.
//  Copyright © 2020 Blair Mitchelmore. All rights reserved.
//

import Foundation

public struct OPTData: Hashable {
    public var udp_size: UInt16
    public var ext_rcode: UInt8
    public var edns_version: UInt8
    public var dnssec_ok: Bool
    var z: UInt16
}

extension OPTData {
    func bytes() throws -> [UInt8] {
        let byte: [BytePackage] = [
            .bit(dnssec_ok),
            .bits16(value: z, count: 15)
        ]
        return try [
            udp_size.bytes,
            [ext_rcode, edns_version],
            byte.bytes(),
            UInt16(0).bytes
        ].flatMap { $0 }
    }
}
