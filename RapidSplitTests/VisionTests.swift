//
//  VisionTests.swift
//  RapidSplitTests
//
//  Created by Addison Hanrattie on 9/29/25.
//

import Testing
@testable import RapidSplit
import UIKit
import CoreImage

struct VisionTests {

    @Test("Text Recognition", arguments: [
        ([], CGSize(width: 800, height: 600)),
        (["HELLO World 123"], CGSize(width: 800, height: 300)),
        (["HELLO", "World", "12.3"], CGSize(width: 800, height: 600)),
        (["Receipt split", "is a", "fun app."], CGSize(width: 800, height: 300)),
    ])
    func testRecognizesSimpleText(lines: [String], size: CGSize) async throws {
        // Precondition: ensure test input lines are single-line and trimmed
        for (index, line) in lines.enumerated() {
            let hasNewlines = line.rangeOfCharacter(from: .newlines) != nil
            try #require(!hasNewlines, "Test input line \(index) contains newline characters")

            let trimmed = line.trimmingCharacters(in: .whitespaces)
            try #require(trimmed == line, "Test input line \(index) has leading/trailing whitespace; please trim it.")
        }

        // Arrange: Create a high-contrast image with predictable text
        let uiImage = makeTestImage(with: lines, size: size)
        let ciImage = try #require(CIImage(image: uiImage), "Failed to create CIImage from test image")



        // Act: Bridge the completion handler API to async/await
        let recognized: [String] = try await withCheckedThrowingContinuation { continuation in
            Task {
                do {
                    try await VisionService.shared.analyzeForText(
                        image: ciImage,
                        progressHandler: nil,
                        handleError: { error in
                            continuation.resume(throwing: error)
                        },
                        completion: { strings in
                            continuation.resume(returning: strings)
                        }
                    )
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }

        // Assert: Recognized text should contain all expected lines
        #expect(recognized.count == lines.count, "Recognized lines mismatch \(recognized.count) != \(lines.count)")
        for (line, expected) in zip(lines, recognized) {
            #expect(line == expected, "Expected recognized text to contain '\(expected)' but got \(recognized)")
        }
    }

    // MARK: - Helpers

    private func makeTestImage(with lines: [String], size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            // White background
            UIColor.white.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))

            // Draw black text centered, possibly multiple lines
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .center

            // Choose a font size that fits all lines comfortably
            let baseFontSize: CGFloat = 96
            let lineCount = max(lines.count, 1)
            let tentativeLineHeight = baseFontSize * 1.2
            // If the text might not fit vertically, scale the font down
            let maxTotalHeight = size.height * 0.9
            let scale = min(1.0, maxTotalHeight / (tentativeLineHeight * CGFloat(lineCount)))
            let fontSize = max(12, baseFontSize * scale)
            let lineHeight = fontSize * 1.2

            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: fontSize, weight: .bold),
                .foregroundColor: UIColor.black,
                .paragraphStyle: paragraph
            ]

            // Compute a starting Y that centers the block of lines vertically
            let totalHeight = lineHeight * CGFloat(lineCount)
            var currentY = (size.height - totalHeight) / 2

            for line in lines {
                let rect = CGRect(x: 0, y: currentY, width: size.width, height: lineHeight)
                (line as NSString).draw(in: rect, withAttributes: attributes)
                currentY += lineHeight
            }
        }
    }
}

