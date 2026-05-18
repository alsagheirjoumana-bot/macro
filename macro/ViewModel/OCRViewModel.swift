//
//  OCRViewModel.swift
//  macro
//
//  Created by ghala alismael on 27/11/1447 AH.
//

import Vision
import UIKit

// Owns all OCR state and Vision framework usage
@Observable
final class OCRViewModel {

    var selectedImage: UIImage? = nil { didSet { ocrDidRun = false } }
    var isProcessing: Bool = false
    var ocrDidRun: Bool = false
    var showImagePicker: Bool = false
    var result: OCRResult = .empty

    func runOCR() {
        guard let image = selectedImage,
              let cgImage = image.cgImage else { return }

        isProcessing = true
        result = .empty

        let request = VNRecognizeTextRequest { [weak self] req, _ in
            let lines = (req.results as? [VNRecognizedTextObservation] ?? [])
                .compactMap { $0.topCandidates(1).first?.string }

            DispatchQueue.main.async {
                self?.result = TextExtractor.extract(from: lines)
                self?.isProcessing = false
                self?.ocrDidRun = true
            }
        }
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        DispatchQueue.global(qos: .userInitiated).async {
            try? VNImageRequestHandler(cgImage: cgImage).perform([request])
        }
    }

    func reset() {
        selectedImage = nil
        result = .empty
        ocrDidRun = false
    }
}
