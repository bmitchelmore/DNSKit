//
//  DNSSECValidation.swift
//  DNSKit
//
//  Created by Blair Mitchelmore on 2020-05-04.
//  Copyright © 2020 Blair Mitchelmore. All rights reserved.
//

import Foundation
import CryptoKit
import CommonCrypto

enum DNSSECError: Error {
    case missingSignature
    case validationFailed
    case validationNotAvailable
    case invalidAlgorithm
    case invalidKey
    case algorithmNotImplemented(DNSSECAlgorithm)
    case commonCryptoFailure(CFError)
}
extension Sequence {
    func map<T>(_ keyPath: KeyPath<Element, T>) -> [T] {
        return map { $0[keyPath: keyPath] }
    }
}

//struct DNSSECValidationInfo {
//    var rrset: [ResourceRecord]
//    var rrsig: ResourceRecord
//    
//    var signature: Data
//    var message: Data
//}

struct DNSSECValidationInfo {
    var signature: [UInt8]
    var message: [UInt8]
}

extension Set where Element == ResourceRecord {
//    func extractValidationInfo() throws -> DNSSECValidationInfo {
//
//    }
//    func extractRRSet<T>(_ type: DNSRecordType, _ key: KeyPath<ResourceRecordData,T?>) -> ([(ResourceRecord,T)], (ResourceRecord,RRSIGData))? {
//        let data = self[type]
//            .compactMap { record in
//                return record.data[keyPath: key].map {
//                    return (record, $0)
//                }
//            }
//        let signatures = self[.rrsig]
//            .compactMap { record in
//                return record.data.rrsig.map {
//                    return (record, $0)
//                }
//            }
//
//        guard signatures.count == 1, let signature = signatures.first else {
//            return nil
//        }
//        return (data, signature)
//    }
    func buildValidationInfo() throws -> DNSSECValidationInfo {
        guard let rrsig = self[.rrsig].first, case .rrsig(let rrsigd) = rrsig.data else {
            throw DNSSECError.missingSignature
        }
        
        let records: [ResourceRecord] = try self
            .filter { $0.data.type == rrsigd.type }
            .map {
                var answer = $0
                answer.name = rrsigd.signer
                answer.ttl = rrsigd.ttl
                return answer
            }
            .sorted { (a, b) in
                let ad = try a.data.bytes()
                let bd = try b.data.bytes()
                return BytewiseCompare(ad, bd) == .orderedAscending
            }
        
        // rrsig rdata (excluding the signature)
        var rrsigb = rrsigd.bytes
        rrsigb.removeLast(rrsigd.signature.count)
        
        // remaining records wire format
        let recordsb = try records.flatMap { try $0.bytes() }
        
        return DNSSECValidationInfo(
            signature: [UInt8](rrsigd.signature),
            message: rrsigb + recordsb
        )
    }
//    func extractValidationBytes() throws -> (signature: [UInt8], data: [UInt8]) {
//
//        guard let rrsig = self[.rrsig].first, case .rrsig(let rrsigd) = rrsig.data else {
//            throw DNSSECError.missingSignature
//        }
//        let records: [ResourceRecord] = try self
//            .filter { $0.data.type == rrsigd.type }
//            .map {
//                var answer = $0
//                answer.ttl = rrsigd.ttl
//                return answer
//            }
//            .sorted { (a, b) in
//                let ad = try a.data.bytes()
//                let bd = try b.data.bytes()
//                return BytewiseCompare(ad, bd) == .orderedAscending
//            }
//
//        // rrsig rdata (excluding the signature)
//        var rrsigb = rrsigd.bytes
//        rrsigb.removeLast(rrsigd.signature.count)
//
//        // remaining records wire format
//        let recordsb = try records.flatMap { try $0.bytes() }
//
//        return ([UInt8](rrsigd.signature), rrsigb + recordsb)
//    }
}

extension ResourceRecord {
    func validate(against ds: DSData) throws -> Bool {
        guard #available(OSX 10.15, *) else {
            throw DNSSECError.validationNotAvailable
        }

        let message = try DNSString(name).bytes + data.rdata()
        let digest: Data

