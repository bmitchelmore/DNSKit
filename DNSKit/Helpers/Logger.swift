//
//  Logger.swift
//  DNSKit
//
//  Created by Blair Mitchelmore on 2020-04-23.
//  Copyright © 2020 Blair Mitchelmore. All rights reserved.
//

import Foundation

protocol Logger {
    func error(_ error: Error, _ message: String)
    func warn(_ message: String)
    func debug(_ message: String)
    func verbose(_ message: String)
}

class ConsoleLogger: Logger {
    func error(_ error: Error, _ message: String) {
        print("\(message) Error: \(error)")
    }
    func warn(_ message: String) {
        print(message)
    }
    func debug(_ message: String) {
        print(message)
    }
    func verbose(_ message: String) {
        print(message)
    }
}

let logger: Logger = ConsoleLogger()
