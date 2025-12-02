//
//  VisionService.swift
//  RapidSplit
//
//  Created by Addison Hanrattie on 9/22/25.
//

import Foundation
import Vision
import CoreImage
import UIKit

actor VisionService {
    static let shared = VisionService()

    private init() { }

    func analyzeForText(
        image: CIImage,
        orientation: CGImagePropertyOrientation? = nil,
    ) async throws -> [String] {
        var request = RecognizeTextRequest()
        request.recognitionLevel = .accurate

        let result = try await request.perform(on: image, orientation: orientation)

        return result.map { observation in
            // TODO: we can do some more clever stuff here
            // Return the string of the top RecognizedTextObservation instance.
            return observation.topCandidates(1).first?.string ?? ""
        }
    }
}

extension CGImagePropertyOrientation {
    init(_ uiOrientation: UIImage.Orientation) {
        switch uiOrientation {
            case .up: self = .up
            case .upMirrored: self = .upMirrored
            case .down: self = .down
            case .downMirrored: self = .downMirrored
            case .left: self = .left
            case .leftMirrored: self = .leftMirrored
            case .right: self = .right
            case .rightMirrored: self = .rightMirrored
        @unknown default:
            fatalError()
        }
    }
}
