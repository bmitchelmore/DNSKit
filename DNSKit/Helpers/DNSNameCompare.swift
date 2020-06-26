//
//  DNSNameCompare.swift
//  DNSKit
//
//  Created by Blair Mitchelmore on 2020-05-04.
//  Copyright © 2020 Blair Mitchelmore. All rights reserved.
//

import Foundation

func DNSNameCompare(_ a: String, _ b: String) -> ComparisonResult {
    let ac = a.split(separator: ".").reversed().map { $0 }
    let bc = b.split(separator: ".").reversed().map { $0 }
    for i in 0..<max(ac.count, bc.count) {
        guard ac.indices.contains(i) else {
            return .orderedAscending
        }
        guard bc.indices.contains(i) else {
            return .orderedDescending
        }
        let ap = ac[i]
        let bp = bc[i]
        let cmp = ap.lowercased().compare(bp.lowercased())
        switch cmp {
        case .orderedAscending, .orderedDescending:
            return cmp
        case .orderedSame:
            break
        }
    }
    return .orderedSame
}

