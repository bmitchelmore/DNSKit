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
    
    private func validate(_ response: DNSResponse, completion: @escaping (Result<DNSResponse,Error>) -> Void) {
        logger.verbose("Validating response: \(response)")

        guard let rrsig = response.answers[.rrsig].first, case .rrsig(let rrsigd) = rrsig.data else {
            return completion(.failure(DNSSECError.missingSignature))
        }
        
        if case .dnskey = rrsigd.type, rrsigd.signer.isEmpty {
             logger.debug("Validated to the final point!")
             logger.verbose("Result: \(rrsig)")
        } else {
            let group = DispatchGroup()
            var dnskeyr: Result<DNSResponse,Error> = .failure(DNSError.timeout)
            var dsr: Result<DNSResponse,Error> = .failure(DNSError.timeout)

            group.enter()
            let ds = DNSRequest(validating: true, .ds(rrsigd.signer))
            queue.schedule(ds) { (result) in
                dsr = result
                group.leave()
            }
            
            group.enter()
            let dnskey = DNSRequest(validating: true, .dnskey(rrsigd.signer))
            queue.schedule(dnskey) { (result) in
                dnskeyr = result
                group.leave()
            }
            
            group.notify(queue: .main) { [weak self] () in
                guard let self = self else { return }
                switch (dsr, dnskeyr) {
                case (.success(let dsr), .success(let dnskeyr)):
                    do {
                        print("DSR: \(dsr)")
                        print("DNSKEYS: \(dnskeyr)")
                        
                        // validate original rrset with dnskey data
                        _ = try response.validate(using: dnskeyr)
                        
                        // validate dnskey data with dnskey response
                        let ksigner = try dnskeyr.validate(using: dnskeyr)
                        
                        // validate dnskey used to sign dnskeys
                        if let ksignerd = ksigner.data.dnskey,
                            let ksdigest = dsr.answers[.ds]
                                .compactMap({ $0.data.ds })
                                .filter({ $0.tag == ksignerd.tag })
                                .first {
                            let valid = try ksigner.validate(against: ksdigest)
                            guard valid else {
                                throw DNSSECError.validationFailed
                            }
                        } else {
                            throw DNSSECError.validationFailed
                        }
                        
                        print("Validating DS record")
                        
                        // validate ds record with parent zone
                        self.validate(dsr, completion: completion)
//                        self.validate(dsr, completion: completion)
                        
//                        response.answers.buildValidationInfo()
                        
//                        let ds = dsr.answers[.ds]
//                        let dnskey = dnskeyr.answers[.dnskey]
//                        
//                        
//                        guard
//                            let (dss, dssig) = dsr.answers.extractRRSet(.ds, \.ds),
//                            let (dnskeys, dnskeysig) = dnskeyr.answers.extractRRSet(.dnskey, \.dnskey)
//                        else {
//                            throw DNSSECError.missingSignature
//                        }
                        
                        
//                        completion(.success(response))
                    } catch {
                        completion(.failure(error))
                    }
                case (.failure(let error), _), (_, .failure(let error)):
                    completion(.failure(error))
//
//                case .success(let signer):
//                    logger.debug("Received trust validation response: \(signer)")
//                    do {
//                        _ = try response.validate(using: signer)
//                        logger.verbose("Validated \(response) using \(signer)")
//                        self.validate(signer, completion: completion)
//                    } catch {
//                        completion(.failure(error))
//                    }
//                case .failure(let error):
//                    completion(.failure(error))
                }
            }
        }
    }

    public func query(_ query: QuestionSection, validating: Bool, completion: @escaping (Result<DNSResponse, Error>) -> Void) {
        if validating {
            let main = DNSRequest(validating: true, query)
            self.queue.schedule(main) { [weak self] (result) in
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    self.validate(response, completion: completion)
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        } else {
            let request = DNSRequest(query)
            self.queue.schedule(request, completion: completion)
        }
    }
}

public let dns: DNS = DNS(resolver: "1.1.1.1")
