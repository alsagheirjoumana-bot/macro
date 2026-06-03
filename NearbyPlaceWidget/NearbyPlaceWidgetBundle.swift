//
//  NearbyPlaceWidgetBundle.swift
//  NearbyPlaceWidget
//
//  Created by May Alqunaytir on 02/06/2026.
//

import WidgetKit
import SwiftUI

@main
struct NearbyPlaceWidgetBundle: WidgetBundle {
    var body: some Widget {
        NearbyPlaceWidget()
        NearbyPlaceWidgetControl()
        NearbyPlaceWidgetLiveActivity()
    }
}
