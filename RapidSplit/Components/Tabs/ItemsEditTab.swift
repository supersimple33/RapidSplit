//
//  ItemsEditTab.swift
//  RapidSplit
//
//  Created by Addison Hanrattie on 10/5/25.
//

import SwiftUI
import MaterialUIKit

struct ItemsEditTab: View {
    @Environment(Router.self) private var router

    let check: Check
    let showContinue: Bool

    var body: some View {
        Container {
            ItemsTable(check: check)
                .floatingActionButton(systemImage: "square.and.pencil", titleKey: "Add New Item") {
                    check.items.append(
                        Item(
                            name: "New Item",
                            price: 10.0,
                        )
                    )
                }
            if showContinue {
                ActionButton("Continue", style: check.items.isEmpty ? .outlineStretched : .filledStretched) {
                    router.navigateTo(route: .participants(check: check))
                }.disabled(check.items.isEmpty)
            }
        }
    }
}
