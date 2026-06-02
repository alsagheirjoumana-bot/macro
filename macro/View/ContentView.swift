import SwiftUI
import SwiftData

struct ContentView: View {
    
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    var body: some View {
        
        if hasSeenOnboarding {
            MainTabView()
        } else {
            OnboardingView()
        }
    }
}

struct MainTabView: View {
    
    @Query(sort: \SavedPlace.createdAt, order: .reverse)
    private var savedPlaces: [SavedPlace]
    
    var body: some View {
        
        TabView {
            
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            MapView()
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Map")
                }
            
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
        }
        .tint(Color("AppBrown"))
        .onAppear {
            PlaceNotificationManager.shared.requestPermissions()
            PlaceNotificationManager.shared.monitorPlaces(savedPlaces)
        }
        .onChange(of: savedPlaces.count) { _, _ in
            PlaceNotificationManager.shared.monitorPlaces(savedPlaces)
        }
    }
}

#Preview {
    ContentView()
}
