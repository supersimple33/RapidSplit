//
//  DataController.swift
//  RapidSplit
//
//  Created by Addison Hanrattie on 9/9/25.
//

#if DEBUG

import Foundation
import SwiftData

@MainActor
class DataController {
    static let previewContainer: ModelContainer = {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(
                for: Check.self, Item.self, Participant.self, configurations: config)

            try DataController.seed(context: container.mainContext)

            return container
        } catch {
            fatalError("Failed to create model container for previewing: \(error.localizedDescription)")
        }
    }()

    static func seed(context: ModelContext) throws {
        let check1 = try Check(name: "Friday Dinner")
        context.insert(check1)
        let alice = try Participant(firstName: "Alice", lastName: "Johnson")
        let bob = try Participant(firstName: "Bob", lastName: "Smith")


        let item1 = Item(name: "Margherita Pizza", price: 12.99)
        let item2 = Item(name: "Soda", price: 2.99)

        check1.items = [item1, item2]

        try item1.addOrderer(alice)
        try item2.addOrderer(bob)

        let check2 = try Check(name: "Lunch at Cafe")
        context.insert(check2)

        let charlie = try Participant(firstName: "Charlie", lastName: "Nguyen")
        let dana = try Participant(firstName: "Dana", lastName: "Lee")

        let item3 = Item(name: "Burger", price: 14.99)
        let item4 = Item(name: "Fries", price: 4.99)
        let item5 = Item(name: "Milkshake", price: 5.99)

        check2.items = [item3, item4, item5]

        try item3.addOrderer(charlie)
        try item4.addOrderer(dana)
        try item5.addOrderer(charlie)

        // Check 3: Brunch with Friends
        let check3 = try Check(name: "Sunday Brunch")
        context.insert(check3)

        let emma = try Participant(firstName: "Emma", lastName: "Williams")
        let frank = try Participant(firstName: "Frank", lastName: "Brown")

        let item6 = Item(name: "Avocado Toast", price: 10.49)
        let item7 = Item(name: "Latte", price: 4.49)
        let item8 = Item(name: "Pancakes", price: 9.99)

        check3.items = [item6, item7, item8]

        try item6.addOrderer(emma)
        try item7.addOrderer(frank)
        try item8.addOrderer(emma)

        // Check 4: Dinner Party
        let check4 = try Check(name: "Dinner Party")
        context.insert(check4)

        let gina = try Participant(firstName: "Gina", lastName: "Lopez")
        let henry = try Participant(firstName: "Henry", lastName: "Kim")

        let item9 = Item(name: "Steak", price: 24.99)
        let item10 = Item(name: "Salad", price: 7.99)
        let item11 = Item(name: "Red Wine", price: 18.50)

        check4.items = [item9, item10, item11]

        try item9.addOrderer(henry)
        try item10.addOrderer(gina)
        try item11.addOrderer(gina)

        try context.save()
    }
}
#endif
