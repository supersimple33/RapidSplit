//
//  CheckDetailsScreen.swift
//  RapidSplit
//
//  Created by Addison Hanrattie on 9/11/25.
//

import SwiftUI
import SwiftData
import MaterialUIKit

struct CheckDetailsScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(Router.self) private var router

    var check: Check

    @State private var showDialogSheet = false
    @State private var selectedParticipant: Participant?
    @State private var selectedTab: TabBarItem = Tab.payout.tabBarItem

    @State private var showSnackbar = false
    @State private var snackbarMessage: String = ""

    fileprivate enum Tab: String {
        case payout = "Payout"
        case items = "Items"
        case participants = "Participants"
        case assignment = "Assignment"

        var systemImage: String {
            switch self {
            case .payout: return "house.fill"
            case .items: return "list.bullet.rectangle"
            case .participants: return "person.2"
            case .assignment: return "mail.and.text.magnifyingglass"
            }
        }

        var tabBarItem: TabBarItem {
            TabBarItem(systemImage: systemImage, titleKey: rawValue)
        }
    }

    var body: some View {
        TabBar(selection: $selectedTab, usesVerticalLayout: true) {
            PayoutsTab(check: check)
                .tabBarItem(tab: .payout, selection: $selectedTab)
            ItemsEditTab(check: check)
                .tabBarItem(tab: .items, selection: $selectedTab)
            IdentifyParticipantsScreen(check: check, showContinue: false)
                .tabBarItem(tab: .participants, selection: $selectedTab)
            ItemAssignmentScreen(check: check, showContinue: false)
                .tabBarItem(tab: .assignment, selection: $selectedTab)
        }
        .snackbar(isPresented: $showSnackbar, message: snackbarMessage)
        .task(id: selectedTab) {
            do {
                try modelContext.save()
            } catch let error {
                snackbarMessage = "Failed to save changes: \(error.localizedDescription)"
                showSnackbar = true
            }
        }
    }
}

fileprivate extension View {
    func tabBarItem(tab: CheckDetailsScreen.Tab, selection: Binding<TabBarItem>) -> some View {
        return self.tabBarItem(systemImage: tab.systemImage, titleKey: tab.rawValue, selection: selection)
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
    let fetchedCheck = try! context.fetch(descriptor).first

    return CheckDetailsScreen(check: fetchedCheck!)
        .environment(Router())
        .modelContainer(container)
}