        switch ds.digest {
        case .sha1:
            digest = Data(Insecure.SHA1.hash(data: message))
        case .sha256:
            digest = Data(SHA256.hash(data: message))
        }
        
        return digest == ds.data
    }
}

extension DNSResponse {
    func validate(using keys: DNSResponse) throws -> ResourceRecord {
        guard #available(OSX 10.15, *) else {
            throw DNSSECError.validationNotAvailable
        }
        
        guard let rrsig = answers[.rrsig].first, case .rrsig(let rrsigd) = rrsig.data else {
            throw DNSSECError.missingSignature
        }
        
        let info = try answers.buildValidationInfo()
        
        let dnskeys = keys.answers[.dnskey]
        guard dnskeys.count > 0 else {
            throw DNSError.invalidResponse
        }
        
        logger.debug("Validating RRSIG (\(rrsigd.tag))")
        
        for dnskey in dnskeys {
            guard case .dnskey(let dnskeyd) = dnskey.data else {
                throw DNSError.invalidResponse
            }
            guard dnskeyd.zk else {
                continue
            }
            
            logger.verbose("Checking DNSKEY (\(dnskeyd.tag))")
            
            do {
                try dnskeyd.validate(signature: info.signature, data: info.message)
                if rrsigd.tag == dnskeyd.tag {
                    return dnskey
                } else {
                    logger.warn("Validation succeeded but key tag didn't match!")
                }
            } catch DNSSECError.validationFailed {
                continue
            } catch {
                throw error
            }
        }
         throw DNSSECError.validationFailed
    }
}

@available(OSX 10.15, *)
protocol PublicKeySignatureValidation {
    func validate<S: DataProtocol, D: DataProtocol>(_ signature: S, for data: D) throws
}

@available(OSX 10.15, *)
extension P256.Signing.PublicKey: PublicKeySignatureValidation {
    func validate<S, D>(_ signature: S, for data: D) throws where S : DataProtocol, D : DataProtocol {
        print("ecdsa256")
        let sig = try P256.Signing.ECDSASignature(rawRepresentation: signature)
        let isValid = isValidSignature(sig, for: data)
        if isValid == false {
            throw DNSSECError.validationFailed
        }
    }
}

@available(OSX 10.15, *)
extension P384.Signing.PublicKey: PublicKeySignatureValidation {
    func validate<S, D>(_ signature: S, for data: D) throws where S : DataProtocol, D : DataProtocol {
        print("ecdsa384")
        let sig = try P384.Signing.ECDSASignature(rawRepresentation: signature)
        let isValid = isValidSignature(sig, for: data)
        if isValid == false {
            throw DNSSECError.validationFailed
        }
    }
}

@available(OSX 10.15, *)
extension Curve25519.Signing.PublicKey: PublicKeySignatureValidation {
    func validate<S, D>(_ signature: S, for data: D) throws where S : DataProtocol, D : DataProtocol {
        print("x25519")
        let isValid = isValidSignature(signature, for: data)
        if isValid == false {
            throw DNSSECError.validationFailed
        }
    }
}

func ASN1Integer<D: DataProtocol>(_ data: D) -> [UInt8] {
    guard let first = data.first else { return [] }
    
    // ASN.1 integers are encoded using twos complement
    // which means if the high bit is set, the ASN.1 parser
    // will read it as a negative number so we need to
    // prefix a zero byte if the high bit of the first byte is set
    if first & 0x80 == 0x80 {
        return [0x00] + data.map { $0 }
    } else {
        return data.map { $0 }
    }
}

func ASN1Length<I: BinaryInteger>(_ amount: I) -> [UInt8] {
    // ASN.1 lengths are variable byte encoded.
    //
    // If less than 128 you use the last 7 bits of one byte
    // and set the high bit low.
    //
    // If greater than or equal to 128, you encode the value
    // as a sequence of bytes and prefix that with a byte
    // containing a high bit set high and the remaining bits
    // encoding the number of bytes used to encode the value.
    if amount < 128 {
        return [UInt8(amount)]
    } else {
        var bytes: [UInt8] = []
        var current = amount
        while current > 0 {
            let byte = UInt8(current & 0xff)
            bytes.insert(byte, at: 0)
            current >>= 8
        }
        bytes.insert(UInt8(bytes.count) | 0x80, at: 0)
        return bytes
    }
}

