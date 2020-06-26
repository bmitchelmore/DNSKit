//
//  LevelUpDNSName.swift
//  DNSKit
//
//  Created by Blair Mitchelmore on 2020-05-04.
//  Copyright © 2020 Blair Mitchelmore. All rights reserved.
//

import Foundation

func LevelUpDNSName(_ name: String) -> String {
    var components = name.split(separator: ".")
    guard components.count > 1 else {
        return ""
    }
    components.removeFirst()
    return components.joined(separator: ".")
}

