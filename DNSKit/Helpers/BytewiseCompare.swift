//
//  BytewiseCompare.swift
//  DNSKit
//
//  Created by Blair Mitchelmore on 2020-05-04.
//  Copyright © 2020 Blair Mitchelmore. All rights reserved.
//

import Foundation

func BytewiseCompare(_ a: [UInt8], _ b: [UInt8]) -> ComparisonResult {
    for i in 0..<max(a.count, b.count) {
        guard i < a.count else {
            return .orderedAscending
        }
        guard i < b.count else {
            return .orderedDescending
        }
        let ai = a[i]
        let bi = b[i]
        if ai < bi {
            return .orderedAscending
        } else if ai > bi {
            return .orderedDescending
        }
    }
    return .orderedSame
}
