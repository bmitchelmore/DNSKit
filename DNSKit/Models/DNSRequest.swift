//
//  DNSRequest.swift
//  DNSKit
//
//  Created by Blair Mitchelmore on 2020-04-27.
//  Copyright © 2020 Blair Mitchelmore. All rights reserved.
//

import Foundation

struct DNSRequest {
    let header: DNSHeader
    let questions: Set<QuestionSection>
    let answers: Set<ResourceRecord>
    let authority: Set<ResourceRecord>
    let additional: Set<ResourceRecord>

    init(_ questions: QuestionSection...) {
        self.header = DNSHeader(
            id: .random(),
            qr: false,
            opcode: 0,
            aa: false,
            tc: false,
            rd: true,
            ra: false,
            z: 0,
            rcode: 0,
            qdcount: UInt16(questions.count),
            ancount: 0,
            nscount: 0,
            arcount: 0
        )
        self.questions = Set(questions)
        self.answers = []
        self.authority = []
        self.additional = []
    }
}

extension DNSRequest {
    func bytes() throws -> [UInt8] {
        return [
            try header.bytes(),
            questions.map {
                $0.bytes
            }.flatMap { $0 }
        ].flatMap { $0 }
    }
}
