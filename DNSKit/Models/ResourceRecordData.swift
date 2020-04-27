//
//  ResourceRecordData.swift
//  DNSKit
//
//  Created by Blair Mitchelmore on 2020-04-27.
//  Copyright © 2020 Blair Mitchelmore. All rights reserved.
//

import Foundation
import Network

public enum ResourceRecordData: Hashable {
    case a(IPv4Address)
    case ns(String)
    case soa(SOAData)
    case txt(String)
    case aaaa(IPv6Address)
}
