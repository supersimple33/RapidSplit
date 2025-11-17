//
//  Item.swift
//  RapidSplit
//
//  Created by Addison Hanrattie on 9/6/25.
//

import Foundation
import SwiftData
import FoundationModels

// A lightweight common interface that both persisted and generated items can share.
protocol Purchasable: Hashable {
    var name: String { get set }
    var price: Decimal { get set }
}

@Model
final class Item: Purchasable {
    var createdAt: Date = Date()
    var name: String
    var price: Decimal // cents
    @Relationship(deleteRule: .nullify) var orderers: [Participant]
    @Relationship(deleteRule: .nullify, inverse: \Check.items) private var internal_check: Check?

    var check: Check {
        get throws {
            guard let check = self.internal_check else {
                throw MissingCheckError()
            }
            return check
        }
    }

    init(name: String, price: Decimal) {
        self.name = name
        self.price = price
        self.orderers = []
    }

    init(from item: any Purchasable) {
        self.name = item.name
        self.price = item.price
        self.orderers = []
    }
}

@Generable(description: "A single item from the check")
struct GeneratedItem: Purchasable {
    @Guide(description: "The name of the item") // TODO: add regex
    var name: String
    @Guide(description: "The price of a the given item", .minimum(0))
    var price: Decimal
    @Guide(description: "The quantity of this item bought", .minimum(0))
    var quantity: Int
}
