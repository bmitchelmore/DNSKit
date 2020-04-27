//
//  Resolver.swift
//  DNSLookup
//
//  Created by Blair Mitchelmore on 2020-04-27.
//  Copyright © 2020 Blair Mitchelmore. All rights reserved.
//

// Code adopted from <https://stackoverflow.com/questions/31256024/get-dns-server-ip-from-iphone-settings>

import Foundation
import Darwin

class Resolvers {
    private var state = __res_9_state()

    init() {
        res_9_ninit(&state)
    }

    deinit {
        res_9_ndestroy(&state)
    }

    private func name(for address: res_9_sockaddr_union) -> String {
        var addr = address
        var buffer = [CChar](repeating: 0, count: Int(NI_MAXHOST))
        let len = socklen_t(addr.sin.sin_len)
        let result = withUnsafePointer(to: &addr) { ptr in
            ptr.withMemoryRebound(to: sockaddr.self, capacity: 1) { ptr in
                Darwin.getnameinfo(ptr, len, &buffer, socklen_t(buffer.count), nil, 0, NI_NUMERICHOST)
            }
        }
        if result != 0 {
            print("Something went wrong!")
        }
        return String(cString: buffer)
    }

    var addresses: [res_9_sockaddr_union] {
        let max = 5
        var buffer = [res_9_sockaddr_union](repeating: res_9_sockaddr_union(), count: max)
        let count = Int(res_9_getservers(&state, &buffer, Int32(max)))
        return buffer[0..<count].filter({ $0.sin.sin_len > 0 })
    }

    var all: [String] {
        return addresses.map {
            name(for: $0)
        }
    }
}
