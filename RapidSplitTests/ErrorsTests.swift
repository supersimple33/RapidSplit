//
//  ErrorsTests.swift
//  RapidSplitTests
//
//  Created by Addison Hanrattie on 11/18/25.
//

import Testing
@testable import RapidSplit
import Foundation

struct ErrorsTests {

    @Test("Error Descriptions not empty")
    func errorDescriptionsNotEmpty() throws {
        // Build a representative set of errors from the app domain
        let longName = String(repeating: "X", count: 60)
        let checkErrors: [Check.ValidationError] = [
            Check.ValidationError.emptyName,
            Check.ValidationError.nameTooLong
        ]
        let participantErrors: [Participant.ValidationError] = [
            Participant.ValidationError.emptyName,
            Participant.ValidationError.nameTooLong(name: longName),
            Participant.ValidationError.invalidPhoneNumber,
            Participant.ValidationError.formattingDiscrepancy
        ]
        let relationErrors: [CheckPartError] = [
            CheckPartError.missing,
            CheckPartError.mismatched
        ]

        let allErrors: [LocalizedError] = checkErrors + participantErrors + relationErrors
        
        for error in allErrors {
            let description = error.errorDescription?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            #expect(
                 !description.isEmpty,
                "Expected non-empty description for \(type(of: error)) -> got: '\(error.localizedDescription)'"
            )
        }
        for error in allErrors {
            let description = error.localizedDescription.trimmingCharacters(in: .whitespacesAndNewlines)
            #expect(
                 !description.isEmpty,
                "Expected non-empty description for \(type(of: error)) -> got: '\(error.localizedDescription)'"
            )
        }
    }

    // MARK: - Exhaustiveness guards
    // These functions intentionally switch over each error enum without a default case.
    // If a new case is added to any enum, this test file will fail to compile until updated.

    private func assertExhaustive(_ error: Check.ValidationError) {
        switch error {
        case .emptyName: break
        case .nameTooLong: break
        }
    }

    private func assertExhaustive(_ error: Participant.ValidationError) {
        switch error {
        case .emptyName: break
        case .nameTooLong(name: _): break
        case .invalidPhoneNumber: break
        case .formattingDiscrepancy: break
        }
    }

    private func assertExhaustive(_ error: CheckPartError) {
        switch error {
        case .missing: break
        case .mismatched: break
        }
    }

    @Test("Error enums are exhaustive (fails compile if a new case is added)")
    func errorEnumsExhaustive() throws {
        // Provide one representative value per enum to satisfy parameter requirements.
        assertExhaustive(Check.ValidationError.emptyName)
        assertExhaustive(Participant.ValidationError.emptyName)
        assertExhaustive(CheckPartError.missing)
    }
}