func ASN1OIDValue<I: BinaryInteger>(_ value: I) -> [UInt8] {
    // ASN.1 OID values are variable byte encoded.
    //
    // If less than 128 you use the last 7 bits of one byte
    // and set the high bit low.
    //
    // If greater than or equal to 128, you encode the value
    // as a sequence of 7-bit values with the high bit of the
    // octet set high for all but the final bit. The final
    // byte will have the high bit set low.
    if value < 128 {
        return [UInt8(value)]
    } else {
        var bytes: [UInt8] = []
        var current = value
        while current > 0 {
            let byte = UInt8(current & 0x7f)
            if bytes.isEmpty {
                bytes.insert(byte, at: 0)
            } else {
                bytes.insert(byte | 0x80, at: 0)
            }
            current >>= 7
        }
        return bytes
    }
}

enum ASN1 {
    private enum ASN1BitMasks: UInt8 {
        case constructed = 0b00100000
    }
    private enum ASN1Tag: UInt8 {
        case integer = 0x02
        case bitstring = 0x03
        case octetstring = 0x04
        case null = 0x05
        case oid = 0x06
        case sequence = 0x10
        
        func apply(_ bitmasks: ASN1BitMasks...) -> UInt8 {
            var value = rawValue
            for bitmask in bitmasks {
                value |= bitmask.rawValue
            }
            return value
        }
    }
    enum ASNOID {
        case sha256
        case sha512
        case rsasha256
        case rsasha512
        
        var values: [Int] {
            switch self {
            case .sha256:
                return [ 2, 16, 840, 1, 101, 3, 4, 2, 1 ]
            case .sha512:
                return [ 2, 16, 840, 1, 101, 3, 4, 2, 3 ]
            case .rsasha256:
                return [ 1, 2, 840, 113549, 1, 1, 11 ]
            case .rsasha512:
                return [ 1, 2, 840, 113549, 1, 1, 13 ]
            }
        }
        
        // ASN.1 OIDs are encoded as a series of numbers
        // with the first two components of an oid's path
        // encoded together as a single byte thanks to the
        // restrictive nature of those values
        //
        // after the first two components are encoded, each
        // additional component is encoded as a variable
        // length number using the packing format described
        // in the ASN1OIDValue func
        var bytes: [UInt8] {
            var values = self.values
            guard values.count > 1 else { return [] }
            
            let first: UInt8 = UInt8((40 * values[0]) + values[1])
            values.removeFirst(2)
            
            return [first] + values.flatMap { ASN1OIDValue($0) }
        }
    }
    case bitstring(Data)
    case octetstring(Data)
    case oid(ASNOID)
    case sequence([ASN1])
    case integer(Data)
    case null
    
    private func pack(_ tag: ASN1Tag, bytes: [UInt8]) -> [UInt8] {
        return pack(tag.rawValue, bytes: bytes)
    }
    
    private func pack(_ tagValue: UInt8, bytes: [UInt8]) -> [UInt8] {
        let type = tagValue
        let len = ASN1Length(bytes.count)
        return [
            [type],
            len,
            bytes
        ].flatMap { $0 }
    }
    
    var bytes: [UInt8] {
        switch self {
        case .null:
            return pack(.null, bytes: [])
        case .oid(let oid):
            return pack(.oid, bytes: oid.bytes)
        case .octetstring(let data):
            return pack(.octetstring, bytes: data.map { $0 })
        case .bitstring(let data):
            return pack(.bitstring, bytes: [0x00] + data.map { $0 })
        case .sequence(let items):
            let type = ASN1Tag.sequence.apply(.constructed)
            return pack(type, bytes: items.flatMap { $0.bytes })
        case .integer(let data):
            return pack(.integer, bytes: ASN1Integer(data))
        }
    }
}

@available(OSX 10.15, *)
final class RSAValidator: PublicKeySignatureValidation {
    enum Algorithm {
        case rsasha256
        case rsasha512
        
