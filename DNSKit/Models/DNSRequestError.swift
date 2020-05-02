//
//  DNSRequestError.swift
//  DNSKit
//
//  Created by Blair Mitchelmore on 2020-04-30.
//  Copyright © 2020 Blair Mitchelmore. All rights reserved.
//

import Foundation

enum DNSRequestError: Error {
    case unknownType(UInt16)
    case invalidTag
    case invalidValue
}

