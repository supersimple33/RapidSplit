//
//  GenerationTests.swift
//  RapidSplitTests
//
//  Created by Addison Hanrattie on 11/16/25.
//

import Testing
@testable import RapidSplit
import FoundationModels

fileprivate let TEST_CHECKS = [
    [
        "McDonalds Order",
        "BigMac $5.49",
        "McNugget Meal $10.99",
        "2 McChicken Entree $7.98",
    ],
    [
        "Sonic Drive-In",
        "55 burgers: $110.00",
        "55 fries: $110.00",
        "55 tacos: $110.00",
        "55 pies: $110.00",
        "55 cokes: $110.00",
        "100 tater tots: $300.00",
        "100 pizzas: $300.00",
        "Total with tax $1234.56"
    ],
    [
        "Chipotle Mexican Grill",
        "Chicken Burrito $8.95",
        "Steak Bowl $9.95",
        "Chips & Guacamole $4.50",
        "Fountain Drink $2.25",
        "Total $25.65"
    ]
]

struct GenerationTests {

    @Test("Title Generation", .enabled(if: !IS_RUNNING_IN_CLOUD), arguments: zip(TEST_CHECKS, [
        "McDonald's Meal Order",
        "Sonic Drive-In Feast",
        "Chipotle Meal"
    ]))
    func testGenerateTitle(lines: [String], expectedTitle: String) async throws {
        let title = try await GenerationService.shared.generateCheckTitle(
            recognizedStrings: lines,
        )
        #expect(title == expectedTitle)
    }

    @Test("Item Generation", .enabled(if: !IS_RUNNING_IN_CLOUD), arguments: zip(TEST_CHECKS, [
        [
            GeneratedItem(name: "BigMac", price: 5.49, quantity: 1),
            GeneratedItem(name: "McNugget Meal", price: 10.99, quantity: 1),
            GeneratedItem(name: "McChicken Entree", price: 7.98, quantity: 2)
        ],
        [
            GeneratedItem(name: "burgers", price: 110.00, quantity: 55),
            GeneratedItem(name: "fries", price: 110.00, quantity: 55),
            GeneratedItem(name: "tacos", price: 110.00, quantity: 55),
            GeneratedItem(name: "pies", price: 110.00, quantity: 55),
            GeneratedItem(name: "cokes", price: 110.00, quantity: 55),
            GeneratedItem(name: "tater tots", price: 300.00, quantity: 100),
            GeneratedItem(name: "pizzas", price: 300.00, quantity: 100)
        ],
        [
            GeneratedItem(name: "Chicken Burrito", price: 8.95, quantity: 1),
            GeneratedItem(name: "Steak Bowl", price: 9.95, quantity: 1),
            GeneratedItem(name: "Chips & Guacamole", price: 4.50, quantity: 1),
            GeneratedItem(name: "Fountain Drink", price: 2.25, quantity: 1)
        ]
    ]))
    func testItemGenerationStructure(lines: [String], expectedItems: [GeneratedItem]) async throws {
        actor SnapshotBuffer {
            private(set) var snapshots: [[GeneratedItem.PartiallyGenerated]] = []
            func append(_ value: [GeneratedItem.PartiallyGenerated]) {
                snapshots.append(value)
            }
        }
        let buffer = SnapshotBuffer()

        let generatedItems = try await GenerationService.shared.generateCheckStructure(
            recognizedStrings: lines,
            onPartial: { partialItems, content in
                await buffer.append(partialItems)
            }
        )

        let updatesReceived = await buffer.snapshots.count
        #expect(updatesReceived >= expectedItems.count, "Expected one update per item, got \(updatesReceived)")

        try #require(generatedItems.count == expectedItems.count)
        for (generatedItem, expectedItem) in zip(generatedItems, expectedItems) {
            #expect(generatedItem == expectedItem)
        }
    }
}
