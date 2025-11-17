//
//  GenerationService.swift
//  RapidSplit
//
//  Created by Addison Hanrattie on 9/22/25.
//

import Foundation
import FoundationModels

fileprivate let ITEMS_INSTRUCTIONS = """
Please sort this description of the check into items using the supplied guidelines.
Please ignore any junk descriptions such as the name of the merchant and any tax information
or information about coupons or surveys. Be sure to include prices formatted as doubles ie ($1.15=1.15)
Do not divide the price of items by the quanity but rather set the price for all of them total. ie (if you have
5 items priced at $15 set the price to $15 rather than $3.
"""

fileprivate let TITLE_INSTRUCTIONS = """
Please generate a title for this check it should only be a few words long such as Five Guys Lunch or Subway Catering.
Only output the title and nothing else.
"""

actor GenerationService {
    static let shared = GenerationService()

    private init() { }

    func generateCheckStructure(
        recognizedStrings: [String],
        onPartial: (@Sendable ([GeneratedItem.PartiallyGenerated], GeneratedContent) async -> Void)? = nil,
        options: GenerationOptions = GenerationOptions()
    ) async throws -> [GeneratedItem] {
        let session = LanguageModelSession(model: .default, instructions: ITEMS_INSTRUCTIONS)
        let prompt = "Here is the scanned check:\n" + recognizedStrings.joined(separator: "\n")
        let stream = session.streamResponse(to: prompt, generating: [GeneratedItem].self, options: options)

        if let onPartial {
            for try await items in stream {
                await onPartial(items.content, items.rawContent)
            }
        }

        let finalItems = try await stream.collect().content
        return finalItems
    }

    func generateCheckTitle(
        recognizedStrings: [String],
        options: GenerationOptions = GenerationOptions()
    ) async throws -> String {
        let session = LanguageModelSession(model: .default, instructions: TITLE_INSTRUCTIONS)
        let prompt = "Here is the scanned check, what would be a good name for it?:\n" + recognizedStrings.joined(separator: "\n")
        return try await session
            .streamResponse(to: prompt, generating: String.self, includeSchemaInPrompt: false, options: options)
            .collect().content
    }
}
