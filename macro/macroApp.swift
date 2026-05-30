import SwiftUI
import SwiftData

@main
struct macroApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: SavedPlace.self)
    }
}
