//
//  DNSQueue.swift
//  DNSKit
//
//  Created by Blair Mitchelmore on 2020-04-23.
//  Copyright © 2020 Blair Mitchelmore. All rights reserved.
//

import Foundation
import Network
import CryptoKit

private let handlerQueue = DispatchQueue(
    label: "dns-lookup-handler",
    qos: .userInitiated,
    attributes: [],
    autoreleaseFrequency: .workItem,
    target: nil
)
private let listenerQueue = DispatchQueue(
    label: "dns-lookup-listener",
    qos: .userInitiated,
    attributes: [.concurrent],
    autoreleaseFrequency: .workItem,
    target: nil
)

final class DNSQueue {
    typealias Callback = (Result<DNSResponse,Error>) -> Void

    private let connection: NWConnection
    private let sem: DispatchSemaphore

    private var handlers: [UInt16:Callback]

    init(resolver: NWEndpoint, handlerQueue: DispatchQueue = handlerQueue, listenerQueue: DispatchQueue = listenerQueue) {
        connection = NWConnection(to: resolver, using: .udp)
        handlers = [:]
        sem = DispatchSemaphore(value: 0)
        connection.start(queue: handlerQueue)
        listen(on: listenerQueue)
    }

    private func listen(on queue: DispatchQueue) {
        listenerQueue.async { [weak self, logger] () in
            guard let self = self else { return }
            self.sem.wait()
//            logger.verbose("Listening for messages")
            self.connection.receiveMessage { [weak self, logger] (data, context, finished, error) in
                if let error = error {
                    logger.error(error, "Failed to receive message!")
                } else if let consumer = data.map({ try? DataConsumer(data: $0) }), var data = consumer {
                    guard let self = self else { return }
                    var handler: Callback? = nil
                    do {
                        let response: DNSResponse = try data.take()
                        if let value = self.handlers[response.header.id] {
                            handler = value
                        }
//                        logger.debug("Received response for Query \(response.header.id.hex): \(data.bytesTotal) bytes")
                        handler?(.success(response))
                    } catch DNSParseError.invalidResponse(let id, let error) {
                        if let value = self.handlers[id] {
                            handler = value
                        }
                        logger.error(error, "Error parsing response for query \(id.hex)")
                        handler?(.failure(DNSError.invalidResponse))
                    } catch {
                        logger.error(error, "Error parsing response")
                        handler?(.failure(DNSError.invalidResponse))
                    }
                } else {
                    logger.warn("Unrecognized message: \(data?.hex ?? "nil")")
                }
                self?.listen(on: queue)
            }
        }
    }

    func schedule(_ request: DNSRequest, timeout: TimeInterval = 3, completion: @escaping Callback) {
        do {
            let bytes = try request.bytes()
            var finished = false
            let finish: Callback = { result in
                if finished { return }
                finished = true
                completion(result)
            }
            delayer.run(in: timeout) {
                finish(.failure(DNSError.timeout))
            }
            handlers[request.header.id] = { result in
                finish(result)
            }
            connection.send(content: Data(bytes), completion: .contentProcessed { [weak self, logger] (error) in
//                logger.debug("Query \(request.header.id.hex) \(request.questions) Sent To Resolver")
                self?.sem.signal()
            })
        } catch {
            MainFailure(error, completion)
        }
    }
}

