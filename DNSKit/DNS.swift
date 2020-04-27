//
//  DNSKit.swift
//  DNSKit
//
//  Created by Blair Mitchelmore on 2020-04-22.
//  Copyright © 2020 Blair Mitchelmore. All rights reserved.
//

import Foundation
import Network

public final class DNS {
    private var queue: DNSQueue

    init(resolver: String) {
        self.queue = DNSQueue(resolver: .hostPort(host: NWEndpoint.Host(resolver), port: 53))
    }

    public func use(_ resolver: String) {
        self.queue = DNSQueue(resolver: .hostPort(host: NWEndpoint.Host(resolver), port: 53))
    }

    public func query(_ query: QuestionSection, completion: @escaping (Result<DNSResponse, Error>) -> Void) {
        self.queue.schedule(DNSRequest(query), completion: completion)
    }
}

public let dns: DNS = DNS(resolver: "1.1.1.1")

