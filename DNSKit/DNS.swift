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
        self.query(query, validating: false, completion: completion)
    }

    public func query(_ query: QuestionSection, validating: Bool, completion: @escaping (Result<DNSResponse, Error>) -> Void) {
        if validating {
            let main = DNSRequest(validating: validating, query)
            let ds = DNSRequest(validating: validating, .ds(query.name))
            let group = DispatchGroup()
            var ar: Result<DNSResponse,Error>? = nil
            var dr: Result<DNSResponse,Error>? = nil

            group.enter()
            self.queue.schedule(main) { (result) in
                ar = result
                group.leave()
            }
            
            group.enter()
            self.queue.schedule(ds) { (result) in
                dr = result
                group.leave()
            }

            group.notify(queue: .main) {
                if let a = ar, let ds = dr {
                    print("A: \(a)")
                    print("DS: \(ds)")
                    completion(a)
                } else {
                    completion(.failure(DNSError.missingResponse))
                }
            }
        } else {
            let request = DNSRequest(query)
            self.queue.schedule(request, completion: completion)
        }
    }
}

public let dns: DNS = DNS(resolver: "1.1.1.1")

