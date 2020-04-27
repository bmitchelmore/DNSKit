//
//  SOAData.swift
//  DNSKit
//
//  Created by Blair Mitchelmore on 2020-04-27.
//  Copyright © 2020 Blair Mitchelmore. All rights reserved.
//

import Foundation

public struct SOAData: Hashable {
    var mname: String
    var rname: String
    var serial: UInt32
    var refresh: UInt32
    var retry: UInt32
    var expire: UInt32
}

extension DataConsumer {
    mutating func take() throws -> SOAData {
        let mname: DNSString = try take()
        let rname: DNSString = try take()
        let serial: UInt32 = try take()
        let refresh: UInt32 = try take()
        let retry: UInt32 = try take()
        let expire: UInt32 = try take()
        return SOAData(
            mname: mname.string,
            rname: rname.string,
            serial: serial,
            refresh: refresh,
            retry: retry,
            expire: expire
        )
    }
}
