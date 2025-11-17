//
//  Participant.swift
//  RapidSplit
//
//  Created by Addison Hanrattie on 9/6/25.
//

import Foundation
import SwiftData
import PhoneNumberKit

@Model
final class Participant {
    // Stored properties
    var createdAt: Date = Date()
    var firstName: String
    var lastName: String
    var phoneNumber: String?
    var check: Check
    var payed: Bool
    @Relationship(deleteRule: .nullify, inverse: \Item.orderers) var items: [Item]

    // Domain-specific validation error
    enum ValidationError: Error, LocalizedError, Equatable {
        case emptyName
        case nameTooLong(name: String)
        case invalidPhoneNumber

        var errorDescription: String? {
            switch self {
            case .emptyName:
                return "Name fields must be populated"
            case .nameTooLong(let name):
                return "Name: \(name) is too long. Maximum length is \(maxNameLength) characters."
            case .invalidPhoneNumber:
                return "Phone number is invalid."
            }
        }
    }

    // Centralized constraints
    static let maxNameLength: Int = 50

    private static func validateAndFormatName(_ name: String) throws -> String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmed.isEmpty else { throw ValidationError.emptyName }
        guard trimmed.count <= Self.maxNameLength else {
            throw ValidationError.nameTooLong(name: name)
        }

        return trimmed
    }

    private static func validatePhoneNumber(_ phoneNumber: String) throws {
        let phoneNumberUtility = PhoneNumberUtility()
        guard phoneNumberUtility
            .isValidPhoneNumber(phoneNumber, ignoreType: true) else {
            throw ValidationError.invalidPhoneNumber
        }
    }

    func validate() throws {
        if let phoneNumber {
            try Participant.validatePhoneNumber(phoneNumber)
        }
        _ = try Participant.validateAndFormatName(self.firstName)
        _ = try Participant.validateAndFormatName(self.lastName)
    }

    // Throwing initializer that validates and normalizes input
    init(firstName: String, lastName: String, phoneNumber: String? = nil, check: Check) throws {
        // Validate names
        let trimmedFirst = try Participant.validateAndFormatName(firstName)

        let trimmedLast =  try Participant.validateAndFormatName(lastName)

        // Validate and normalize phone if provided
        if let phoneNumber {
            try Participant.validatePhoneNumber(phoneNumber)
            self.phoneNumber = phoneNumber
        } else {
            self.phoneNumber = nil
        }
        self.firstName = trimmedFirst
        self.lastName = trimmedLast
        self.check = check
        self.items = []
        self.payed = false
    }

    func getTotalCost() -> Decimal {
        return self.items.reduce(0) { $0 + $1.price }
    }
}

