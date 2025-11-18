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
    var payed: Bool
    @Relationship(deleteRule: .nullify, inverse: \Check.participants) private var internal_check: Check?
    @Relationship(deleteRule: .nullify, inverse: \Item.orderers) private(set) var items: [Item]

    var check: Check {
        get throws {
            guard let check = self.internal_check else {
                throw CheckPartError.missing
            }
            return check
        }
    }

    // Domain-specific validation error
    enum ValidationError: LocalizedError, Equatable {
        case emptyName
        case nameTooLong(name: String)
        case invalidPhoneNumber
        case formattingDiscrepancy

        var errorDescription: String? {
            switch self {
            case .emptyName:
                return "Name fields must be populated"
            case .nameTooLong(let name):
                return "Name: \(name) is too long. Maximum length is \(maxNameLength) characters."
            case .invalidPhoneNumber:
                return "Phone number is invalid."
            case .formattingDiscrepancy:
                return "Finalized name can be further formatted."
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
        guard try self.firstName == Participant.validateAndFormatName(self.firstName) else {
            throw ValidationError.formattingDiscrepancy
        }
        guard try self.lastName == Participant.validateAndFormatName(self.lastName) else {
            throw ValidationError.formattingDiscrepancy
        }
        _ = try self.check
    }

    // Throwing initializer that validates and normalizes input
    init(firstName: String, lastName: String, phoneNumber: String? = nil) throws {
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
        self.items = []
        self.payed = false
    }

    func getTotalCost() -> Decimal {
        return self.items.reduce(Decimal.zero) { $0 + $1.price }
    }

    func addItem(_ item: Item) throws {
        let prevCheck = try? item.check
        if prevCheck == nil {
            try self.check.items.append(item)
            self.items.append(item)
        } else if try prevCheck === self.check {
            self.items.append(item)
        } else {
            throw CheckPartError.mismatched
        }
    }
}

