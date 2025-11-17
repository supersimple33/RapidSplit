//
//  IdentifyParticipantsScreen.swift
//  RapidSplit
//
//  Created by Addison Hanrattie on 9/24/25.
//

import SwiftUI
import SwiftData
import MaterialUIKit
import Contacts

struct IdentifyParticipantsScreen: View {
    @Environment(Router.self) private var router

    let check: Check
    let showContinue: Bool

    @State private var showContactPicker: Bool = false
    @State private var showParticipantBuilder: Bool = false

    @State private var newFirstName = ""
    @State private var newLastName = ""
    @State private var newPhoneNumber = ""

    @State private var showSnackbar = false
    @State private var snackbarMessage: String = ""

    private enum IdentifyParticipantsError: LocalizedError {
        case regionNotSet

        var errorDescription: String {
            switch self {
            case .regionNotSet:
                return "No region is set for the current locale."
            }
        }
    }

    var body: some View {
        Container {
            ActionButton("Import from Contacts", style: .tonalStretched) {
                self.showContactPicker = true
            }
            ParticipantsTable(check: check)
            ActionButton("Manually Add", style: .tonalStretched) {
                self.newFirstName = ""
                self.newLastName = ""
                self.newPhoneNumber = ""
                self.showParticipantBuilder = true
            }
            if showContinue {
                ActionButton("Continue", style: check.participants.isEmpty ? .outlineStretched : .filledStretched) {
                    do {
                        for participant in check.participants {
                            try participant.validate()
                        }
                        router.navigateTo(route: .assignment(check: check))
                    } catch let error {
                        self.showSnackbar = true
                        self.snackbarMessage = error.localizedDescription
                    }
                }.disabled(check.participants.isEmpty)
            }
        }
        .dialogSheet(isPresented: $showParticipantBuilder, {
            VStack {
                TextBox(systemImage: "person.fill", "Enter First Name*", text: $newFirstName)
                TextBox(systemImage: "person.fill", "Enter Last Name*", text: $newLastName)
                TextBox(systemImage: "phone.fill", "Enter Phone Number", text: $newPhoneNumber)
                ActionButton(
                    "Add Participant",
                    style: newFirstName
                        .trimmingCharacters(in: .whitespacesAndNewlines) != "" && newLastName
                        .trimmingCharacters(in: .whitespacesAndNewlines) != "" ? .filledStretched : .outlineStretched
                ) {
                    let phoneNumber = newPhoneNumber.trimmingCharacters(in: .whitespacesAndNewlines)
                    self.showParticipantBuilder = false
                    do {
                        check.participants.append(try Participant(
                            firstName: newFirstName,
                            lastName: newLastName,
                            phoneNumber: phoneNumber == "" ? nil : phoneNumber,
                        ))
                    } catch let error {
                        self.showSnackbar = true
                        self.snackbarMessage = error.localizedDescription
                    }
                }.disabled(newFirstName.trimmingCharacters(in: .whitespacesAndNewlines) == ""
                           || newLastName.trimmingCharacters(in: .whitespacesAndNewlines) == "")
            }
        })
        .contactPicker(isPresented: $showContactPicker, onDismiss: nil) { (contact, contactProperty) in
            do {
                if let contactProperty, let phoneNumber = contactProperty.value as? CNPhoneNumber {
                    check.participants.append(try Participant(
                        firstName: contact.givenName,
                        lastName: contact.familyName,
                        phoneNumber: phoneNumber.stringValue,
                    ))
                } else if let phoneNumber = contact.phoneNumbers.first?.value {
                    check.participants.append(try Participant(
                        firstName: contact.givenName,
                        lastName: contact.familyName,
                        phoneNumber: phoneNumber.stringValue,
                    ))
                } else {
                    check.participants.append(try Participant(
                        firstName: contact.givenName,
                        lastName: contact.familyName,
                    ))
                }
            } catch let error {
                print(error)
                self.showSnackbar = true
                self.snackbarMessage = error.localizedDescription
            }
        }
        .snackbar(isPresented: $showSnackbar, message: snackbarMessage)
    }
}

#Preview {
    // Build a context from the preview container
    let container = DataController.previewContainer
    let context = container.mainContext

    // Try to fetch a single Check
    var descriptor = FetchDescriptor<Check>()
    descriptor.fetchLimit = 1
    descriptor.sortBy = [SortDescriptor(\Check.name, order: .forward)]
    let fetchedCheck = try! context.fetch(descriptor).first!

    return IdentifyParticipantsScreen(check: fetchedCheck, showContinue: true)
        .environment(Router())
        .modelContainer(container)
}
