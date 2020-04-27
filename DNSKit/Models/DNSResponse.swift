//
//  DNSResponse.swift
//  DNSKit
//
//  Created by Blair Mitchelmore on 2020-04-27.
//  Copyright © 2020 Blair Mitchelmore. All rights reserved.
//

import Foundation

public struct DNSResponse {
    let header: DNSHeader
    let questions: Set<QuestionSection>
    public let answers: Set<ResourceRecord>
    let authority: Set<ResourceRecord>
    let additional: Set<ResourceRecord>
}

extension DataConsumer {
    mutating func take() throws -> DNSResponse {
        let header: DNSHeader = try take()
        do {

            let questions: [QuestionSection] = try (0..<header.qdcount).map { _ in
                return try take()
            }

            let answers: [ResourceRecord] = try (0..<header.ancount).map { _ in
                return try take()
            }

            let authority: [ResourceRecord] = try (0..<header.nscount).map { _ in
                return try take()
            }

            let additional: [ResourceRecord] = try (0..<header.arcount).map { _ in
                return try take()
            }

            return DNSResponse(
                header: header,
                questions: Set(questions),
                answers: Set(answers),
                authority: Set(authority),
                additional: Set(additional)
            )
        } catch {
            throw DNSParseError.invalidResponse(header.id, error)
        }
    }
}
