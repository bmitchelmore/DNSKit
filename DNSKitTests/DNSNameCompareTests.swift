//
//  DNSNameCompareTests.swift
//  DNSKitTests
//
//  Created by Blair Mitchelmore on 2020-05-04.
//  Copyright © 2020 Blair Mitchelmore. All rights reserved.
//

import XCTest
@testable import DNSKit

class DNSNameCompareTests: XCTestCase {
    func testSorting() {
        let expected = [
            "example",
            "a.example",
            "yljkjljk.a.example",
            "Z.a.example",
            "zABC.a.EXAMPLE",
            "z.example",
            "\u{1}.z.example",
            "*.z.example",
            "\u{200}.z.example"
        ]
        let unordered = Array(Set(expected))
        let sorted = unordered.sorted { DNSNameCompare($0, $1) == .orderedAscending }
        XCTAssertNotEqual(expected, unordered)
        XCTAssertEqual(expected, sorted)
    }
}
