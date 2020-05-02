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

    init(validating: Bool = false, _ questions: QuestionSection...) {
        self.questions = Set(questions)
        self.answers = []
        self.authority = []
        if validating {
            let opt = OPTData(
                udp_size: 4096,
                ext_rcode: 0,
                edns_version: 0,
                dnssec_ok: true,
                z: 0
            )
            self.additional = [
                ResourceRecord(
                    class: .in,
                    name: "",
                    ttl: 0,
                    data: .opt(opt)
                )
            ]
        } else {
            self.additional = []
        }
        self.header = DNSHeader(
            id: .random(),
            qr: false,
            opcode: 0,
            aa: false,
            tc: false,
            rd: true,
            ra: false,
            z: false,
            ad: false,
            cd: false,
            rcode: 0,
            qdcount: UInt16(questions.count),
            ancount: 0,
            nscount: 0,
            arcount: UInt16(additional.count)
        )
    }
}

extension DNSRequest {
    func bytes() throws -> [UInt8] {
        return try [
            header.bytes(),
            questions.map {
                $0.bytes
            }.flatMap { $0 },
            additional.map {
                try $0.bytes()
            }.flatMap { $0 }
        ].flatMap { $0 }
    }
}
