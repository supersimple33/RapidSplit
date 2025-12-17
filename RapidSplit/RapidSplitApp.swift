//
//  RapidSplitApp.swift
//  RapidSplit
//
//  Created by Addison Hanrattie on 9/6/25.
//

import SwiftUI
import SwiftData
import MaterialUIKit

fileprivate let AUTO_LOCALE = Locale.autoupdatingCurrent
func getCurrencyCode() -> String {
    return AUTO_LOCALE.currency?.identifier ?? "USD"
}

@main
struct RapidSplitApp: App {
    let containerResult: Result<ModelContainer, SwiftDataError>

    @State private var showAlert: Bool = false

    var body: some Scene {
        WindowGroup {
            switch containerResult {
            case .success(let modelContainer):
                SplashScreen()
                    .modelContainer(modelContainer)
            case .failure(let error):
                Text("Error loading data store")
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Error loading data store"),
                            message: Text(error.localizedDescription),
                            dismissButton: .default(Text("OK"))
                        )
                    }
            }
        }
    }

    init() {
//        MaterialUIKit.configuration.borderWidth = 2.0

        // Build a dedicated model container value for the app
        let schema = Schema(Check.self, Item.self, Participant.self, version: SCHEMA_VERSION)
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

#if DEBUG
        if CommandLine.arguments.contains(LaunchArguments.reset.rawValue) ||
           CommandLine.arguments.contains(LaunchArguments.seed.rawValue) {
            let tempContainer = try! ModelContainer(for: schema, configurations: modelConfiguration)
            try! tempContainer.erase()
        }
#endif

        do {
            let container = try ModelContainer(for: schema,
                                                     configurations: modelConfiguration)
            container.mainContext.autosaveEnabled = false

#if DEBUG
            if CommandLine.arguments.contains(LaunchArguments.seed.rawValue) {
                try! DataController.seed(context: container.mainContext)
            }
#endif
            
            self.containerResult = .success(container)
        } catch let error as SwiftDataError {
            self.showAlert = true
            self.containerResult = .failure(error)
        } catch let error {
            fatalError(error.localizedDescription)
        }
    }
}
