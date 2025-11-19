//
//  SplashScreen.swift
//  RapidSplit
//
//  Created by Addison Hanrattie on 9/15/25.
//

import SwiftUI

struct SplashScreen: View {
    @State private var router = Router()
    @State private var showSnackbar = false
    @State private var snackbarMessage: String = ""

    enum OpenUrlError: LocalizedError, CaseIterable {
        case unknownRoute
        case failedToOpenFileManager
        case failedToBuildImage
    }

    var body: some View {
        NavigationStack(path: $router.navigationPath) {
            HomeScreen()
                .environment(router)
                .navigationDestination(for: Router.Route.self) { route in
                    switch route {
                    case .capture:
                        CaptureScreen().environment(router)
                    case .analysis(let image):
                        CheckAnalysisScreen(image: image).environment(router)
                    case .overview(let title, let items):
                        CheckOverviewScreen(title: title, items: items).environment(router)
                    case .participants(let check):
                        IdentifyParticipantsScreen(check: check, showContinue: true).environment(router)
                    case .assignment(let check):
                        ItemAssignmentScreen(check: check, showContinue: true).environment(router)
                    case .details(let check):
                        CheckDetailsScreen(check: check).environment(router)
                    }
                }
        }
        .onOpenURL { url in
            do {
                try handle(url: url)
            } catch let error {
                self.snackbarMessage = "Error: \(error.localizedDescription)"
                self.showSnackbar = true
            }
        }
    }

    private func handle(url: URL) throws {
        guard url.host == OPEN_SHARED_IMAGE_PATH else {
            throw OpenUrlError.unknownRoute
        }

        guard let container = FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: GROUP_IDENTIFIER) else {

            throw OpenUrlError.failedToOpenFileManager
        }

        let fileURL = container.appendingPathComponent(SHARED_IMAGE_FILE_NAME)

        let data = try Data(contentsOf: fileURL)
        // Attempt to delete the shared image file now that we've loaded it
        try? FileManager.default.removeItem(at: fileURL)
        
        guard let image = UIImage(data: data) else {
            throw OpenUrlError.failedToBuildImage
        }

        router.jumpToAnalysis(of: image)
    }
}

#Preview {
    SplashScreen()
}
