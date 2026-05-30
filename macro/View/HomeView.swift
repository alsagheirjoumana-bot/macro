//
//  HomeView 2.swift
//  macro
//
//  Created by May Alqunaytir on 19/05/2026.
//


import SwiftUI
import SwiftData

struct HomeView: View {
    
    // MARK: - SwiftData (from old HomeView)
    @Query(sort: \SavedPlace.createdAt, order: .reverse)
    private var places: [SavedPlace]
    
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = HomeViewModel()
    @State private var showAdd = false
    
    let columns = [
        GridItem(.flexible(minimum: 170), spacing: 20),
        GridItem(.flexible(minimum: 170), spacing: 20)
    ]
    
    var body: some View {
        
        NavigationStack {
            
            ZStack {
                
                Color("BackgroundColor")
                    .ignoresSafeArea()
                
                VStack {
                    
                    // Title
                    VStack(spacing: 10) {
                        
                        Text("Your Places")
                            .font(.custom("Shafarik-Regular", size: 35))
                        
                        Rectangle()
                            .frame(height: 1)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(Color("AppBrown"))
                    }
                    .padding(.top, -20)
                    
                    // Discover Text
                    VStack(alignment: .leading, spacing: 13) {
                        
                        Text("Discover, remember, revisit")
                            .font(.headline)
                            .foregroundColor(Color("AppBrown"))
                        
                        Text("Categories:")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color("AppBrown"))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 30)
                    
                    Button {
                        showAdd = true
                    } label: {
                        
                        Image(systemName: "plus")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color("AppBrown"))
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    }
                    .offset(x: 155)
                    .offset(y: -85)
                    
                    // Category Buttons
                    LazyVGrid(columns: columns, spacing: 17) {
                        
                        CategoryButton(emoji: "☕️", number: 0, title: "Cafes")
                        CategoryButton(emoji: "🍽️", number: 0, title: "Restaurants")
                        CategoryButton(emoji: "🛍️", number: 0, title: "Shops")
                        CategoryButton(emoji: "+", number: 0, title: "Others")
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal)
                    .offset(y: -50)
                    
                    // MARK: - LIST ADDED UNDER CATEGORIES (ONLY ADDITION)
                    
                    if places.isEmpty {
                        
                        ContentUnavailableView(
                            "No places yet",
                            systemImage: "mappin.slash",
                            description: Text("Tap + to add your first place.")
                        )
                        .padding(.top, 20)
                        
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
                        .listStyle(.plain)
                        .frame(maxHeight: .infinity)
                        .searchable(text: $viewModel.searchText, prompt: "Search places")
                    }
                    
                    Spacer()
                }
                .padding()
            }
         
            .tint(Color("AppBrown"))
            .sheet(isPresented: $showAdd) {
                AddPlaceView()
            }
        }
    }
}

// MARK: - OLD ROW (UNCHANGED)
private struct PlaceRow: View {
    
    let place: SavedPlace
    
    var body: some View {
        
        HStack(spacing: 12) {
            
            Text(place.category.emoji)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 2) {
                
                Text(place.name)
                    .font(.headline)
                
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

#Preview {
    HomeView()
}
