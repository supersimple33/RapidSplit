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

        let allErrors: [LocalizedError] = Check.ValidationError.allCases
            + CheckPartError.allCases
            + Participant.ValidationError.allCases
            + CheckAnalysisScreen.AnalysisError.allCases

        for error in allErrors {
            let description = error.errorDescription?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            #expect(
                 !description.isEmpty,
                "Expected non-empty description for \(type(of: error)) -> got: '\(error.localizedDescription)'"
            )
            let localizedDescription = error.localizedDescription.trimmingCharacters(in: .whitespacesAndNewlines)
            #expect(
                 !localizedDescription.isEmpty,
                "Expected non-empty description for \(type(of: error)) -> got: '\(error.localizedDescription)'"
            )
        }
    }
}
