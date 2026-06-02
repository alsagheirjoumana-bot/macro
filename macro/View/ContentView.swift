import SwiftUI

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
    }
}

#Preview {
    ContentView()
}
