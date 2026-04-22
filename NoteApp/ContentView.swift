import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Note.createdAt, order: .reverse) private var notes: [Note]
    var networkMonitor: NetworkMonitor

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ConnectionBanner(isConnected: networkMonitor.isConnected)
                    .padding(.top, 8)

                List {
                    ForEach(notes) { note in
                        NavigationLink(destination: NoteDetailView(networkMonitor: networkMonitor, note: note)) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(note.content)
                                    .lineLimit(2)
                                Text(note.createdAt, format: .dateTime.month().day().hour().minute())
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .onDelete(perform: deleteNotes)
                }
                .listStyle(.plain)
            }
            .navigationTitle("Notes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink(destination: NoteDetailView(networkMonitor: networkMonitor)) {
                        Label("New Note", systemImage: "plus")
                    }
                }
            }
        }
    }

    private func deleteNotes(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let note = notes[index]
                enqueueDelete(note: note)
                modelContext.delete(note)
            }
            try? modelContext.save()

            if networkMonitor.isConnected {
                triggerSync()
            }
        }
    }

    private func enqueueDelete(note: Note) {
        let syncOp = SyncOperation(noteId: note.id, operation: "delete", payload: "{}")
        modelContext.insert(syncOp)
    }

    private func triggerSync() {
        let context = modelContext
        Task {
            let sync = SyncService(modelContext: context)
            await sync.syncAll()
        }
    }
}

#Preview {
    ContentView(networkMonitor: NetworkMonitor())
        .modelContainer(for: [Note.self, SyncOperation.self], inMemory: true)
}
