//
//  HomeView.swift
//  macro
//

import SwiftUI
import UIKit
import SwiftData
import PhotosUI
import MapKit
import WidgetKit

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
                .accessibilityAddTraits(.isHeader)
            
            Text("Discover, remember, revisit")
                .font(.subheadline)
                .foregroundColor(Color("AppBrown").opacity(0.75))
                .accessibilityHidden(true)
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
        .accessibilityLabel("Add a new place")
        .accessibilityHint("Double tap to create a new saved place")
    }
    
    private var categorySection: some View {
        
        VStack(alignment: .leading, spacing: 14) {
            
            Text(String(localized: "Categories"))
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(Color("AppBrown"))
                .accessibilityAddTraits(.isHeader)
            
            LazyVGrid(columns: columns, spacing: 14) {
                
                CategoryButton(
                    emoji: "☕️",
                    number: count(for: .cafe),
                    title: String(localized: "Cafes"),
                    isSelected: selectedCategory == .cafe
                ) {
                    selectedCategory = selectedCategory == .cafe ? nil : .cafe
                }
                
                CategoryButton(
                    emoji: "🍽️",
                    number: count(for: .restaurant),
                    title: String(localized: "Restaurants"),
                    isSelected: selectedCategory == .restaurant
                ) {
                    selectedCategory = selectedCategory == .restaurant ? nil : .restaurant
                }
                
                CategoryButton(
                    emoji: "🛍️",
                    number: count(for: .shopping),
                    title: String(localized: "Shops"),
                    isSelected: selectedCategory == .shopping
                ) {
                    selectedCategory = selectedCategory == .shopping ? nil : .shopping
                }
                
                CategoryButton(
                    emoji: "+",
                    number: count(for: .other),
                    title: String(localized: "Others"),
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
                .accessibilityAddTraits(.isHeader)
            
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

                                NotificationManager.shared.placeWasDeleted(place)

                                modelContext.delete(place)
                                try? modelContext.save()

                                WidgetCenter.shared.reloadAllTimelines()
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
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("No places have been saved yet. Tap Add a new place to save your first location.")
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
    @State private var shouldNavigate = false
    @State private var showDeleteAlert = false

    private let maxSwipe: CGFloat = -140

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

            //DELETE BUTTON
            Button {
                showDeleteAlert = true
            } label: {

                HStack(spacing: 8) {

                    Image(systemName: "trash.fill")
                        .font(.system(size: 14, weight: .semibold))

                    Text("Delete")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16 + abs(offset * 0.18))
                .padding(.vertical, 10)
                .background(
                    ZStack {
                        Color.red.opacity(0.95)

                        // subtle glass feel
                        BlurView(style: .systemUltraThinMaterialDark)
                            .opacity(0.25)
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
                .scaleEffect(offset == 0 ? 0.85 : 1)
                .opacity(offset == 0 ? 0 : 1)
                .animation(.spring(response: 0.35, dampingFraction: 0.85), value: offset)
            }
            .padding(.trailing, 16)
            .accessibilityLabel("Delete place")
            .accessibilityHint("Deletes this saved place")

            label
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .contentShape(Rectangle())
                .offset(x: offset)
                .onTapGesture {

                    if offset == 0 {
                        shouldNavigate = true
                    } else {
                        withAnimation(.spring()) {
                            offset = 0
                        }
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 25)
                        .onEnded { value in

                            let dx = value.translation.width
                            let dy = value.translation.height

                            guard abs(dx) > abs(dy) else { return }

                            withAnimation(.spring(response: 0.35,
                                                  dampingFraction: 0.85)) {

                                // Close if already open
                                if offset != 0 {
                                    if dx > 20 {
                                        offset = 0
                                    }
                                    return
                                }

                                // Open
                                if dx < -80 {
                                    offset = maxSwipe

                                    if dx < -130 {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                            showDeleteAlert = true
                                        }
                                    }
                                }
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
                    offset = 0
                }
            }

            Button("Cancel", role: .cancel) {
                withAnimation {
                    offset = 0
                }
            }
        }
    }
}

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
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
                        
                        Image(systemName: place.isVisited ? "checkmark.circle.fill" : "checkmark.circle.dotted")
                            .font(.caption)
                            .foregroundColor(.white)
                        
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
            .accessibilityLabel("Open directions")
            .accessibilityHint("Opens navigation to \(place.name)")
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
            "\(place.name). Category \(place.category.rawValue). \(place.isVisited ? "Visited" : "Want to visit")."
        )
        .accessibilityHint("Double tap to view place details.")
        .accessibilityAddTraits(.isButton)
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
    @State private var showPhotoMenu = false
    
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
                .accessibilityLabel("Go back")
                .accessibilityHint("Returns to the home page")
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
                .accessibilityLabel(isEditing ? "Save changes" : "Edit place")
                .accessibilityHint(isEditing ? "Saves your changes" : "Opens editing mode")
            }
        }
        .alert("Delete Place?", isPresented: $showDeleteAlert) {
            Button("Delete", role: .destructive) {
                modelContext.delete(place)
                WidgetCenter.shared.reloadAllTimelines()
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
        
        ZStack {

            RoundedRectangle(cornerRadius: 28)
                .fill(Color.white.opacity(0.9))
                .frame(height: 320)
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(Color("AppOrange"), lineWidth: 1.5)
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

                VStack(spacing: 14) {

                    Image(systemName: "photo")
                        .font(.system(size: 95))
                        .foregroundColor(.gray)

                    PhotosPicker(
                        selection: $selectedPhoto,
                        matching: .images
                    ) {

                        Image(systemName: "square.and.arrow.up")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(width: 52, height: 52)
                            .background(Color("AppOrange"))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Upload image")
                    .accessibilityHint("Upload a picture of the place")
                }
            }

            if isEditing {

                VStack {

                    HStack {

                        Spacer()

                        VStack(spacing: 10) {

                            PhotosPicker(
                                selection: $selectedPhoto,
                                matching: .images
                            ) {

                                Image(systemName: "pencil")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(width: 38, height: 38)
                                    .background(Color("AppOrange"))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)

                            if editedImageData != nil {

                                Button {

                                    editedImageData = nil

                                } label: {

                                    Image(systemName: "trash")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(width: 38, height: 38)
                                        .background(.red)
                                        .clipShape(Circle())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(16)
                    }

                    Spacer()
                }
            }
        }
        .padding(.top, 18)
        .onChange(of: selectedPhoto) { _, newItem in

            Task {

                guard let data = try? await newItem?.loadTransferable(type: Data.self)
                else { return }

                if isEditing {

                    editedImageData = data

                } else {

                    place.imageData = data
                    try? modelContext.save()
                    WidgetCenter.shared.reloadAllTimelines()
                }
            }
        }
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
            .accessibilityLabel("Delete place")
            .accessibilityHint("Permanently deletes this saved place")
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