        var encryptionOID: ASN1.ASNOID {
            switch self {
            case .rsasha512: return .rsasha512
            case .rsasha256: return .rsasha256
            }
        }
        
        var digestOID: ASN1.ASNOID {
            switch self {
            case .rsasha512: return .sha512
            case .rsasha256: return .sha256
            }
        }
        
        var secKeyAlgorithm: SecKeyAlgorithm {
            switch self {
            case .rsasha512: return .rsaSignatureMessagePKCS1v15SHA512
            case .rsasha256: return .rsaSignatureMessagePKCS1v15SHA256
            }
        }
    }
    struct KeyData {
        var mod: Data
        var exp: Data
    }
    
    private let key: SecKey
    private let alg: SecKeyAlgorithm
    private let oid: ASN1.ASNOID
    
    init(key: SecKey, alg: SecKeyAlgorithm, oid: ASN1.ASNOID) {
        self.key = key
        self.alg = alg
        self.oid = oid
    }
    
    convenience init(alg: Algorithm, key: KeyData) throws {
        let asn1 = ASN1.sequence([
            .sequence([
                .oid(alg.encryptionOID),
                .null,
                .bitstring(
                    Data(ASN1.sequence([
                        .integer(key.mod),
                        .integer(key.exp)
                    ]).bytes)
                )
            ])
        ])
        var error: Unmanaged<CFError>?
        let bytes: [UInt8] = asn1.bytes
        guard let key = SecKeyCreateWithData(
            Data(bytes) as CFData,
            [
                kSecAttrKeyType: kSecAttrKeyTypeRSA,
                kSecAttrKeyClass: kSecAttrKeyClassPublic,
                kSecAttrKeySizeInBits: NSNumber(value: key.mod.count * 8)
            ] as CFDictionary,
            &error
        ) else {
            if let error = error {
                let cferror = error.takeRetainedValue()
                throw DNSSECError.commonCryptoFailure(cferror)
            } else {
                throw DNSSECError.invalidKey
            }
        }
        let oid = alg.digestOID
        let alg = alg.secKeyAlgorithm
        self.init(key: key, alg: alg, oid: oid)
    }
    
    func validate<S, D>(_ signature: S, for data: D) throws where S : DataProtocol, D : DataProtocol {
        var error: Unmanaged<CFError>?
        print("RSA Validation")
        let verified = SecKeyVerifySignature(key, alg, Data(signature) as CFData, Data(data) as CFData, &error)
        if !verified {
            if let error = error {
                let cferror = error.takeRetainedValue()
                if CFErrorGetCode(cferror) != -67808 { // RSA signature verification failed, no match
                    throw DNSSECError.commonCryptoFailure(cferror)
                }
            }
            throw DNSSECError.validationFailed
        }
    }
}

extension DNSKEYData {
    @available(OSX 10.15.0, *)
    func buildValidator() throws -> PublicKeySignatureValidation {
        switch (alg, pk) {
        case (.ecdsasha256, .ecdsa(x: let x, y: let y)):
            return try P256.Signing.PublicKey(rawRepresentation: x + y)
        case (.ecdsasha384, .ecdsa(x: let x, y: let y)):
            return try P384.Signing.PublicKey(rawRepresentation: x + y)

        case (.ed25519, DNSSECPublicKey.eddsa(let data)):
            return try Curve25519.Signing.PublicKey(rawRepresentation: data)

        case (.rsasha256, .rsa(exp: let exp, mod: let mod)):
            return try RSAValidator(alg: .rsasha256, key: RSAValidator.KeyData(mod: mod, exp: exp))
        case (.rsasha512, .rsa(exp: let exp, mod: let mod)):
            return try RSAValidator(alg: .rsasha512, key: RSAValidator.KeyData(mod: mod, exp: exp))

            case (.ed448, _):
                throw DNSSECError.algorithmNotImplemented(alg)

        default:
            throw DNSSECError.invalidAlgorithm
        }
    }
}

extension DNSKEYData {
    func validate(signature: [UInt8], data: [UInt8]) throws {
        guard #available(OSX 10.15, *) else {
            throw DNSSECError.validationNotAvailable
        }
        
        let validator = try buildValidator()
        try validator.validate(signature, for: data)
    }
}
