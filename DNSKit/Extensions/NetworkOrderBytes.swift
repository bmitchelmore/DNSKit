//
//  NetworkOrderBytes.swift
//  DNSKit
//
//  Created by Blair Mitchelmore on 2020-04-23.
//  Copyright © 2020 Blair Mitchelmore. All rights reserved.
//

import Foundation

struct OutOfBoundsError: Error {
    
}

extension UInt32 {
    init(networkBytes data: Data) throws {
        guard data.count >= 4 else {
            throw OutOfBoundsError()
        }
        let value = data.withUnsafeBytes { ptr in
            ptr.load(as: UInt32.self)
        }
        self = UInt32(bigEndian: value)
    }
}

extension UInt16 {
    init(networkBytes data: Data) throws {
        guard data.count >= 2 else {
            throw OutOfBoundsError()
        }
        let value = data.withUnsafeBytes { ptr in
            ptr.load(as: UInt16.self)
        }
        self = UInt16(bigEndian: value)
    }
}
