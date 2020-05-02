//
//  DNSSECPublicKey.swift
//  DNSKit
//
//  Created by Blair Mitchelmore on 2020-05-02.
//  Copyright © 2020 Blair Mitchelmore. All rights reserved.
//

import Foundation

enum DNSSECPublicKey: Hashable {
    case rsa(exp: Data, mod: Data)
    case ecdsa(x: Data, y: Data)
    case eddsa(Data)
}

extension DNSSECPublicKey {
    var bytes: [UInt8] {
        switch self {
        case .rsa(exp: let exp, mod: let mod):
            if exp.count < 256 {
                return [
                    [UInt8(exp.count)],
                    exp.map { $0 },
                    mod.map { $0 }
                ].flatMap { $0 }
            } else {
                return [
                    [UInt8(0)],
                    UInt16(exp.count).bytes,
                    exp.map { $0 },
                    mod.map { $0 }
                ].flatMap { $0 }
            }
        case .ecdsa(x: let x, y: let y):
            return [
                x.map { $0 },
                y.map { $0 }
            ].flatMap { $0 }
        case .eddsa(let data):
            return data.map { $0 }
        }
    }
}

extension DataConsumer {
    mutating func take(for alg: DNSSECAlgorithm) throws -> DNSSECPublicKey {
        switch alg {
        case .rsasha256, .rsasha512:
            let fb: UInt8 = try peek()
            if fb == 0 {
                try drop(1)
                let exp_len: UInt16 = try take()
                let exp: Data = try take(exp_len)
                let mod: Data = try take()
                return .rsa(exp: exp, mod: mod)
            } else {
                let exp_len: UInt8 = try take()
                let exp: Data = try take(exp_len)
                let mod: Data = try take()
                return .rsa(exp: exp, mod: mod)
            }
        case .ecdsasha256:
            let x: Data = try take(32)
            let y: Data = try take(32)
            return .ecdsa(x: x, y: y)
        case .ecdsasha384:
            let x: Data = try take(48)
            let y: Data = try take(48)
            return .ecdsa(x: x, y: y)
        case .ed25519:
            let data: Data = try take(32)
            return .eddsa(data)
        case .ed448:
            let data: Data = try take(57)
            return .eddsa(data)
        }
    }
}
