//
//  PlaceModels.swift.swift
//  macro
//
//  Created by ghala alismael on 01/12/1447 AH.
//

import Foundation
import SwiftData

// MARK: - OCR Result

struct OCRResult: Equatable {

    var rawText: String
    var detectedName: String
    var detectedNeighborhood: String
    var detectedNotes: String

    static let empty = OCRResult(
        rawText: "",
        detectedName: "",
        detectedNeighborhood: "",
        detectedNotes: ""
    )
}

// MARK: - Place Category

enum PlaceCategory: String, Codable, CaseIterable, Identifiable {

    case cafe       = "Cafe"
    case restaurant = "Restaurant"
    case shop   = "Shop"
    case other      = "Other"

    var id: String { rawValue }

    var emoji: String {

        switch self {

        case .cafe:
            return "☕️"

        case .restaurant:
            return "🍽️"

        case .shop:
            return "🛍️"

        case .other:
            return "📍"
        }
    }
}

// MARK: - Saved Place

@Model
final class SavedPlace {

    var id: UUID
    var name: String
    var neighborhood: String
    var notes: String
    var categoryRaw: String
    var isVisited: Bool
    var createdAt: Date
    var imageData: Data?
    var latitude: Double?
    var longitude: Double?
    var address: String
    

    init(
        name: String,
        neighborhood: String = "",
        notes: String = "",
        category: PlaceCategory = .other,
        isVisited: Bool = false,
        imageData: Data? = nil,
        latitude: Double? = nil,
        longitude: Double? = nil,
        address: String = ""
    ) {
        self.id = UUID()
        self.name = name
        self.neighborhood = neighborhood
        self.notes = notes
        self.categoryRaw = category.rawValue
        self.isVisited = isVisited
        self.createdAt = Date()
        self.imageData = imageData
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
    }

    var category: PlaceCategory {
        PlaceCategory(rawValue: categoryRaw) ?? .other
    }
}

// MARK: - Text Extractor

struct TextExtractor {

    static func extract(from lines: [String]) -> OCRResult {

        let fullText = lines.joined(separator: "\n")

        let name = lines.first(where: {
            !$0.trimmingCharacters(in: .whitespaces).isEmpty
        }) ?? ""

        let neighborhood = lines.dropFirst().first(where: {

            $0.count > 3 &&
            $0.count < 50 &&
            !$0.contains("http") &&
            !$0.contains("@")

        }) ?? ""

        let notes = lines
            .dropFirst(2)
            .joined(separator: " ")

        return OCRResult(
            rawText: fullText,
            detectedName: name,
            detectedNeighborhood: neighborhood,
            detectedNotes: notes
        )
    }
}
