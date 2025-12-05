//
//  CheckAnalysisScreen.swift
//  RapidSplit
//
//  Created by Addison Hanrattie on 9/13/25.
//

import SwiftUI
import Vision
import MaterialUIKit
import FoundationModels

struct CheckAnalysisScreen: View {
    @Environment(Router.self) private var router

    let image: UIImage

    @State private var showSnackbar = false
    @State private var snackbarMessage: String = ""

    @State private var phase: AnalysisPhase = .setup
    @State private var statusUpdates: [String] = ["Initializing Analysis", AnalysisPhase.setup.displayTitle, "is CI: \(IS_RUNNING_CI)"]

    enum AnalysisPhase: Hashable {
        case setup
        case detectingText
        case runningAIAnalysis
        case buildingCheckItems
        case namingCheck
        case error

        var displayTitle: String {
            switch self {
            case .setup: return "Setting up"
            case .detectingText: return "Detecting text"
            case .runningAIAnalysis: return "Running AI analysis"
            case .buildingCheckItems: return "Building check items"
            case .namingCheck: return "Naming check"
            case .error: return "Encountered an error"
            }
        }
    }

    enum AnalysisError: LocalizedError, CaseIterable {
        case noRecognizedText
        case failedImageConversion

        var errorDescription: String? {
            switch self {
            case .noRecognizedText:
                return "No text was detected in the image."
            case .failedImageConversion:
                return "Failed to convert image to a format that Vision can process."
            }
        }
    }

    var body: some View {
        Container {
            VStack(spacing: 16) {
                ProgressBar(lineWidth: 5)
                Text(phase.displayTitle)
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            Image(uiImage: image).resizable().aspectRatio(contentMode: .fit)
            Text(statusUpdates.joined(separator: "\n"))
        }
        .task {
            await runAnalysis()
        }
        .snackbar(isPresented: $showSnackbar, message: snackbarMessage)
    }

    private func runAnalysis() async {
        do {
            // Check conversion
            guard let ciImage = CIImage(image: image) else {
                throw AnalysisError.failedImageConversion
            }

            // Begin Image Recognition
            self.setPhase(.detectingText)
            let recognizedStrings = try await VisionService.shared.analyzeForText(image: ciImage)

            // Check recognition success
            self.statusUpdates.append("Detected \(recognizedStrings.count) lines of text")
            guard !recognizedStrings.isEmpty else {
                throw AnalysisError.noRecognizedText
            }

            // Begin AI Analysis
            self.setPhase(.runningAIAnalysis)
            let items = try await GenerationService.shared.generateCheckStructure(
                recognizedStrings: recognizedStrings,
                onPartial: handlePartialCheck
            )
            self.statusUpdates.append("Generated \(items.count) check items from scan")

            // Make a name
            self.setPhase(.namingCheck)
            let title = try await GenerationService.shared.generateCheckTitle(recognizedStrings: recognizedStrings)

            // Finish
            router.navigateTo(route: .overview(title: title, items: items))
        } catch let err {
            self.statusUpdates.append("Error: \(err.localizedDescription)")
            self.phase = .error
            self.snackbarMessage = "Error: \(err.localizedDescription)"
            self.showSnackbar = true
        }
    }

    nonisolated private func handlePartialCheck(partialItems: [GeneratedItem.PartiallyGenerated], rawContent: GeneratedContent) async {
        if !partialItems.isEmpty {
            await MainActor.run {
                self.phase = .buildingCheckItems
                self.statusUpdates.append(rawContent.jsonString)
            }
        }
    }

    private func setPhase(_ newPhase: AnalysisPhase) {
        self.phase = newPhase
        self.statusUpdates.append(newPhase.displayTitle + "...")
    }
}

#Preview {
    CheckAnalysisScreen(image: UIImage(systemName: "paintpalette")!).environment(Router())
}

