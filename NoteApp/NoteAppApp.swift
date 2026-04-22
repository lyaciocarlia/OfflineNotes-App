import SwiftUI
import SwiftData

@main
struct NoteAppApp: App {
    @State private var networkMonitor = NetworkMonitor()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Note.self,
            SyncOperation.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView(networkMonitor: networkMonitor)
                .onChange(of: networkMonitor.isConnected) { _, isConnected in
                    if isConnected {
                        let context = sharedModelContainer.mainContext
                        Task {
                            let sync = SyncService(modelContext: context)
                            await sync.syncAll()
                        }
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
