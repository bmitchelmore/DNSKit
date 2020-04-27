//
//  ResultHelpers.swift
//  DNSKit
//
//  Created by Blair Mitchelmore on 2020-04-23.
//  Copyright © 2020 Blair Mitchelmore. All rights reserved.
//

import Foundation

func MainFailure<Success,Failure>(_ error: Failure, _ completion: @escaping (Result<Success,Failure>) -> Void) {
    DispatchQueue.main.async {
        completion(.failure(error))
    }
}

func MainSuccess<Success,Failure>(_ value: Success, _ completion: @escaping (Result<Success,Failure>) -> Void) {
    DispatchQueue.main.async {
        completion(.success(value))
    }
}
