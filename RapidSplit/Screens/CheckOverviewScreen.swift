//
//  CheckOverviewScreen.swift
//  RapidSplit
//
//  Created by Addison Hanrattie on 9/22/25.
//

import SwiftUI
import MaterialUIKit

struct CheckOverviewScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(Router.self) private var router

    let title: String
    let items: [GeneratedItem]

    @State private var check: Check?

    @State private var showSnackbar = false
    @State private var snackbarMessage: String = ""

    var body: some View {
        Group {
            if let check {
                ItemsEditTab(check: check)
            } else {
                ProgressBar()
                Text("Building check...")
            }
        }
        .task {
            do {
                self.check = try Check(name: title)
            } catch let error {
                print(error)
                self.snackbarMessage = error.localizedDescription
                self.showSnackbar = true
                return // TODO: this should push to a chat screen
            }

            modelContext.insert(self.check!)

            for generatedItem in items {
                if generatedItem.quantity == 1 {
                    self.check!.items.append(Item(from: generatedItem))
                } else {
                    for i in 1...generatedItem.quantity {
                        self.check!.items.append(
                            Item(
                                name: generatedItem.name + " #\(i)/\(generatedItem.quantity)",
                                price: generatedItem.price / Decimal(generatedItem.quantity),
                            )
                        )
                    }
                }
            }
        }
        .snackbar(isPresented: $showSnackbar, message: snackbarMessage)
    }
}

#Preview {
    CheckOverviewScreen(title: "Lunch", items: [
        GeneratedItem(name: "Burger", price: 200, quantity: 1),
        GeneratedItem(name: "Salad", price: 100, quantity: 2),
        GeneratedItem(name: "Salad", price: 50, quantity: 2),
    ])
    .environment(Router())
    .modelContainer(for: [Check.self, Item.self])
}
