//
//  SRVData.swift
//  DNSKit
//
//  Created by Blair Mitchelmore on 2020-04-29.
//  Copyright © 2020 Blair Mitchelmore. All rights reserved.
//

import Foundation

public struct SRVData: Hashable {
    var service: SRVService
    var proto: SRVProto
    var priority: UInt16
    var weight: UInt16
    var port: UInt16
    var target: String
}

extension SRVData {
    var bytes: [UInt8] {
        let bytes = [
            priority.bytes,
            weight.bytes,
            port.bytes,
            DNSString(target).bytes
        ].flatMap { $0 }
        return [
            UInt16(bytes.count).bytes,
            bytes
        ].flatMap { $0 }
    }
}

extension DataConsumer {
    mutating func take(service: SRVService, proto: SRVProto) throws -> SRVData {
        let _: UInt16 = try take()
        let priority: UInt16 = try take()
        let weight: UInt16 = try take()
        let port: UInt16 = try take()
        let target: DNSString = try take()
        return SRVData(
            service: service,
            proto: proto,
            priority: priority,
            weight: weight,
            port: port,
            target: target.string
        )
    }
}
