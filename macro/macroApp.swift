import SwiftUI
import SwiftData

@main
struct macroApp: App {

    var sharedModelContainer: ModelContainer = {

        let schema = Schema([
            SavedPlace.self
        ])

        let appGroupID = "group.com.may.macro"

        let storeURL = FileManager.default
            .containerURL(
                forSecurityApplicationGroupIdentifier: appGroupID
            )?
            .appendingPathComponent("Macro.sqlite")
            ?? URL.applicationSupportDirectory
             
        

        let configuration = ModelConfiguration(
            schema: schema,
            url: storeURL
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: [configuration]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light)
                .onAppear {

                    NotificationManager.shared.requestNotificationPermission()

                    NotificationManager.shared.requestLocationPermission()

                    NotificationManager.shared.scheduleTimeReminder()

                }
        }
        .modelContainer(sharedModelContainer)
    }
}
