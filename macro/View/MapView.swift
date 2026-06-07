import SwiftUI
import MapKit
import CoreLocation
import SwiftData
import UserNotifications
import Combine

struct MapPlace: Identifiable {
    let id = UUID()
    var name: String
    var address: String
    var note: String
    var latitude: Double
    var longitude: Double
    var distance: Double
    var category: PlaceCategory = .other
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var location: CLLocationCoordinate2D?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestPermissions() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()

        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .sound, .badge]
        ) { _, _ in }
    }


    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {

        guard let coordinate = locations.last?.coordinate else {
            return
        }

        location = coordinate

        LocationStore.save(
            coordinate: coordinate
        )
    }

    func startMonitoring(
        name: String,
        latitude: Double,
        longitude: Double
    ) {
        let region = CLCircularRegion(
            center: CLLocationCoordinate2D(
                latitude: latitude,
                longitude: longitude
            ),
            radius: 200,
            identifier: name
        )

        region.notifyOnEntry = true
        region.notifyOnExit = false

        manager.startMonitoring(for: region)
    }

    func locationManager(
        _ manager: CLLocationManager,
        didEnterRegion region: CLRegion
    ) {
        let content = UNMutableNotificationContent()
        content.title = "You’re near a saved place"
        content.body = "You saved \(region.identifier). Want to visit?"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }
}

struct MapView: View {

    @Environment(\.modelContext) private var modelContext

    @Query(sort: \SavedPlace.createdAt, order: .reverse)
    private var savedPlaces: [SavedPlace]

    @StateObject private var locationManager = LocationManager()

    @State private var searchText = ""
    @State private var searchTask: Task<Void, Never>?
    @State private var searchResults: [MapPlace] = []
    @State private var selectedPlace: MapPlace?
    @FocusState private var isSearchFocused: Bool

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

                ForEach(savedPlaces) { place in
                    if let lat = place.latitude,
                       let lon = place.longitude {

                        Annotation(
                            place.name,
                            coordinate: CLLocationCoordinate2D(
                                latitude: lat,
                                longitude: lon
                            )
                        ) {
                            pin(
                                systemName: "star.fill",
                                color: .orange
                            ) {
                                selectedPlace = MapPlace(
                                    name: place.name,
                                    address: place.address,
                                    note: place.notes,
                                    latitude: lat,
                                    longitude: lon,
                                    distance: 0
                                )

                                moveMapTo(
                                    latitude: lat,
                                    longitude: lon
                                )
                            }
                        }
                    }
                }

