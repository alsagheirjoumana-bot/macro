//
//  LocationStore.swift
//  macro
//
//  Created by May Alqunaytir on 02/06/2026.
//


import Foundation
import CoreLocation

enum LocationStore {

    static let defaults = UserDefaults(
        suiteName: "group.com.reemaa.macro"
    )

    static func save(
        coordinate: CLLocationCoordinate2D
    ) {
        defaults?.set(
            coordinate.latitude,
            forKey: "lastLatitude"
        )

        defaults?.set(
            coordinate.longitude,
            forKey: "lastLongitude"
        )
    }
}
