//
//  DNSError.swift
//  DNSKit
//
//  Created by Blair Mitchelmore on 2020-04-23.
//  Copyright © 2020 Blair Mitchelmore. All rights reserved.
//

import Foundation

enum DNSError: Error {
    case timeout
    case missingResponse
    case invalidResponse
    case invalidAlgorithm
    case invalidDigest
}
