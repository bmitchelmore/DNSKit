//
//  DNSParseError.swift
//  DNSKit
//
//  Created by Blair Mitchelmore on 2020-04-27.
//  Copyright © 2020 Blair Mitchelmore. All rights reserved.
//

import Foundation

enum DNSParseError: Error {
    case invalidResponse(UInt16, Error)
    case unknownService(String)
    case unknownProto(String)
    case invalidRecordType
    case invalidTagLength
    case optValuesNotSupported
    case invalidAlgorithm
    case invalidWindow
}
