//
//  AddPlaceViewModel.swift
//  macro
//
//  Created by ghala alismael on 27/11/1447 AH.
//
import Foundation
import SwiftData

@Observable
final class AddPlaceViewModel {

    var name: String = ""
    var neighborhood: String = ""
    var notes: String = ""
    var selectedCategory: PlaceCategory = .other
    var isVisited: Bool = false
    
    var latitude: Double?
    var longitude: Double?
    var address: String = ""

    var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    func apply(ocrResult: OCRResult) {
        if name.isEmpty { name = ocrResult.detectedName }
        if neighborhood.isEmpty { neighborhood = ocrResult.detectedNeighborhood }
        if notes.isEmpty { notes = ocrResult.detectedNotes }
    }

    func save(context: ModelContext, imageData: Data? = nil) {

        let place = SavedPlace(
            name: name,
            neighborhood: neighborhood,
            notes: notes,
            category: selectedCategory,
            isVisited: isVisited,
            imageData: imageData,
            latitude: latitude,
            longitude: longitude,
            address: address
        )

        context.insert(place)

        do {
            try context.save()
        } catch {
            print("Save failed:", error)
        }

        reset()
    }

    func reset() {
        name = ""
        neighborhood = ""
        notes = ""
        selectedCategory = .other
        isVisited = false
        latitude = nil
        longitude = nil
        address = ""
    }
}
