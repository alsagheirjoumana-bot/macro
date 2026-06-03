import SwiftUI
import SwiftData

import SwiftUI
import SwiftData

struct ContentView: View {
    
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    
    @State private var showSplash = true
    
    var body: some View {
        
        if showSplash {
            
            SplashView()
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5.2) {
                        withAnimation {
                            showSplash = false
                        }
                    }
                }
            
        } else {
            
            if hasSeenOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
    }
}

struct MainTabView: View {
    @State private var selectedTab = 1
    @Query(sort: \SavedPlace.createdAt, order: .reverse)
    private var savedPlaces: [SavedPlace]
    
    var body: some View {
        
        TabView(selection: $selectedTab) {
            
            MapView()
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Map")
                }
                .tag(0)
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(1)

            SpinView()
                .tabItem {
                    Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
                    Text("Spin")
                }
                .tag(2)

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
