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

        let cleanedLines = lines
            .map { clean($0) }
            .filter { !$0.isEmpty }

        let usefulLines = cleanedLines
            .filter { !isJunkLine($0) }

        let fullText = lines.joined(separator: "\n")

        let name = bestPlaceName(from: usefulLines)
        let neighborhood = bestNeighborhood(from: usefulLines, excluding: name)

        let notes = usefulLines
            .filter { $0 != name && $0 != neighborhood }
            .joined(separator: " ")

        return OCRResult(
            rawText: fullText,
            detectedName: name,
            detectedNeighborhood: neighborhood,
            detectedNotes: notes
        )
    }

    private static func bestPlaceName(from lines: [String]) -> String {

        let scored = lines.map { line in
            (line: line, score: placeNameScore(line))
        }

        return scored
            .sorted { $0.score > $1.score }
            .first?.line ?? ""
    }

    private static func bestNeighborhood(
        from lines: [String],
        excluding name: String
    ) -> String {

        let scored = lines
            .filter { $0 != name }
            .map { line in
                (line: line, score: neighborhoodScore(line))
            }

        return scored
            .sorted { $0.score > $1.score }
            .first?.line ?? ""
    }

    private static func placeNameScore(_ line: String) -> Int {

        let lower = line.lowercased()
        let words = line.split(separator: " ")
        var score = 0

        if hasLetters(line) { score += 20 }
        if line.count >= 2 && line.count <= 25 { score += 25 }
        if words.count <= 4 { score += 20 }
        if line == line.uppercased() && hasLetters(line) { score += 35 }

        let placeWords = [
            "cafe", "coffee", "restaurant", "bakery", "roasters",
            "zuma", "dunkin", "starbucks", "burger", "pizza",
            "مطعم", "كافيه", "قهوة", "كوفي", "مقهى"
        ]

        if placeWords.contains(where: { lower.contains($0) }) {
            score += 30
        }

        if looksLikeSentence(line) { score -= 40 }
        if containsMostlyNumbers(line) { score -= 60 }
        if lower.contains("riyadh") || lower.contains("الرياض") { score -= 10 }
        if lower.contains("street") || lower.contains("شارع") { score -= 15 }

        return score
    }

    private static func neighborhoodScore(_ line: String) -> Int {

        let lower = line.lowercased()
        var score = 0

        if hasLetters(line) { score += 10 }
        if line.count >= 4 && line.count <= 70 { score += 15 }

        let neighborhoodWords = [
            "riyadh", "الرياض", "district", "street", "road",
            "شارع", "طريق", "حي", "العليا", "الملقا", "النخيل"
        ]

        if neighborhoodWords.contains(where: { lower.contains($0) }) {
            score += 30
        }

        if looksLikeSentence(line) { score -= 20 }
        if containsMostlyNumbers(line) { score -= 50 }

        return score
    }

    private static func isJunkLine(_ line: String) -> Bool {

        let lower = line.lowercased()
        let trimmed = clean(line)

        if trimmed.isEmpty { return true }

        if trimmed.range(of: #"^\d{1,2}:\d{2}$"#, options: .regularExpression) != nil {
            return true
        }

        if trimmed.range(of: #"^\d+\s*/\s*\d+$"#, options: .regularExpression) != nil {
            return true
        }

        if trimmed.range(of: #"^\d+(\.\d+)?k$"#, options: [.regularExpression, .caseInsensitive]) != nil {
            return true
        }

        if trimmed.range(of: #"^\d+$"#, options: .regularExpression) != nil {
            return true
        }

        let junkWords = [
            "search",
            "find related content",
            "add comment",
            "see translation",
            "photo",
            "part",
            "like",
            "comment",
            "share",
            "following",
            "for you",
            "followers",
            "likes",
            "views",
            "reply",
            "sound",
            "original sound",
            "منشور",
            "تعليق",
            "إعجاب",
            "متابعة"
        ]

        if junkWords.contains(where: { lower.contains($0) }) {
            return true
        }

        if lower.contains("@") || lower.contains("http") {
            return true
        }

        return false
    }

    private static func looksLikeSentence(_ line: String) -> Bool {
        line.split(separator: " ").count > 5
    }

    private static func hasLetters(_ line: String) -> Bool {
        line.rangeOfCharacter(from: .letters) != nil
    }

    private static func containsMostlyNumbers(_ line: String) -> Bool {
        let digits = line.filter { $0.isNumber }.count
        return digits > line.count / 2
    }

    private static func clean(_ text: String) -> String {
        text
            .replacingOccurrences(of: "•", with: " ")
            .replacingOccurrences(of: "|", with: " ")
            .replacingOccurrences(of: "٪", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
