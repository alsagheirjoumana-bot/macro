import SwiftUI
import SwiftData
import MapKit

struct SpinView: View {
    
    @Query(sort: \SavedPlace.createdAt, order: .reverse)
    private var places: [SavedPlace]
    
    @State private var selectedCategory: PlaceCategory? = nil
    @State private var rotation: Double = 0
    @State private var pickedPlace: SavedPlace?
    @State private var pendingPickedPlace: SavedPlace?
    private var filteredPlaces: [SavedPlace] {
        if let selectedCategory {
            return places.filter { $0.category == selectedCategory }
        }
        return places
    }
    
    var body: some View {
        
        ZStack {
            
            Color("BackgroundColor")
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 30) {

                    VStack(alignment: .leading, spacing: 8) {

                        Text("Spin")
                            .font(.custom("Shafarik-Regular", size: 38))
                            .foregroundColor(.black)

                        Text("Let the wheel choose your next destination")
                            .font(.subheadline)
                            .foregroundColor(Color("AppBrown").opacity(0.75))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 12)
                    .padding(.trailing, 24)
                    .padding(.bottom, 20)

                    categoryPicker
                        .padding(.top, 8)
                    if filteredPlaces.isEmpty {
                        emptyState
                    } else {
                        wheelView
                            .padding(.top, 10)
                        
                        Button {
                            spinWheel()
                        } label: {
                            Text(String(localized: "SPIN"))
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color("AppOrange"))
                                .clipShape(Capsule())
                                .padding(.horizontal, 40)
                        }
                        
                     
                    }
                }
                .padding(.top, 24)
                .padding(.bottom, 100)
            }
            if let pickedPlace {
                Color.black.opacity(0.25)
                    .ignoresSafeArea()
                    .onTapGesture {
                        self.pickedPlace = nil
                    }

                resultCard(for: pickedPlace)
                    .padding(.horizontal, 26)
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(10)
            }
        }
    }
    
    private var categoryPicker: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            
            HStack(spacing: 10) {
                
                categoryChip(
                    String(localized: "All"),
                    emoji: "⭐️",
                    category: nil
                )
                
                categoryChip(
                    String(localized: "Cafes"),
                    emoji: "☕️",
                    category: .cafe
                )
                
                categoryChip(
                    String(localized: "Food"),
                    emoji: "🍽️",
                    category: .restaurant
                )
                
                categoryChip(
                    String(localized: "Shops"),
                    emoji: "🛍️",
                    category: .shopping
                )
                
                categoryChip(
                    String(localized: "Other"),
                    emoji: "+",
                    category: .other
                )
            }
            .padding(.leading, 4)
            .padding(.trailing, 24)
        }
    }
    private func categoryChip(
        _ title: String,
        emoji: String,
        category: PlaceCategory?
    ) -> some View {
        
        Button {
            selectedCategory = category
            pickedPlace = nil
        } label: {
            
            HStack(spacing: 6) {
                
                Text(emoji)
                    .font(.subheadline)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .lineLimit(1)
                    .fixedSize()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .fixedSize()
            .background(
                selectedCategory == category
                ? Color("OrangeBackground")
                : Color.white.opacity(0.95)
            )
            .foregroundColor(Color("AppBrown"))
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(
                        selectedCategory == category
                        ? Color("AppOrange")
                        : Color.clear,
                        lineWidth: 1.5
                    )
            )
            .shadow(
                color: .black.opacity(0.03),
                radius: 4,
                x: 0,
                y: 2
            )
        }
        .buttonStyle(.plain)
    }
    
    private var wheelView: some View {
        
        ZStack {
            
            Triangle()
                .fill(Color("AppOrange"))
                .frame(width: 28, height: 24)
                .rotationEffect(.degrees(90))
                .offset(x: 170)
                .zIndex(3)
            
            ZStack {
                
                Circle()
                    .fill(Color.white.opacity(0.96))
                    .frame(width: 310, height: 310)
                
                Circle()
                    .stroke(Color("AppBrown").opacity(0.25), lineWidth: 2)
                    .frame(width: 310, height: 310)
                
                // Lines behind names
                ForEach(0..<filteredPlaces.count, id: \.self) { index in
                    
                    Rectangle()
                        .fill(Color("AppBrown").opacity(0.14))
                        .frame(width: 1, height: 100)
                        .offset(y: -50)
                        .rotationEffect(
                            .degrees(
                                Double(index) / Double(filteredPlaces.count) * 360
                            )
                        )
                }
                
                // Place names
                ForEach(Array(filteredPlaces.enumerated()), id: \.element.id) { index, place in
                    
                    let angle = Double(index) / Double(filteredPlaces.count) * 360
                    
                    VStack(spacing: 3) {
                        
                        Text(place.category.emoji)
                            .font(.caption)
                        
                        Text(place.name)
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("AppBrown"))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .frame(width: 78)
                    }
                    .rotationEffect(.degrees(-angle))
                    .offset(y: -122)
                    .rotationEffect(.degrees(angle))
                    .zIndex(2)
                }
            }
            .rotationEffect(.degrees(rotation))
            .animation(.easeOut(duration: 2.2), value: rotation)
            .drawingGroup()
            
            Image("AppIconCenter")
                .resizable()
                .scaledToFit()
                .frame(width: 58, height: 58)
                .zIndex(4)
        }
        .frame(width: 360, height: 330)
    }
    
    private var emptyState: some View {
        
        VStack(spacing: 14) {
            
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundColor(Color("AppOrange"))
            
            Text("No places here yet")
                .font(.headline)
            
            Text("Save places in this category first, then come back to spin.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(30)
        .background(Color.white.opacity(0.9))
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .padding(.horizontal)
    }
    
    private func resultCard(for place: SavedPlace) -> some View {
        
        VStack(spacing: 10) {
            
            Text("Today's Pick")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(place.name)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(Color("AppOrange"))
            
            Text(place.neighborhood.isEmpty ? place.category.rawValue : place.neighborhood)
                .font(.subheadline)
                .foregroundColor(Color("AppBrown"))
            
            Button {
                openDirections(place)
            } label: {
                Label(
                    String(localized: "Open in Maps"),
                    systemImage: "location.fill"
                )
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                .background(Color("AppBrown"))
                .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(22)
        .background(Color.white.opacity(0.95))
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
        .padding(.horizontal, 24)
    }
    private func spinWheel() {
        
        guard !filteredPlaces.isEmpty else { return }
        
        pickedPlace = nil
        
        let randomIndex = Int.random(in: 0..<filteredPlaces.count)
        pendingPickedPlace = filteredPlaces[randomIndex]
        
        let segmentAngle = 360.0 / Double(filteredPlaces.count)
        let desiredPosition = 90.0
        let placePosition = Double(randomIndex) * segmentAngle
        
        let currentPosition =
            (rotation + placePosition)
            .truncatingRemainder(dividingBy: 360)
        
        let clockwiseAdjustment =
            (desiredPosition - currentPosition + 360)
            .truncatingRemainder(dividingBy: 360)
        
        withAnimation(.easeOut(duration: 2.2)) {
            rotation += Double(Int.random(in: 5...7)) * 360 + clockwiseAdjustment
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
            
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                pickedPlace = pendingPickedPlace
            }
        }
        }
    }
    
    private func openDirections(_ place: SavedPlace) {
        
        guard let lat = place.latitude,
              let lon = place.longitude else {
            return
        }
        
        let urlString =
        "https://www.google.com/maps/dir/?api=1&destination=\(lat),\(lon)&travelmode=driving"
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }


struct Triangle: Shape {
    
    func path(in rect: CGRect) -> Path {
        
        var path = Path()
        
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.closeSubpath()
        
        return path
    }
}

#Preview {
    SpinView()
        .modelContainer(for: SavedPlace.self, inMemory: true)
}
