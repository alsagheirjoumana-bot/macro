//
//  HomeView.swift
//  macro
//

import SwiftUI
import SwiftData
import PhotosUI
import MapKit

struct HomeView: View {
    
    @Query(sort: \SavedPlace.createdAt, order: .reverse)
    private var places: [SavedPlace]
    
    @Environment(\.modelContext) private var modelContext
    
    @State private var viewModel = HomeViewModel()
    @State private var showAdd = false
    @State private var selectedCategory: PlaceCategory? = nil
    
    private let columns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]
    
    private var filteredPlaces: [SavedPlace] {
        let searched = viewModel.filtered(places)
        
        if let selectedCategory {
            return searched.filter { $0.category == selectedCategory }
        }
        
        return searched
    }
    
    var body: some View {
        
        NavigationStack {
            
            ZStack {
                
                Color("BackgroundColor")
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    
                    VStack(alignment: .leading, spacing: 24) {
                        
                        headerSection
                        addButton
                        categorySection
                        placesSection
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 18)
                    .padding(.bottom, 110)
                }
            }
            .tint(Color("AppBrown"))
            .sheet(isPresented: $showAdd) {
                AddPlaceView()
            }
        }
    }
    
    private var headerSection: some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            Text("Your Places")
                .font(.custom("Shafarik-Regular", size: 38))
                .foregroundColor(.black)
            
            Text("Discover, remember, revisit")
                .font(.subheadline)
                .foregroundColor(Color("AppBrown").opacity(0.75))
        }
    }
    
    private var addButton: some View {
        
        Button {
            showAdd = true
        } label: {
            
            HStack(spacing: 12) {
                
                Image(systemName: "plus")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(Color("AppOrange"))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Add a new place")
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    Text("Save a spot you want to remember")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(Color("AppBrown").opacity(0.7))
            }
            .padding(16)
            .background(Color.white.opacity(0.95))
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
        }
        .buttonStyle(.plain)
    }
    
    private var categorySection: some View {
        
        VStack(alignment: .leading, spacing: 14) {
            
            Text("Categories")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(Color("AppBrown"))
            
            LazyVGrid(columns: columns, spacing: 14) {
                
                CategoryButton(
                    emoji: "☕️",
                    number: count(for: .cafe),
                    title: "Cafes",
                    isSelected: selectedCategory == .cafe
                ) {
                    selectedCategory = selectedCategory == .cafe ? nil : .cafe
                }
                
                CategoryButton(
                    emoji: "🍽️",
                    number: count(for: .restaurant),
                    title: "Restaurants",
                    isSelected: selectedCategory == .restaurant
                ) {
                    selectedCategory = selectedCategory == .restaurant ? nil : .restaurant
                }
                
                CategoryButton(
                    emoji: "🛍️",
                    number: count(for: .shopping),
                    title: "Shops",
                    isSelected: selectedCategory == .shopping
                ) {
                    selectedCategory = selectedCategory == .shopping ? nil : .shopping
                }
                
                CategoryButton(
                    emoji: "+",
                    number: count(for: .other),
                    title: "Others",
                    isSelected: selectedCategory == .other
                ) {
                    selectedCategory = selectedCategory == .other ? nil : .other
                }
            }
        }
    }
    
    private var placesSection: some View {
        
        VStack(alignment: .leading, spacing: 14) {
            
            Text(places.isEmpty ? "Get Started" : "Saved Places")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(Color("AppBrown"))
            
            if places.isEmpty {
                emptyState
            } else {
                VStack(spacing: 14) {
                    ForEach(filteredPlaces) { place in
                        
                        SwipeToDeleteCard {
                            PlaceDetailView(place: place)
                        } label: {
                            SavedPlaceCard(place: place)
                        } onDelete: {
                            withAnimation {
                                modelContext.delete(place)
                                try? modelContext.save()
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var emptyState: some View {
        
        VStack(spacing: 16) {
            
            ZStack {
                Circle()
                    .fill(Color("OrangeBackground"))
                    .frame(width: 86, height: 86)
                
                Image(systemName: "star.fill")
                    .font(.system(size: 34))
                    .foregroundColor(Color("AppOrange"))
            }
            
            VStack(spacing: 6) {
                Text("No places saved yet")
                    .font(.headline)
                    .foregroundColor(.black)
                
                Text("Tap the + to save places you want to visit later.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.horizontal, 20)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 34)
        .background(Color.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 6)
    }
    
    private func count(for category: PlaceCategory) -> Int {
        places.filter { $0.category == category }.count
    }
}
private struct SwipeToDeleteCard<Destination: View, Label: View>: View {
    
    let destination: Destination
    let label: Label
    let onDelete: () -> Void
    
    @State private var offset: CGFloat = 0
    @State private var dragAmount: CGFloat = 0
    @State private var shouldNavigate = false
    @State private var showDeleteAlert = false
    
    init(
        @ViewBuilder destination: () -> Destination,
        @ViewBuilder label: () -> Label,
        onDelete: @escaping () -> Void
    ) {
        self.destination = destination()
        self.label = label()
        self.onDelete = onDelete
    }
    
    var body: some View {
        
        ZStack(alignment: .trailing) {
            
            if offset < -8 {
                Button {
                    showDeleteAlert = true
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: "trash.fill")
                            .font(.headline)
                        
                        Text("Delete")
                            .font(.caption2)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(width: 62, height: 62)
                    .background(Color.red)
                    .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .padding(.trailing, 18)
                .zIndex(1)
            }
            
            label
                .offset(x: offset)
                .allowsHitTesting(offset == 0)
                .contentShape(Rectangle())
                .onTapGesture {
                    if offset == 0 && abs(dragAmount) < 5 {
                        shouldNavigate = true
                    } else {
                        withAnimation(.spring()) {
                            offset = 0
                        }
                    }
                }
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            dragAmount = value.translation.width
                            
                            let horizontal = abs(value.translation.width)
                            let vertical = abs(value.translation.height)
                            
                            if horizontal > vertical,
                               value.translation.width < 0 {
                                offset = max(value.translation.width, -85)
                            }
                        }
                        .onEnded { value in
                            withAnimation(.spring()) {
                                if value.translation.width < -45 {
                                    offset = -85
                                } else {
                                    offset = 0
                                }
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                dragAmount = 0
                            }
                        }
                )
                .background(
                    NavigationLink(
                        destination: destination,
                        isActive: $shouldNavigate
                    ) {
                        EmptyView()
                    }
                    .hidden()
                )
        }
        .alert("Delete Place?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                withAnimation {
                    onDelete()
                }
            }
            
            Button("Cancel", role: .cancel) {
                withAnimation(.spring()) {
                    offset = 0
                }
            }
        } message: {
            Text("Are you sure you want to delete this place? This action cannot be undone.")
        }
    }
}
// MARK: - Saved Place Card

private struct SavedPlaceCard: View {
    
    let place: SavedPlace
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 14) {
            
            VStack(alignment: .leading, spacing: 10) {
                
                Text(place.name)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color("AppOrange"))
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    
                    // Category Badge
                    
                    HStack(spacing: 6) {
                        
                        Text(place.category.emoji)
                        
                        Text(place.category.rawValue)
                            .font(.subheadline)
                            .foregroundColor(Color("AppBrown"))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Color("AppGray"))
                    .clipShape(Capsule())
                    .fixedSize(horizontal: true, vertical: false)
                    
                    // Visited Badge
                    
                    HStack(spacing: 6) {
                        
                        Circle()
                            .fill(.white)
                            .frame(width: 6, height: 6)
                        
                        Text(place.isVisited ? "Visited" : "Want to Visit")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .fixedSize()
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(
                        place.isVisited
                        ? Color.green
                        : Color("AppOrange")
                    )
                    .clipShape(Capsule())
                    .fixedSize()
                }
                
                if !place.notes.isEmpty {
                    Text(place.notes)
                        .font(.body)
                        .foregroundColor(Color("AppBrown"))
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)
                } else if !place.address.isEmpty {
                    Text(place.address)
                        .font(.body)
                        .foregroundColor(Color("AppBrown"))
                        .lineLimit(2)
                } else {
                    Text("No notes added yet.")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button {
                openDirections(place)
            } label: {
                Image(systemName: "location.fill")
                    .font(.title3)
                    .foregroundColor(Color("AppOrange"))
                    .frame(width: 52, height: 52)
                    .background(Color("AppGray"))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .background(Color.white.opacity(0.96))
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(Color("AppBrown").opacity(0.45), lineWidth: 1.2)
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "\(place.name), \(place.category.rawValue), \(place.isVisited ? "visited" : "want to visit")"
        )
        .accessibilityHint("Double tap to open place details")
    }
    
    private func openDirections(_ place: SavedPlace) {
        guard let lat = place.latitude,
              let lon = place.longitude else { return }
        
        let urlString = "https://www.google.com/maps/dir/?api=1&destination=\(lat),\(lon)&travelmode=driving"
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}


struct PlaceDetailView: View {
    
    @Bindable var place: SavedPlace
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var isEditing = false
    @State private var showDeleteAlert = false
    
    @State private var editedName = ""
    @State private var editedNotes = ""
    @State private var editedCategoryRaw = ""
    @State private var editedIsVisited = false
    @State private var editedImageData: Data?
    @State private var showDiscardAlert = false

    @FocusState private var notesFocused: Bool
    
    var body: some View {
        
        ZStack {
            
            Color("BackgroundColor")
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                
                VStack(spacing: 24) {
                    
                    imageSection
                    infoSection
                    notesSection
                    deleteButton
                    savedDate
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
            .scrollDismissesKeyboard(.interactively)
            .onTapGesture {
                notesFocused = false
            }
        }
        .onAppear {
            loadEditValues()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    
                    notesFocused = false
                    
                    if isEditing && hasUnsavedChanges {
                        showDiscardAlert = true
                    } else {
                        dismiss()
                    }
                    
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "arrow.left")
                        Text("Back")
                    }
                    .foregroundColor(.black)
                }
            }
            
            ToolbarItem(placement: .principal) {
                TextField("Place name", text: isEditing ? $editedName : .constant(place.name))
                    .font(.custom("Shafarik-Regular", size: 32))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                    .disabled(!isEditing)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    if isEditing {
                        saveChanges()
                    } else {
                        loadEditValues()
                        isEditing = true
                    }
                } label: {
                    Text(isEditing ? "Save" : "Edit")
                        .fontWeight(.semibold)
                        .foregroundColor(Color("AppOrange"))
                }
            }
        }
        .alert("Delete Place?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                modelContext.delete(place)
                dismiss()
            }
            
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this place? This action cannot be undone.")
        }
        .alert(
            "Discard Changes?",
            isPresented: $showDiscardAlert
        ) {

            Button(
                "Discard",
                role: .destructive
            ) {

                notesFocused = false
                dismiss()
            }

            Button(
                "Keep Editing",
                role: .cancel
            ) { }

        } message: {

            Text(
                "You have unsaved changes. Are you sure you want to discard them?"
            )
        }
        .onChange(of: selectedPhoto) { _, newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    editedImageData = data
                }
            }
        }
    }
    
    private var imageSection: some View {
        
        PhotosPicker(selection: $selectedPhoto, matching: .images) {
            ZStack {
                
                RoundedRectangle(cornerRadius: 28)
                    .fill(Color.white.opacity(0.9))
                    .frame(height: 320)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color("AppGray"), lineWidth: 1)
                    )
                
                if let imageData = isEditing ? editedImageData : place.imageData,
                   let uiImage = UIImage(data: imageData) {
                    
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: 320)
                        .clipShape(RoundedRectangle(cornerRadius: 28))
                    
                } else {
                    
                    VStack(spacing: 12) {
                        Image(systemName: "photo")
                            .font(.system(size: 95))
                            .foregroundColor(.gray)
                        
                        Image(systemName: "square.and.arrow.up")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(!isEditing)
        .opacity(isEditing ? 1 : 0.9)
        .padding(.top, 18)
    }
    private var hasUnsavedChanges: Bool {
        
        editedName != place.name ||
        editedNotes != place.notes ||
        editedCategoryRaw != place.categoryRaw ||
        editedIsVisited != place.isVisited ||
        editedImageData != place.imageData
    }
    
    private var infoSection: some View {
        
        VStack(alignment: .leading, spacing: 14) {
            
            if !place.address.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "location")
                        .foregroundColor(Color("AppBrown"))
                    
                    Text(place.address)
                        .font(.subheadline)
                        .foregroundColor(Color("AppBrown"))
                        .lineLimit(2)
                }
            }
            
            HStack(spacing: 10) {
                
                Picker("Category", selection: isEditing ? $editedCategoryRaw : .constant(place.categoryRaw)) {
                    ForEach(PlaceCategory.allCases) { category in
                        Text("\(category.emoji) \(category.rawValue)")
                            .tag(category.rawValue)
                    }
                }
                .pickerStyle(.menu)
                .disabled(!isEditing)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color("AppGray"))
                .clipShape(Capsule())
                
                Toggle(isOn: isEditing ? $editedIsVisited : .constant(place.isVisited)) {
                    Text((isEditing ? editedIsVisited : place.isVisited) ? "Visited" : "Not visited")
                        .font(.subheadline)
                }
                .disabled(!isEditing)
                .toggleStyle(.button)
                .tint(Color("AppGreen"))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var notesSection: some View {
        
        VStack(alignment: .leading, spacing: 8) {
            
            Text("Notes")
                .font(.headline)
                .foregroundColor(.black)
            
            TextField(
                "Write your note here...",
                text: isEditing ? $editedNotes : .constant(place.notes),
                axis: .vertical
            )
            .focused($notesFocused)
            .disabled(!isEditing)
            .lineLimit(4...7)
            .padding()
            .background(Color("AppGray"))
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .foregroundColor(Color("AppBrown"))
        }
    }
    
    private var deleteButton: some View {
        
        HStack {
            Spacer()
            
            Button {
                showDeleteAlert = true
            } label: {
                Label("Delete Place", systemImage: "trash")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.red)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.red.opacity(0.08))
                    .clipShape(Capsule())
            }
        }
    }
    
    private var savedDate: some View {
        
        Text("Saved on \(place.createdAt.formatted(date: .long, time: .omitted))")
            .font(.subheadline)
            .foregroundColor(Color("AppBrown").opacity(0.8))
            .padding(.top, 50)
    }
    
    private func loadEditValues() {
        editedName = place.name
        editedNotes = place.notes
        editedCategoryRaw = place.categoryRaw
        editedIsVisited = place.isVisited
        editedImageData = place.imageData
    }
    
    private func saveChanges() {
        
        place.name = editedName
        place.notes = editedNotes
        place.categoryRaw = editedCategoryRaw
        place.isVisited = editedIsVisited
        place.imageData = editedImageData

        notesFocused = false
        isEditing = false

        dismiss()
    }
}

#Preview {
    HomeView()
}
