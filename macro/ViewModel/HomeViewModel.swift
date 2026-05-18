//
//  HomeViewModel.swift
//  macro
//
//  Created by ghala alismael on 27/11/1447 AH.
//

import Foundation
import SwiftData

@Observable
final class HomeViewModel {
    // List filtering state (extend later for search/filter)
    var searchText: String = ""
    var filterVisited: Bool = false

    func delete(_ place: SavedPlace, from context: ModelContext) {
        context.delete(place)
    }

    func filtered(_ places: [SavedPlace]) -> [SavedPlace] {
        places.filter { place in
            let matchesSearch = searchText.isEmpty ||
                place.name.localizedCaseInsensitiveContains(searchText)
            let matchesVisited = !filterVisited || place.isVisited
            return matchesSearch && matchesVisited
        }
    }
}
