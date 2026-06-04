//
//  NearbyPlaceWidget.swift
//  NearbyPlaceWidget
//
//  Created by May Alqunaytir on 02/06/2026.
//

import WidgetKit
import SwiftUI
import SwiftData
import CoreLocation


func loadPlaces() -> [WidgetPlace] {

    do {

        let schema = Schema([
            SavedPlace.self
        ])

        let storeURL = FileManager.default
            .containerURL(
                forSecurityApplicationGroupIdentifier: "group.com.may.macro"
            )!
            .appendingPathComponent("Macro.sqlite")

        let configuration = ModelConfiguration(
            schema: schema,
            url: storeURL
        )

        let container = try ModelContainer(
            for: schema,
            configurations: [configuration]
        )

        let context = ModelContext(container)

        let places = try context.fetch(
            FetchDescriptor<SavedPlace>()
        )

        return buildWidgetPlaces(from: places)

    } catch {

        print("Widget fetch failed:", error)
        return []
    }
}

func buildWidgetPlaces(
    from places: [SavedPlace]
) -> [WidgetPlace] {

    let unvisited = places.filter {
        !$0.isVisited
    }

    let defaults = UserDefaults(
        suiteName: "group.com.may.macro"
    )

    let latitude = defaults?.object(
        forKey: "lastLatitude"
    ) as? Double

    let longitude = defaults?.object(
        forKey: "lastLongitude"
    ) as? Double

    if let latitude,
       let longitude {

        let userLocation = CLLocation(
            latitude: latitude,
            longitude: longitude
        )

        let nearbyPlaces = unvisited.compactMap { place -> (SavedPlace, Double)? in

            guard let lat = place.latitude,
                  let lon = place.longitude else {
                return nil
            }

            let distance = CLLocation(
                latitude: lat,
                longitude: lon
            )
            .distance(from: userLocation)

            return (place, distance)
        }

        var selected: [(SavedPlace, Double)] = []

        for category in [
            PlaceCategory.cafe,
            PlaceCategory.restaurant,
            PlaceCategory.shopping
        ] {

            if let nearest = nearbyPlaces
                .filter({ $0.0.category == category })
                .min(by: { $0.1 < $1.1 }) {

                selected.append(nearest)
            }
        }
        
        let selectedIDs = Set(
            selected.map { $0.0.id }
        )

        let remaining = nearbyPlaces
            .filter {
                !selectedIDs.contains($0.0.id)
            }
            .sorted {
                $0.1 < $1.1
            }

        selected.append(
            contentsOf:
            remaining.prefix(
                max(0, 3 - selected.count)
            )
        )

        return selected.prefix(3).map {

            WidgetPlace(
                name: $0.0.name,
                emoji: $0.0.category.emoji,
                distance: $0.1
            )
        }
    }

    var selected: [SavedPlace] = []

    if let cafe = unvisited.first(where: {
        $0.category == .cafe
    }) {
        selected.append(cafe)
    }

    if let restaurant = unvisited.first(where: {
        $0.category == .restaurant
    }) {
        selected.append(restaurant)
    }

    if let shopping = unvisited.first(where: {
        $0.category == .shopping
    }) {
        selected.append(shopping)
    }

    let remaining = unvisited
        .filter { place in
            !selected.contains {
                $0.id == place.id
            }
        }
        .shuffled()

    selected.append(
        contentsOf:
        remaining.prefix(
            max(0, 3 - selected.count)
        )
    )

    return selected.prefix(3).map {

        WidgetPlace(
            name: $0.name,
            emoji: $0.category.emoji,
            distance: nil
        )
    }
}


struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {

        SimpleEntry(
            date: Date(),
            title: "Nearby Saved Places",
            places: [
                WidgetPlace(name: "Cafe", emoji: "☕️", distance: 120),
                WidgetPlace(name: "Restaurant", emoji: "🍽️", distance: 300),
                WidgetPlace(name: "Shopping", emoji: "🛍️", distance: 700)
            ]
        )
    }

    func getSnapshot(
        in context: Context,
        completion: @escaping (SimpleEntry) -> ()
    ) {

        let places = loadPlaces()

        let entry = SimpleEntry(
            date: Date(),
            title: places.isEmpty
                ? "No Saved Places"
                : "Nearby Saved Places",
            places: places
        )
        
        completion(entry)
    }

    func getTimeline(
        in context: Context,
        completion: @escaping (Timeline<Entry>) -> ()
    ) {

        let places = loadPlaces()

        let entry = SimpleEntry(
            date: Date(),
            title: places.isEmpty
                ? "No Saved Places"
                : "Nearby Saved Places",
            places: places
        )

        let timeline = Timeline(
            entries: [entry],
            policy: .after(
                Date().addingTimeInterval(900)
            )
        )

        completion(timeline)
    }

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let title: String
    let places: [WidgetPlace]
}

struct NearbyPlaceWidgetEntryView: View {

    var entry: Provider.Entry

    var body: some View {

        VStack(alignment: .leading, spacing: 14) {
            
            if entry.places.isEmpty {

                VStack(spacing: 10) {

                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)

                    Text("No Saved Places")
                        .font(.custom("Shafarik-Regular", size: 18))
                        .foregroundColor(.black)

                    Text("Save places to see them here")
                        .font(.caption)
                        .foregroundColor(Color("AppBrown"))
                }
                .frame(
                    maxWidth: .infinity,
                    maxHeight: .infinity,
                    alignment: .center
                )

            } else {
                
                HStack(spacing: 8) {

                    Image("Logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)

                    Text(entry.title)
                        .font(.custom("Shafarik-Regular", size: 18))
                        .foregroundColor(.black)

                    Spacer()
                }

                ForEach(
                    Array(entry.places.enumerated()),
                    id: \.offset
                ) { index, place in

                    VStack(spacing: 8) {

                        HStack(spacing: 10) {

                            Text(place.emoji)
                                .font(.title3)

                            Text(place.name)
                                .font(.subheadline)
                                .foregroundStyle(Color("AppBrown"))
                                .lineLimit(1)

                            Spacer()

                            if let distance = place.distance {

                                let distanceText =
                                    distance >= 1000
                                    ? String(format: "%.1fkm", distance / 1000)
                                    : "\(Int(distance))m"

                                HStack(spacing: 4) {

                                    Text(distanceText)
                                        .font(.caption)
                                        .foregroundColor(Color("AppBrown"))

                                    Image(systemName: "location.fill")
                                        .foregroundColor(Color("Orange"))
                                }
                            }
                        }

                        if index < entry.places.count - 1 {

                            Divider()
                                .overlay(
                                    Color("AppBrown").opacity(0.10)
                                )
                        }
                    }
                }

            }
        }
        .frame(maxWidth: .infinity,
               maxHeight: .infinity,
               alignment: .topLeading)
        .padding()
        .containerBackground(
            Color("WidgetBackground"),
            for: .widget
        )
    }
}

struct NearbyPlaceWidget: Widget {
    let kind: String = "NearbyPlaceWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            NearbyPlaceWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Nearby Places")
        .description("Shows nearby saved places.")
        .supportedFamilies([
            .systemMedium
        ])
    }
}

#Preview(as: .systemMedium) {
    NearbyPlaceWidget()
} timeline: {
    SimpleEntry(
        date: .now,
        title: "Nearby Saved Places",
        places: [
            WidgetPlace(
                name: "Cafe",
                emoji: "☕️",
                distance: 120
            ),
            WidgetPlace(
                name: "Restaurant",
                emoji: "🍽️",
                distance: 300
            ),
            WidgetPlace(
                name: "Shopping",
                emoji: "🛍️",
                distance: 700
            )
        ]
    )
}
