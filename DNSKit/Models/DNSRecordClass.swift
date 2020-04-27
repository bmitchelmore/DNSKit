//
//  DNSRecordClass.swift
//  DNSKit
//
//  Created by Blair Mitchelmore on 2020-04-27.
//  Copyright © 2020 Blair Mitchelmore. All rights reserved.
//

import Foundation

public enum DNSRecordClass: UInt16, Hashable {
   case `in` = 1
}

extension DataConsumer {
    mutating func take() throws -> DNSRecordClass {
        return try self.take(or: DNSError.invalidResponse) { DNSRecordClass(rawValue: $0) }
    }
}
