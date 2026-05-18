//
//  AddPlaceViewModel.swift
//  macro
//
//  Created by ghala alismael on 27/11/1447 AH.
//

import Foundation
import SwiftData

// Owns all form state for both tabs
@Observable
final class AddPlaceViewModel {

    var name: String = ""
    var neighborhood: String = ""
    var notes: String = ""
    var selectedCategory: PlaceCategory = .other
    var isVisited: Bool = false

    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    // Apply OCR output into form fields (only fills empty fields)
    func apply(ocrResult: OCRResult) {
        if name.isEmpty        { name = ocrResult.detectedName }
        if neighborhood.isEmpty { neighborhood = ocrResult.detectedNeighborhood }
        if notes.isEmpty       { notes = ocrResult.detectedNotes }
    }

    func save(context: ModelContext, imageData: Data? = nil) {
        let place = SavedPlace(
            name: name,
            neighborhood: neighborhood,
            notes: notes,
            category: selectedCategory,
            isVisited: isVisited,
            imageData: imageData
        )
        context.insert(place)
        reset()
    }

    func reset() {
        name = ""
        neighborhood = ""
        notes = ""
        selectedCategory = .other
        isVisited = false
    }
}
