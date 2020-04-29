//
//  SRVData.swift
//  DNSKit
//
//  Created by Blair Mitchelmore on 2020-04-29.
//  Copyright © 2020 Blair Mitchelmore. All rights reserved.
//

import Foundation

public struct SRVData: Hashable {
    var service: String
    var proto: String
    var priority: UInt16
    var weight: UInt16
    var port: UInt16
    var target: String
}

extension DataConsumer {
    mutating func take(service: String, proto: String) throws -> SRVData {
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
