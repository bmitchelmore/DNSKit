//
//  main.swift
//  DNSLookup
//
//  Created by Blair Mitchelmore on 2020-04-27.
//  Copyright © 2020 Blair Mitchelmore. All rights reserved.
//

import Foundation
import Darwin
import DNSKit
import Network

// Simple example usage of DNSKit

let group = DispatchGroup()

func query(_ question: QuestionSection, validating: Bool = false, completion: @escaping (Result<DNSResponse,Error>) -> Void) {
    group.enter()
    dns.query(question, validating: validating) { (result) in
        completion(result)
        group.leave()
    }
}

func log(_ message: String, _ result: Result<DNSResponse,Error>) {
    switch result {
    case .success(let response):
        print("\(message): \(Array(response.answers.map({$0.data})))")
    case .failure(let error):
        print("\(message): \(error)")
    }
}

func wait() {
    group.notify(queue: .main) {
        exit(0)
    }

    RunLoop.current.run()
}

if let resolver = Resolvers().all.last {
    dns.use(resolver)

    query(.a("google.com")) { (result) in
        log("Google A", result)
    }

    query(.aaaa("google.com")) { (result) in
        log("Google AAAA", result)
    }

    query(.txt("google.com")) { (result) in
        log("Google TXT", result)
    }

    query(.srv("gmail.com", .imaps, .tcp)) { (result) in
        log("Gmail IMAPS TCP SRV", result)
    }

    if let ip = IPv4Address("8.8.8.8") {
        query(.ptr(ip)) { (result) in
            log("Google DNS IPv4 PTR", result)
        }
    }

    if let ip = IPv6Address("2001:4860:4860::8888") {
        query(.ptr(ip)) { (result) in
            log("Google DNS IPv6 PTR", result)
        }
    }
} else {
    print("No Resolvers Found????")
}

wait()
