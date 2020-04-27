//
//  Bytes.swift
//  DNSKit
//
//  Created by Blair Mitchelmore on 2020-04-23.
//  Copyright © 2020 Blair Mitchelmore. All rights reserved.
//

import Foundation

extension UInt16 {
    var bytes: [UInt8] {
        return stride(from: 8, through: 0, by: -8).map {
            UInt8(truncatingIfNeeded: self >> UInt16($0))
        }
    }
}

extension UInt32 {
    var bytes: [UInt8] {
        return stride(from: 24, through: 0, by: -8).map {
            UInt8(truncatingIfNeeded: self >> UInt32($0))
        }
    }
}

extension String {
    var bytes: [UInt8] {
        let components = split(separator: ".")
        return components.flatMap { component -> [UInt8] in
            guard let bytes = component.data(using: .utf8) else {
                return []
            }
            let count = UInt8(bytes.count)
            return [ count ] + [UInt8](bytes)
        } + [0x00]
    }
}

