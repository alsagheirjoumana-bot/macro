//
//  MapPickerView.swift
//  macro
//
//  Created by Reema Alkhelaiwi on 08/06/2026.
//
import SwiftUI
import MapKit
import CoreLocation

struct MapPickerView: View {
    
    var onPick: (MapPlace) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var searchTask: Task<Void, Never>?
    @StateObject private var locationManager = LocationManager()
    
    @State private var searchText = ""
    @State private var searchResults: [MapPlace] = []
    @State private var cameraPosition: MapCameraPosition = .userLocation(
        fallback: .region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: 24.7136,
                    longitude: 46.6753
                ),
                span: MKCoordinateSpan(
                    latitudeDelta: 0.03,
                    longitudeDelta: 0.03
                )
            )
        )
    )
    
    var userLocation: CLLocation {
        CLLocation(
            latitude: locationManager.location?.latitude ?? 24.7136,
            longitude: locationManager.location?.longitude ?? 46.6753
        )
    }
    
    var body: some View {
        
        ZStack(alignment: .top) {
            
            Map(position: $cameraPosition) {
                UserAnnotation()
                
                ForEach(searchResults) { place in
                    Annotation(
                        place.name,
                        coordinate: CLLocationCoordinate2D(
                            latitude: place.latitude,
                            longitude: place.longitude
                        )
                    ) {
                        Button {
                            onPick(place)
                            dismiss()
                        } label: {
                            Image(systemName: "mappin.circle.fill")
                                .font(.title)
                                .foregroundStyle(Color("AppOrange"))
                        }
                    }
                }
            }
            .ignoresSafeArea()
            .onAppear {
                locationManager.requestPermissions()
            }
            
            VStack(spacing: 10) {
                
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    
                    TextField("Search places...", text: $searchText)
                        .submitLabel(.search)
                        .onSubmit {
                            searchNearbyPlaces()
                        }
                        .onChange(of: searchText) { _, newValue in
                            liveSearch(newValue)
                        }
                    
                    Button {
                        searchNearbyPlaces()
                    } label: {
                        Image(systemName: "arrow.right.circle.fill")
                            .foregroundColor(Color("AppOrange"))
                    }
                }
                .padding(.horizontal, 16)
                .frame(height: 52)
                .background(Color.white.opacity(0.95))
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
                .padding(.horizontal, 24)
                
                if !searchResults.isEmpty {
                    resultsCard
                }
            }
            .padding(.top, 20)
        }
    }
    
    private var resultsCard: some View {
        
        ScrollView {
            VStack(spacing: 0) {
                ForEach(searchResults) { place in
                    Button {
                        onPick(place)
                        dismiss()
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(place.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(place.address)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("\(place.distance / 1000, specifier: "%.1f") km away")
                                .font(.caption2)
                                .foregroundColor(Color("AppOrange"))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    }
                    
                    Divider()
                }
            }
        }
        .frame(maxHeight: 260)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal, 24)
    }
    private func liveSearch(_ newValue: String) {
        
        searchTask?.cancel()
        
        let trimmed = newValue.trimmingCharacters(in: .whitespaces)
        
        guard trimmed.count >= 2 else {
            searchResults = []
            return
        }
        
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 350_000_000)
            
            if !Task.isCancelled {
                await MainActor.run {
                    searchNearbyPlaces()
                }
            }
        }
    }
    private func searchNearbyPlaces() {
        
        let trimmed = searchText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = trimmed
        request.resultTypes = .pointOfInterest
        request.region = MKCoordinateRegion(
            center: userLocation.coordinate,
            span: MKCoordinateSpan(
                latitudeDelta: 0.15,
                longitudeDelta: 0.15
            )
        )
        
        MKLocalSearch(request: request).start { response, _ in
            guard let items = response?.mapItems else { return }
            
            searchResults = items.map { item in
                let coordinate = item.placemark.coordinate
                let placeLocation = CLLocation(
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude
                )
                
                return MapPlace(
                    name: item.name ?? "Unknown place",
                    address: item.placemark.title ?? "No address",
                    note: "",
                    latitude: coordinate.latitude,
                    longitude: coordinate.longitude,
                    distance: userLocation.distance(from: placeLocation),
                    category: guessCategory(from: item)
                )
            }
            .sorted { $0.distance < $1.distance }
        }
    }
    
    private func guessCategory(from item: MKMapItem) -> PlaceCategory {
        guard let category = item.pointOfInterestCategory else {
            return .other
        }
        
        switch category {
        case .cafe, .bakery:
            return .cafe
        case .restaurant, .foodMarket:
            return .restaurant
        case .store:
            return .shopping
        default:
            return .other
        }
    }
}
