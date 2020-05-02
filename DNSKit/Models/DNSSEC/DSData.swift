//
//  DSData.swift
//  DNSKit
//
//  Created by Blair Mitchelmore on 2020-05-02.
//  Copyright © 2020 Blair Mitchelmore. All rights reserved.
//

import Foundation

public struct DSData: Hashable {
    var tag: UInt16
    var alg: DNSSECAlgorithm
    var digest: DNSSECDigest
    var data: Data
}

extension DSData {
    var bytes: [UInt8] {
        return [
            tag.bytes,
            [alg.rawValue, digest.rawValue],
            data.map { $0 }
        ].flatMap { $0 }
    }
}

extension DataConsumer {
    mutating func take() throws -> DSData {
        try drop(2)
        let tag: UInt16 = try take()
        let alg: DNSSECAlgorithm = try take()
        let digest: DNSSECDigest = try take()
        let data = try take(digest.size)
        return DSData(
            tag: tag,
            alg: alg,
            digest: digest,
            data: data
        )
    }
}
