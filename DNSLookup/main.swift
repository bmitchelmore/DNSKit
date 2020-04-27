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

// Simple example usage of DNSKit

if let resolver = Resolvers().all.first {
    dns.use(resolver)

    let group = DispatchGroup()

    group.enter()
    dns.query(.txt("google.com")) { (result) in
        print("Google TXT: \(result)")
        group.leave()
    }

    group.enter()
    dns.query(.aaaa("cloudflare.com")) { (result) in
        print("Cloudflare AAAA: \(result)")
        group.leave()
    }

    group.notify(queue: .main) {
        exit(0)
    }

    RunLoop.current.run()
} else {
    print("No Resolvers Found????")
}

