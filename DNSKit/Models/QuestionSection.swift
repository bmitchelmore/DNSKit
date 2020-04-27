//
//  QuestionSection.swift
//  DNSKit
//
//  Created by Blair Mitchelmore on 2020-04-27.
//  Copyright © 2020 Blair Mitchelmore. All rights reserved.
//

import Foundation

public struct QuestionSection: Hashable {
    let `class`: DNSRecordClass
    let type: DNSRecordType
    let name: String
}

extension QuestionSection {
    public static func a(_ name: String) -> QuestionSection {
        return QuestionSection(
            class: .in,
            type: .a,
            name: name
        )
    }
    public static func ns(_ name: String) -> QuestionSection {
        return QuestionSection(
            class: .in,
            type: .ns,
            name: name
        )
    }
    public static func txt(_ name: String) -> QuestionSection {
        return QuestionSection(
            class: .in,
            type: .txt,
            name: name
        )
    }
    public static func aaaa(_ name: String) -> QuestionSection {
        return QuestionSection(
            class: .in,
            type: .aaaa,
            name: name
        )
    }
}

extension QuestionSection {
    var bytes: [UInt8] {
        return [
            name.bytes,
            type.rawValue.bytes,
            `class`.rawValue.bytes
        ].flatMap { $0 }
    }
}

extension DataConsumer {
    mutating func take() throws -> QuestionSection {
        let name: DNSString = try take()
        let type: DNSRecordType = try take()
        let `class`: DNSRecordClass = try take()
        return QuestionSection(
            class: `class`,
            type: type,
            name: name.string
        )
    }
}
