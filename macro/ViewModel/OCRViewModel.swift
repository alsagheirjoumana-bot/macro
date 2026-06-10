import Vision
import UIKit
import CoreImage

@Observable
final class OCRViewModel {

    var selectedImage: UIImage? = nil {
        didSet { ocrDidRun = false }
    }

    var isProcessing: Bool = false
    var ocrDidRun: Bool = false
    var showImagePicker: Bool = false
    var result: OCRResult = .empty

    func runOCR() {
        guard let image = selectedImage else { return }

        isProcessing = true
        result = .empty

        let processedImage = preprocessImage(image)

        guard let cgImage = processedImage.cgImage else {
            isProcessing = false
            return
        }

        let request = VNRecognizeTextRequest { [weak self] request, error in

            let observations = request.results as? [VNRecognizedTextObservation] ?? []

            let lines = observations.compactMap { observation in
                observation.topCandidates(3).first?.string
            }

            DispatchQueue.main.async {
                self?.result = TextExtractor.extract(from: lines)
                self?.isProcessing = false
                self?.ocrDidRun = true
            }
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = [
            "en-US",
            "ar-SA"
        ]
        request.minimumTextHeight = 0.015

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try VNImageRequestHandler(
                    cgImage: cgImage,
                    orientation: CGImagePropertyOrientation(image.imageOrientation)
                ).perform([request])
            } catch {
                DispatchQueue.main.async {
                    self.isProcessing = false
                    self.ocrDidRun = true
                }
            }
        }
    }

    private func preprocessImage(_ image: UIImage) -> UIImage {

        guard let ciImage = CIImage(image: image) else {
            return image
        }

        let filter = CIFilter(name: "CIColorControls")
        filter?.setValue(ciImage, forKey: kCIInputImageKey)
        filter?.setValue(1.15, forKey: kCIInputContrastKey)
        filter?.setValue(0.05, forKey: kCIInputBrightnessKey)
        filter?.setValue(0.0, forKey: kCIInputSaturationKey)

        guard let output = filter?.outputImage else {
            return image
        }

        let context = CIContext()

        guard let cgImage = context.createCGImage(output, from: output.extent) else {
            return image
        }

        return UIImage(
            cgImage: cgImage,
            scale: image.scale,
            orientation: image.imageOrientation
        )
    }

    func reset() {
        selectedImage = nil
        result = .empty
        ocrDidRun = false
    }
}

extension CGImagePropertyOrientation {

    init(_ orientation: UIImage.Orientation) {
        switch orientation {
        case .up:
            self = .up
        case .down:
            self = .down
        case .left:
            self = .left
        case .right:
            self = .right
        case .upMirrored:
            self = .upMirrored
        case .downMirrored:
            self = .downMirrored
        case .leftMirrored:
            self = .leftMirrored
        case .rightMirrored:
            self = .rightMirrored
        @unknown default:
            self = .up
        }
    }
}
