//
//  SOAData.swift
//  DNSKit
//
//  Created by Blair Mitchelmore on 2020-04-27.
//  Copyright © 2020 Blair Mitchelmore. All rights reserved.
//

import Foundation

public struct SOAData: Hashable {
    var mname: String
    var rname: String
    var serial: UInt32
    var refresh: UInt32
    var retry: UInt32
    var expire: UInt32
    var ttl: UInt32
}

extension SOAData {
    var bytes: [UInt8] {
        let bytes = [
            DNSString(mname).bytes,
            DNSString(rname).bytes,
            serial.bytes,
            refresh.bytes,
            retry.bytes,
            expire.bytes,
            ttl.bytes
        ].flatMap { $0 }
        return [
            UInt16(bytes.count).bytes,
            bytes
        ].flatMap { $0 }
    }
}

extension DataConsumer {
    mutating func take() throws -> SOAData {
        let len: UInt16 = try take()
        return try take(len) { consumer in
            let mname: DNSString = try consumer.take()
            let rname: DNSString = try consumer.take()
            let serial: UInt32 = try consumer.take()
            let refresh: UInt32 = try consumer.take()
            let retry: UInt32 = try consumer.take()
            let expire: UInt32 = try consumer.take()
            let ttl: UInt32 = try consumer.take()
            return SOAData(
                mname: mname.string,
                rname: rname.string,
                serial: serial,
                refresh: refresh,
                retry: retry,
                expire: expire,
                ttl: ttl
            )
        }
    }
}
