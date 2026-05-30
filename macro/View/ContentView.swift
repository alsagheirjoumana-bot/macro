//
//  ContentView.swift
//  macro
//
//  Created by Joumana Alsagheir on 11/05/2026.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        
        TabView {
            
            MapView()
                .tabItem {
                    Image(systemName: "map")
                    Text("Map")
                }
            
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
            
            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
        }
        .tint(Color("Brown"))
    }
}
#Preview {
    ContentView()
}
