//
//  Check.swift
//  RapidSplit
//
//  Created by Addison Hanrattie on 9/6/25.
//

import Foundation
import SwiftData

@Model
final class Check: Identifiable {
    var createdAt: Date = Date()
    var name: String
    @Relationship(deleteRule: .cascade) var participants: [Participant]
    @Relationship(deleteRule: .cascade) var items: [Item]

    // Centralized constraints
    static let maxNameLength: Int = 50

    // Domain-specific validation error
    enum ValidationError: LocalizedError, CaseIterable {
        case emptyName
        case nameTooLong

        var errorDescription: String? {
            switch self {
            case .emptyName:
                return "Check name cannot be empty."
            case .nameTooLong:
                return "Check name is too long. Maximum length is \(maxNameLength) characters."
            }
        }
    }

    // Throwing initializer that validates and normalizes input
    init(name: String, participants: [Participant] = [], items: [Item] = []) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            throw ValidationError.emptyName
        }
        guard trimmedName.count <= Self.maxNameLength else {
            throw ValidationError.nameTooLong
        }

        self.name = trimmedName
        self.participants = participants
        self.items = items
    }
}

enum CheckPartError: LocalizedError, CaseIterable {
    case missing
    case mismatched

    var errorDescription: String? {
        switch self {
        case .missing:
            return "The associated check no longer exists (DB Error)."
        case .mismatched:
            return "The check associated with the item and participant differ."
        }
    }
}
