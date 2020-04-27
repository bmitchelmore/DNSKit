//
//  Random.swift
//  DNSKit
//
//  Created by Blair Mitchelmore on 2020-04-23.
//  Copyright © 2020 Blair Mitchelmore. All rights reserved.
//

import Foundation

extension UInt16 {
    static func random() -> UInt16 {
        return random(in: 0...UInt16.max)
    }
}
