//
//  ItemsEditTab.swift
//  RapidSplit
//
//  Created by Addison Hanrattie on 10/5/25.
//

import SwiftUI
import MaterialUIKit

struct ItemsEditTab: View {
    let check: Check

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
        }
    }
}
