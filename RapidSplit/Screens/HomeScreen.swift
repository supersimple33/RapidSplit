//
//  HomeScreen.swift
//  RapidSplit
//
//  Created by Addison Hanrattie on 9/10/25.
//

import SwiftUI
import MaterialUIKit

struct HomeScreen: View {
    @State private var model = TableOptions()
    @Environment(Router.self) private var router

    var body: some View {
        Container {
            VStack(spacing: 16) {
                ChecksTable(model, navigateToCheck: { check in
                    router.navigateTo(route: .details(check: check))
                })
                Text("This app uses AI to identify categorize and price items. Always double check outputs before splitting.")
                    .font(.caption)
                    .multilineTextAlignment(.center)
                ActionButton("Split New Receipt", style: .filledStretched) {
                    router.navigateTo(route: .capture)
                }
            }
        }
        .navigationTitle("Receipts")
    }
}

#if DEBUG
#Preview {
    return HomeScreen()
        .environment(Router())
        .modelContainer(DataController.previewContainer)
}
#endif
