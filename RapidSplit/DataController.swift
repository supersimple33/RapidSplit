//
//  DataController.swift
//  RapidSplit
//
//  Created by Addison Hanrattie on 9/9/25.
//

import Foundation
import SwiftData

@MainActor
class DataController {
    static let previewContainer: ModelContainer = {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: Check.self, Item.self, Participant.self, configurations: config)

            let check1 = try Check(name: "Friday Dinner")
            let alice = try Participant(firstName: "Alice", lastName: "Johnson")
            let bob = try Participant(firstName: "Bob", lastName: "Smith")


            let item1 = Item(name: "Margherita Pizza", price: 12.99)
            try item1.addOrderer(alice)
            let item2 = Item(name: "Soda", price: 2.99)
            try item2.addOrderer(bob)

            check1.participants = [alice, bob]
            check1.items = [item1, item2]

            container.mainContext.insert(check1)

            let check2 = try Check(name: "Lunch at Cafe")
            let charlie = try Participant(firstName: "Charlie", lastName: "Nguyen")
            let dana = try Participant(firstName: "Dana", lastName: "Lee")

            let item3 = Item(name: "Burger", price: 14.99)
            try item3.addOrderer(charlie)
            let item4 = Item(name: "Fries", price: 4.99)
            try item4.addOrderer(dana)
            let item5 = Item(name: "Milkshake", price: 5.99)
            try item5.addOrderer(charlie)

            check2.participants = [charlie, dana]
            check2.items = [item3, item4, item5]


            container.mainContext.insert(check2)
            container.mainContext.insert(charlie)
            container.mainContext.insert(dana)
            container.mainContext.insert(item3)
            container.mainContext.insert(item4)
            container.mainContext.insert(item5)


            return container
        } catch {
            fatalError("Failed to create model container for previewing: \(error.localizedDescription)")
        }
    }()
}
