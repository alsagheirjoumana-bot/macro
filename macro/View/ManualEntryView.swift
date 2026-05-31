import SwiftUI
import MapKit
import CoreLocation
import Combine

struct ManualEntryView: View {
    
    @Bindable var viewModel: AddPlaceViewModel
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var locationManager = AddPlaceLocationManager()
    @State private var searchCompleter = MKLocalSearchCompleter()
    @State private var completerDelegate = SearchCompleterDelegate()
    @State private var suggestions: [MKLocalSearchCompletion] = []
    @State private var didChooseSuggestion = false
    var body: some View {
        
        ScrollView {
            
            VStack(alignment: .leading, spacing: 20) {
                
                CategoryPickerView(selected: $viewModel.selectedCategory)
                
                placeNameField
                
                formField(
                    "Neighborhood",
                    text: $viewModel.neighborhood,
                    placeholder: "e.g. Al Olaya, Riyadh"
                )
                
                notesField
                
                VisitedToggleRow(isVisited: $viewModel.isVisited)
                
                saveButton
            }
            .padding()
        }
        .onAppear {
            locationManager.requestLocation()
            
            completerDelegate.onResultsUpdate = {
                suggestions = searchCompleter.results
            }
            
            searchCompleter.delegate = completerDelegate
            searchCompleter.resultTypes = [.pointOfInterest, .address]
            
            updateSearchRegion()
        }
        .onReceive(locationManager.$location) { _ in
            updateSearchRegion()
        }
    }
    
    private var placeNameField: some View {
        
        VStack(alignment: .leading, spacing: 6) {
            
            Text("Place Name *")
                .font(.subheadline)
                .fontWeight(.medium)
            
            TextField("Start typing a place name...", text: $viewModel.name)
                .textFieldStyle(.roundedBorder)
                .onChange(of: viewModel.name) { _, newValue in

                    if didChooseSuggestion {
                        didChooseSuggestion = false
                        suggestions = []
                        searchCompleter.queryFragment = ""
                        return
                    }

                    let trimmed = newValue.trimmingCharacters(in: .whitespaces)

                    if trimmed.count >= 2 {
                        updateSearchRegion()
                        searchCompleter.queryFragment = trimmed
                    } else {
                        suggestions = []
                    }
                }
            
    if !suggestions.isEmpty {
             
             VStack(spacing: 0) {
                 
                 ForEach(suggestions.prefix(5), id: \.self) { suggestion in
                     
                     Button {

                         didChooseSuggestion = true
                         suggestions = []
                         searchCompleter.queryFragment = ""

                         selectSuggestion(suggestion)

                     } label: {
                         
                         HStack(spacing: 12) {
                             
                             Circle()
                                 .fill(Color("AppOrange").opacity(0.18))
                                 .frame(width: 38, height: 38)
                                 .overlay(
                                     Image(systemName: "mappin")
                                         .foregroundStyle(Color("AppOrange"))
                                 )
                             
                             VStack(alignment: .leading, spacing: 4) {
                                 
                                 Text(suggestion.title)
                                     .font(.headline)
                                     .foregroundColor(.primary)
                                     .lineLimit(1)
                                 
                                 if !suggestion.subtitle.isEmpty {
                                     Text(suggestion.subtitle)
                                         .font(.caption)
                                         .foregroundColor(.secondary)
                                         .lineLimit(1)
                                 }
                             }
                             
                             Spacer()
                         }
                         .padding(.horizontal, 14)
                         .padding(.vertical, 12)
                     }
                     .buttonStyle(.plain)
                     
                     Divider()
                         .padding(.leading, 64)
                 }
             }
             .background(Color.white.opacity(0.96))
             .clipShape(RoundedRectangle(cornerRadius: 22))
             .shadow(color: .black.opacity(0.10), radius: 14, x: 0, y: 6)
         }
        }
    }
    
    private func formField(
        _ label: String,
        text: Binding<String>,
        placeholder: String
    ) -> some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            Text(label)
                .font(.subheadline)
                .fontWeight(.medium)
            
            TextField(placeholder, text: text)
                .textFieldStyle(.roundedBorder)
        }
    }
    
    private var notesField: some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            Text("Notes")
                .font(.subheadline)
                .fontWeight(.medium)
            
            TextField(
                "What caught your eye? What to try?",
                text: $viewModel.notes,
                axis: .vertical
            )
            .lineLimit(4...6)
            .textFieldStyle(.roundedBorder)
        }
    }
    
    private var saveButton: some View {
        
        Button {
            viewModel.save(context: modelContext)
            dismiss()
        } label: {
            
            Label("Save", systemImage: "square.and.arrow.down")
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    viewModel.canSave
                    ? Color("AppOrange")
                    : Color("AppGray")
                )
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .disabled(!viewModel.canSave)
    }
    
    private func updateSearchRegion() {
        
        let coordinate = locationManager.location ?? CLLocationCoordinate2D(
            latitude: 24.7136,
            longitude: 46.6753
        )
        
        searchCompleter.region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(
                latitudeDelta: 0.08,
                longitudeDelta: 0.08
            )
        )
    }
    
    private func selectSuggestion(_ suggestion: MKLocalSearchCompletion) {
        
        viewModel.name = suggestion.title
        suggestions = []
        
        let request = MKLocalSearch.Request(completion: suggestion)
        request.region = searchCompleter.region
        
        let search = MKLocalSearch(request: request)
        
        search.start { response, _ in
            
            guard let item = response?.mapItems.first else {
                return
            }
            
            DispatchQueue.main.async {
                
                viewModel.name = item.name ?? suggestion.title
                
                viewModel.neighborhood =
                item.placemark.subLocality ??
                item.placemark.locality ??
                suggestion.subtitle
                
                viewModel.selectedCategory = guessCategory(from: item)
            }
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

final class SearchCompleterDelegate: NSObject, MKLocalSearchCompleterDelegate {
    
    var onResultsUpdate: (() -> Void)?
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        onResultsUpdate?()
    }
}

final class AddPlaceLocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    private let manager = CLLocationManager()
    
    @Published var location: CLLocationCoordinate2D?
    
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func requestLocation() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        location = locations.last?.coordinate
    }
}