                ForEach(searchResults) { place in
                    Annotation(
                        place.name,
                        coordinate: CLLocationCoordinate2D(
                            latitude: place.latitude,
                            longitude: place.longitude
                        )
                    ) {
                        pin(
                            systemName: "mappin.circle.fill",
                            color: .red
                        ) {
                            selectedPlace = place

                            moveMapTo(
                                latitude: place.latitude,
                                longitude: place.longitude
                            )
                        }
                    }
                }
            }
            .ignoresSafeArea()
            .onAppear {
                locationManager.requestPermissions()

                for place in savedPlaces {
                    if let lat = place.latitude,
                       let lon = place.longitude {

                        locationManager.startMonitoring(
                            name: place.name,
                            latitude: lat,
                            longitude: lon
                        )
                    }
                }
            }

            topSearchArea

            if let place = selectedPlace {
                bottomCard(for: place)
            }
        }
    }

    var topSearchArea: some View {
        VStack(spacing: 10) {

            HStack {

                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)

                ZStack(alignment: .leading) {

                    if searchText.isEmpty && !isSearchFocused {
                        Text("Search places...")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    }

                    TextField("", text: $searchText)
                        .focused($isSearchFocused)
                        .font(.subheadline)
                        .submitLabel(.search)
                        .onSubmit {
                            searchNearbyPlaces()
                        }
                        .onChange(of: searchText) { _, newValue in
                            liveSearch(newValue)
                        }
                }

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                        searchResults = []
                        selectedPlace = nil
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 52)

            .background(
                RoundedRectangle(cornerRadius: 30)
                    .fill(Color.white.opacity(0.95))
            )

            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(
                        isSearchFocused
                        ? Color("AppOrange")
                        : Color.clear,
                        lineWidth: 2
                    )
            )

            .shadow(
                color: .black.opacity(0.08),
                radius: 10,
                x: 0,
                y: 4
            )

            .padding(.horizontal, 28)

            if !searchResults.isEmpty && selectedPlace == nil {
                resultsCard
            }
        }
        .padding(.top, 20)
    }

    var resultsCard: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(searchResults) { place in
                    Button {
                        selectedPlace = place

                        moveMapTo(
                            latitude: place.latitude,
                            longitude: place.longitude
                        )
                    } label: {
                        VStack(
                            alignment: .leading,
                            spacing: 4
                        ) {
                            Text(place.name)
                                .font(.headline)
                                .foregroundStyle(.primary)

                            Text(place.address)
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Text("\(place.distance / 1000, specifier: "%.1f") km away")
                                .font(.caption2)
                                .foregroundStyle(.orange)
                        }
                        .frame(
                            maxWidth: .infinity,
                            alignment: .leading
                        )
                        .padding()
                    }

                    Divider()
                }
            }
        }
        .frame(maxHeight: 260)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .padding(.horizontal, 28)
    }

    func bottomCard(for place: MapPlace) -> some View {
        VStack {
            Spacer()

            VStack(alignment: .leading, spacing: 16) {

                Text(place.name)
                    .font(.title2)
                    .bold()

                Text(place.address)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text(place.note.isEmpty ? "No note added yet." : place.note)

                HStack {
                    Button {
                        if isSaved(place) {
                            unsavePlace(place)
                        } else {
                            savePlace(place)
                        }
                    } label: {
                        Label(
                            isSaved(place) ? "Unsave" : "Save",
                            systemImage: isSaved(place)
                            ? "bookmark.slash.fill"
                            : "bookmark.fill"
                        )
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            isSaved(place)
                            ? Color.red
                            : Color("AppOrange")
                        )
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                    }

                    Button {
                        openGoogleMaps(for: place)
                    } label: {
                        Image(systemName: "location.fill")
                            .padding()
                            .background(Color("AppBrown"))
                            .foregroundStyle(.white)
                            .clipShape(Circle())
                    }

                    Button {
                        selectedPlace = nil
                    } label: {
                        Image(systemName: "xmark")
                            .padding()
                            .background(.thinMaterial)
                            .clipShape(Circle())
                    }
                }
            }
            .padding(20)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 28))
            .padding()
        }
    }

    func pin(
        systemName: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.title2)
                .foregroundStyle(color)
                .padding(8)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
        }
    }

    func liveSearch(_ newValue: String) {
        searchTask?.cancel()

        let trimmed = newValue.trimmingCharacters(
            in: .whitespaces
        )

        guard trimmed.count >= 2 else {
            searchResults = []
            return
        }

        searchTask = Task {
            try? await Task.sleep(
                nanoseconds: 350_000_000
            )

            if !Task.isCancelled {
                await MainActor.run {
                    searchNearbyPlaces()
                }
            }
        }
    }

    func searchNearbyPlaces() {
        let trimmed = searchText.trimmingCharacters(
            in: .whitespaces
        )

        guard !trimmed.isEmpty else {
            searchResults = []
            return
        }

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
            guard let items = response?.mapItems else {
                return
            }

            let places = items.map { item in
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
                    distance: userLocation.distance(
                        from: placeLocation
                    ),
                    category: guessCategory(from: item)
                )
            }

            searchResults = places.sorted {
                $0.distance < $1.distance
            }
        }
    }

    func savePlace(_ place: MapPlace) {
        guard !isSaved(place) else {
            selectedPlace = nil
            return
        }

        let saved = SavedPlace(
            name: place.name,
            neighborhood: "",
            notes: place.note,
            category: place.category,
            isVisited: false,
            latitude: place.latitude,
            longitude: place.longitude,
            address: place.address
        )

        modelContext.insert(saved)

        locationManager.startMonitoring(
            name: saved.name,
            latitude: place.latitude,
            longitude: place.longitude
        )

        selectedPlace = nil
    }

    func unsavePlace(_ place: MapPlace) {
        if let existingPlace = savedPlaces.first(where: {
            $0.name == place.name &&
            $0.latitude == place.latitude &&
            $0.longitude == place.longitude
        }) {
            modelContext.delete(existingPlace)
        }

        selectedPlace = nil
    }

    func isSaved(_ place: MapPlace) -> Bool {
        savedPlaces.contains {
            $0.name == place.name &&
            $0.latitude == place.latitude &&
            $0.longitude == place.longitude
        }
    }

    func moveMapTo(
        latitude: Double,
        longitude: Double
    ) {
        cameraPosition = .region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: latitude,
                    longitude: longitude
                ),
                span: MKCoordinateSpan(
                    latitudeDelta: 0.02,
                    longitudeDelta: 0.02
                )
            )
        )
    }
    
    func guessCategory(from item: MKMapItem) -> PlaceCategory {

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
    func openGoogleMaps(for place: MapPlace) {
        let urlString =
        "https://www.google.com/maps/dir/?api=1&destination=\(place.latitude),\(place.longitude)&travelmode=driving"

        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    MapView()
}
