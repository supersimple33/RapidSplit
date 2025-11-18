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
    private let context = CIContext()

    @State private var showSnackbar = false
    @State private var snackbarMessage: String = ""

    @State private var phase: AnalysisPhase = .setup
    @State private var statusUpdates: [String] = ["Initializing Analysis"]

    enum AnalysisPhase: Hashable {
        case setup
        case detectingText
        case runningAIAnalysis
        case buildingCheckItems
        case namingCheck

        var displayTitle: String {
            switch self {
            case .setup: return "Setting up"
            case .detectingText: return "Detecting text"
            case .runningAIAnalysis: return "Running AI analysis"
            case .buildingCheckItems: return "Building check items"
            case .namingCheck: return "Naming check"
            }
        }
    }

    private enum AnalysisError: LocalizedError {
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
            do {
                guard let ciImage = CIImage(image: image) else {
                    handleError(error: AnalysisError.failedImageConversion)
                    return
                }
                phase = .detectingText
                self.statusUpdates.append(phase.displayTitle + "...")
                try await VisionService.shared
                    .analyzeForText(image: ciImage,
                                    progressHandler: handleProgess,
                                    handleError: handleError
                    ) { recognizedStrings in
                        DispatchQueue.main.async {
                            phase = .runningAIAnalysis
                            self.statusUpdates.append(phase.displayTitle + "...")
                            self.statusUpdates.append("Detected \(recognizedStrings.count) lines of text")
                        }
                        Task {
                            await handleVisionFinished(recognizedStrings: recognizedStrings)
                        }
                    }
            } catch let err {
                print(err)
                self.snackbarMessage = "Error: \(err.localizedDescription)"
                self.showSnackbar.toggle()
            }
        }
        .snackbar(isPresented: $showSnackbar, message: snackbarMessage)
    }

    nonisolated private func handleError(error: Error) {
        DispatchQueue.main.async {
            print(error)
            self.snackbarMessage = "Error: \(error.localizedDescription)"
            self.showSnackbar.toggle()
        }
    }

    nonisolated private func handleProgess(with request: VNRequest, progress: Double, error: Error?) {
        if let error {
            handleError(error: error)
        }
        DispatchQueue.main.async {
            self.statusUpdates.append("\(Int(progress * 100))% complete processing text")
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

    nonisolated private func handleVisionFinished(recognizedStrings: [String]) async {
        guard !recognizedStrings.isEmpty else {
            handleError(error: AnalysisError.noRecognizedText)
            return
        }

        do {
            let items = try await GenerationService.shared.generateCheckStructure(
                recognizedStrings: recognizedStrings,
                onPartial: handlePartialCheck
            )
            await MainActor.run {
                self.phase = .namingCheck
                self.statusUpdates.append(phase.displayTitle + "...")
            }
            let title = try await GenerationService.shared.generateCheckTitle(recognizedStrings: recognizedStrings)
            await MainActor.run {
                router.navigateTo(route: .overview(title: title, items: items))
            }
        } catch let err {
            handleError(error: err)
        }
    }
}

#Preview {
    CheckAnalysisScreen(image: UIImage(systemName: "paintpalette")!).environment(Router())
}

