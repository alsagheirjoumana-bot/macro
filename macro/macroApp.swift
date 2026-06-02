import SwiftUI
import SwiftData

@main
struct macroApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
        }
        .modelContainer(for: SavedPlace.self)
    }
}
