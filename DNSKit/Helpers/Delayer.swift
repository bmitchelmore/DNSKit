//
//  Delayer.swift
//  DNSKit
//
//  Created by Blair Mitchelmore on 2020-04-23.
//  Copyright © 2020 Blair Mitchelmore. All rights reserved.
//

import Foundation

protocol Delayer {
    typealias Function = () -> Void
    func run(in delay: TimeInterval, fn: @escaping Function)
}

class GCDDelayer: Delayer {
    typealias Function = () -> Void

    func run(in delay: TimeInterval, fn: @escaping Function) {
        DispatchQueue.main.asyncAfter(
            deadline: .now() + delay,
            execute: fn
        )
    }
}

let delayer: Delayer = GCDDelayer()
