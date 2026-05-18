//
//  HomeView.swift
//  macro
//
//  Created by ghala alismael on 27/11/1447 AH.
//
import SwiftUI
import SwiftData

struct HomeView: View {
    @Query(sort: \SavedPlace.createdAt, order: .reverse)
    private var places: [SavedPlace]

    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = HomeViewModel()
    @State private var showAdd = false

    var body: some View {
        NavigationStack {
            Group {
                if places.isEmpty {
                    ContentUnavailableView(
                        "No places yet",
                        systemImage: "mappin.slash",
                        description: Text("Tap + to add your first place.")
                    )
                } else {
                    List {
                        ForEach(viewModel.filtered(places)) { place in
                            PlaceRow(place: place)
                        }
                        .onDelete { indexSet in
                            let filtered = viewModel.filtered(places)
                            indexSet.forEach {
                                viewModel.delete(filtered[$0], from: modelContext)
                            }
                        }
                    }
                    .searchable(text: $viewModel.searchText, prompt: "Search places")
                }
            }
            .navigationTitle("My Places")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button { showAdd = true } label: {
                        Image(systemName: "plus")
                    }
                }
                ToolbarItem(placement: .topBarLeading) {
                    Toggle("Visited only", isOn: $viewModel.filterVisited)
                        .toggleStyle(.button)
                        .font(.caption)
                }
            }
            .sheet(isPresented: $showAdd) {
                AddPlaceView()
            }
        }
    }
}

private struct PlaceRow: View {
    let place: SavedPlace
    var body: some View {
        HStack(spacing: 12) {
            Text(place.category.emoji).font(.title2)
            VStack(alignment: .leading, spacing: 2) {
                Text(place.name).font(.headline)
                if !place.neighborhood.isEmpty {
                    Text(place.neighborhood)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            if place.isVisited {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(Color("AppGreen"))
            }
        }
        .padding(.vertical, 4)
    }
}
