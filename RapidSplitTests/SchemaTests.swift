//
//  SchemaTests.swift
//  RapidSplitTests
//
//  Created by Addison Hanrattie on 11/17/25.
//

import Testing
@testable import RapidSplit
import SwiftData
import Foundation

struct SchemaTests {

    // MARK: - Helpers

    private func makeInMemoryContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: Check.self, Item.self, Participant.self, configurations: config)
    }

    // MARK: - Check validation

    @Test("Check init trims and accepts valid name")
    func checkInitTrimsAndValidates() async throws {
        let check = try Check(name: "  Lunch Run  ")
        #expect(check.name == "Lunch Run")
        #expect(check.participants.isEmpty)
        #expect(check.items.isEmpty)
    }

    @Test("Check init throws for empty or whitespace-only name")
    func checkInitThrowsForEmpty() async throws {
        #expect(throws: Check.ValidationError.emptyName) {
            try Check(name: "")
        }
        #expect(throws: Check.ValidationError.emptyName) {
            try Check(name: "   \n\t  ")
        }
    }

    @Test("Check init enforces max name length")
    func checkInitEnforcesMaxLength() async throws {
        let justLong = String(repeating: "A", count: Check.maxNameLength)
        #expect(throws: Check.ValidationError.nameTooLong) {
            try Check(name: justLong + "A")
        }
        #expect(try Check(name: justLong + "   ").name == justLong)
    }

    // MARK: - Participant validation

    @Test("Participant init trims names and defaults")
    func participantInitTrimsAndDefaults() async throws {
        let p = try Participant(firstName: "  Alice  ", lastName: " \t Smith  \n ")
        #expect(p.firstName == "Alice")
        #expect(p.lastName == "Smith")
        #expect(p.phoneNumber == nil)
        #expect(p.payed == false)
        #expect(p.items.isEmpty)
    }

    @Test("Participant init throws for invalid phone number")
    func participantInitInvalidPhone() async throws {
        let check = try Check(name: "Test")
        #expect(throws: Participant.ValidationError.invalidPhoneNumber) {
            check.participants.append(
                try Participant(firstName: "Bob", lastName: "Jones", phoneNumber: "abc-not-a-phone")
            )
        }
        #expect(check.participants.isEmpty)
    }

    @Test("Participant init throws for empty names")
    func participantInitEmptyNames() async throws {
        let check = try Check(name: "Test")
        #expect(throws: Participant.ValidationError.emptyName) {
            check.participants.append(try Participant(firstName: "   ", lastName: "Doe"))
        }
        #expect(throws: Participant.ValidationError.emptyName) {
            check.participants.append(try Participant(firstName: "\n", lastName: "Doe\n"))
        }
        #expect(throws: Participant.ValidationError.emptyName) {
            check.participants.append(try Participant(firstName: "Jane", lastName: "   "))
        }
        #expect(throws: Participant.ValidationError.emptyName) {
            check.participants.append(try Participant(firstName: "   Jane    ", lastName: "\t \t"))
        }
        #expect(check.participants.isEmpty)
    }

    @Test("Participant init enforces max name length")
    func participantInitMaxLength() async throws {
        let check = try Check(name: "Test")
        let long = String(repeating: "Z", count: Participant.maxNameLength)
        #expect(throws: Participant.ValidationError.nameTooLong(name: long + "Z")) {
            check.participants.append(try Participant(firstName: long + "Z", lastName: "Ok"))
        }
        #expect(throws: Participant.ValidationError.nameTooLong(name: long + "Z")) {
            check.participants.append(try Participant(firstName: "ok", lastName: long + "Z"))
        }
        #expect(check.participants.isEmpty)
        #expect(try Participant(firstName: long + "  ", lastName: "Ok").firstName == long)
        #expect(try Participant(firstName: "ok", lastName: long + "\n").lastName == long)   
    }

    // MARK: - Relationships & delete rules

    @Test("Inverse relationship maintained between Item.orderers and Participant.items")
    @MainActor
    func inverseRelationshipMaintainedAndDeleted() async throws {
        let container = try makeInMemoryContainer()
        let context = container.mainContext

        let check = try Check(name: "Dinner")

        let alice = try Participant(firstName: "Alice", lastName: "Jones")
        let burger = Item(name: "Burger", price: 12.50)

        context.insert(check)
        check.participants.append(alice)
        try alice.addItem(burger)

        var pDesc = FetchDescriptor<Participant>()
        pDesc.fetchLimit = 1
        let fetchedP = try #require(context.fetch(pDesc).first)

        var iDesc = FetchDescriptor<Item>()
        iDesc.fetchLimit = 1
        let fetchedI = try #require(context.fetch(iDesc).first)

        #expect(fetchedI.orderers.contains(where: { $0 === fetchedP }))
        #expect(fetchedP.items.contains(where: { $0 === fetchedI }))

        // remove link
        burger.removeOrderer(alice)

        let postFetchedP = try #require(context.fetch(pDesc).first)
        let postFetchedI = try #require(context.fetch(iDesc).first)

        #expect(burger.orderers.isEmpty)
        #expect(alice.items.isEmpty)
        #expect(!postFetchedI.orderers.contains(where: { $0 === fetchedP }))
        #expect(!postFetchedP.items.contains(where: { $0 === fetchedI }))
        #expect(check.participants.count == 1)
        #expect(check.items.count == 1)
    }

    @Test("Deleting Check cascades to Items and Participants")
    @MainActor
    func deletingCheckCascades() async throws {
        let container = try makeInMemoryContainer()
        let context = container.mainContext

        let check = try Check(name: "Friday")
        context.insert(check)

        let alice = try Participant(firstName: "Alice", lastName: "J")
        check.participants.append(alice)
        let bob = try Participant(firstName: "Bob", lastName: "K")
        check.participants.append(bob)
        let soda = Item(name: "Soda", price: 2.99)
        let fries = Item(name: "Fries", price: 3.4)
        try alice.addItem(soda)
        try bob.addItem(fries)

        // Pre-deletion sanity checks
        let preParticipants = try context.fetch(FetchDescriptor<Participant>())
        let preItems = try context.fetch(FetchDescriptor<Item>())
        let preChecks = try context.fetch(FetchDescriptor<Check>())

        try #require(preChecks.count == 1)
        try #require(preParticipants.count == 2)
        try #require(preItems.count == 2)

        // Verify relationships
        try #require(soda.orderers.contains(where: { $0 === alice }))
        try #require(fries.orderers.contains(where: { $0 === bob }))
        try #require(alice.items.contains(where: { $0 === soda }))
        try #require(bob.items.contains(where: { $0 === fries }))

        try #require(check.participants.contains(where: { $0 === alice }))
        try #require(check.participants.contains(where: { $0 === bob }))
        try #require(check.items.contains(where: { $0 === soda }))
        try #require(check.items.contains(where: { $0 === fries }))

        context.delete(check)

        let remainingParticipants = try context.fetch(FetchDescriptor<Participant>())
        let remainingItems = try context.fetch(FetchDescriptor<Item>())
        let remainingChecks = try context.fetch(FetchDescriptor<Check>())

        #expect(remainingChecks.isEmpty)
        #expect(remainingParticipants.isEmpty)
        #expect(remainingItems.isEmpty)
    }

    @Test("Deleting Participant nullifies Item.orderers")
    @MainActor
    func deletingParticipantNullifies() async throws {
        let container = try makeInMemoryContainer()
        let context = container.mainContext

        let check = try Check(name: "Brunch")
        let carl = try Participant(firstName: "Carl", lastName: "M")
        let toast = Item(name: "Toast", price: 4.00)

        context.insert(check)
        check.participants.append(carl)
        try carl.addItem(toast)

        // Pre-deletion sanity checks
        let preChecks = try context.fetch(FetchDescriptor<Check>())
        let preParticipants = try context.fetch(FetchDescriptor<Participant>())
        let preItems = try context.fetch(FetchDescriptor<Item>())

        try #require(preChecks.count == 1)
        try #require(preParticipants.count == 1)
        try #require(preItems.count == 1)

        // Verify relationships before deletion
        try #require(toast.orderers.contains(where: { $0 === carl }))
        try #require(carl.items.contains(where: { $0 === toast }))
        try #require(check.participants.contains(where: { $0 === carl }))
        try #require(check.items.contains(where: { $0 === toast }))

        context.delete(carl)
        try context.save()

        let items = try context.fetch(FetchDescriptor<Item>())
        let checks = try context.fetch(FetchDescriptor<Check>())
        let participants = try context.fetch(FetchDescriptor<Participant>())

        let fetchedToast = try #require(items.first)
        let fetchedCheck = try #require(checks.first)
        #expect(participants.isEmpty)
        #expect(fetchedCheck.participants.isEmpty)
        #expect(check === fetchedCheck)
        #expect(fetchedToast.orderers.isEmpty)
        #expect(toast === fetchedToast)
    }

    @Test("Deleting Item nullifies Participant.items")
    @MainActor
    func deletingItemNullifies() async throws {
        let container = try makeInMemoryContainer()
        let context = container.mainContext

        let check = try Check(name: "Cafe")
        let dana = try Participant(firstName: "Dana", lastName: "L")
        let latte = Item(name: "Latte", price: 5.50)

        context.insert(check)
        check.participants.append(dana)
        try dana.addItem(latte)

        // Pre-deletion sanity checks
        let preChecks = try context.fetch(FetchDescriptor<Check>())
        let preParticipants = try context.fetch(FetchDescriptor<Participant>())
        let preItems = try context.fetch(FetchDescriptor<Item>())

        try #require(preChecks.count == 1)
        try #require(preParticipants.count == 1)
        try #require(preItems.count == 1)

        // Verify relationships before deletion
        try #require(latte.orderers.contains(where: { $0 === dana }))
        try #require(dana.items.contains(where: { $0 === latte }))
        try #require(check.participants.contains(where: { $0 === dana }))
        try #require(check.items.contains(where: { $0 === latte }))

        context.delete(latte) // delete rule .nullify on Participant.items inverse
        try context.save()

        let items = try context.fetch(FetchDescriptor<Item>())
        let checks = try context.fetch(FetchDescriptor<Check>())
        let participants = try context.fetch(FetchDescriptor<Participant>())

        let fetchedDana = try #require(participants.first)
        let fetchedCheck = try #require(checks.first)
        #expect(items.isEmpty)
        #expect(fetchedDana.items.isEmpty)
        #expect(check === fetchedCheck)
        #expect(dana === fetchedDana)
    }

    // MARK: - Domain utility

    @Test("Participant.getTotalCost sums Decimal prices")
    @MainActor
    func participantTotalCost() async throws {
        let container = try makeInMemoryContainer()
        let context = container.mainContext

        let check = try Check(name: "Totals")
        let eve = try Participant(firstName: "Eve", lastName: "Q")
        context.insert(check)
        check.participants.append(eve)

        let i1 = Item(name: "Item1", price: Decimal(string: "12.34")!)
        let i2 = Item(name: "Item2", price: Decimal(string: "4.56")!)

        try eve.addItem(i1)
        try eve.addItem(i2)

        // Fetch participant back and verify total
        let fetched = try #require(context.fetch(FetchDescriptor<Participant>()).first)
        let total: Decimal = fetched.getTotalCost()
        #expect(total == Decimal(string: "16.90")!)
    }
}

