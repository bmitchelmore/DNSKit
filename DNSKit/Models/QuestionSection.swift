//
//  QuestionSection.swift
//  DNSKit
//
//  Created by Blair Mitchelmore on 2020-04-27.
//  Copyright © 2020 Blair Mitchelmore. All rights reserved.
//

import Foundation

public enum SRVService: String, Hashable {
    case ldap = "_ldap"
    case sip = "_sip"
    case carddav = "_carddav"
    case carddavs = "_carddavs"
    case caldav = "_caldav"
    case caldavs = "_caldavs"
    case kerberos = "_kerberos"
    case kerberos_master = "_kerberos-master"
    case kerberos_adm = "_kerberos-adm"
    case kpasswd = "_kpasswd"
    case kerberos_iv = "_kerberos-iv"
    case submission = "_submission"
    case imap = "_imap"
    case imaps = "_imaps"
    case pop3 = "_pop3"
    case pop3s = "_pop3s"
    case minecraft = "_minecraft"
    case mumble = "_mumble"
    case jabber = "_jabber"
    case puppet = "_x-puppet"
    case teamspeak = "_ts3"
}

public enum SRVProto: String, Hashable {
    case tcp = "_tcp"
    case udp = "_udp"
}

public struct QuestionSection: Hashable {
    let `class`: DNSRecordClass
    let type: DNSRecordType
    let name: String

    init(`class`: DNSRecordClass, type: DNSRecordType, name: String) {
        self.`class` = `class`
        self.type = type
        self.name = name
    }

    init(_ type: DNSRecordType, _ name: String, _ `class`: DNSRecordClass = .in) {
        self.init(class: `class`, type: type, name: name)
    }
}

extension QuestionSection {
    public static func a(_ name: String) -> QuestionSection {
        return QuestionSection(.a, name)
    }
    public static func ns(_ name: String) -> QuestionSection {
        return QuestionSection(.ns, name)
    }
    public static func cname(_ name: String) -> QuestionSection {
        return QuestionSection(.cname, name)
    }
    public static func soa(_ name: String) -> QuestionSection {
        return QuestionSection(.soa, name)
    }
    public static func mx(_ name: String) -> QuestionSection {
        return QuestionSection(.mx, name)
    }
    public static func txt(_ name: String) -> QuestionSection {
        return QuestionSection(.txt, name)
    }
    public static func aaaa(_ name: String) -> QuestionSection {
        return QuestionSection(.aaaa, name)
    }
    public static func srv(_ name: String, _ service: SRVService, _ proto: SRVProto) -> QuestionSection {
        return QuestionSection(.srv, "\(service.rawValue).\(proto.rawValue).\(name)")
    }
    public static func any(_ name: String) -> QuestionSection {
        return QuestionSection(.any, name)
    }
    public static func caa(_ name: String) -> QuestionSection {
        return QuestionSection(.caa, name)
    }
}

extension QuestionSection {
    var bytes: [UInt8] {
        return [
            name.bytes,
            type.rawValue.bytes,
            `class`.rawValue.bytes
        ].flatMap { $0 }
    }
}

extension DataConsumer {
    mutating func take() throws -> QuestionSection {
        let name: DNSString = try take()
        let type: DNSRecordType = try take()
        let `class`: DNSRecordClass = try take()
        return QuestionSection(
            class: `class`,
            type: type,
            name: name.string
        )
    }
}
