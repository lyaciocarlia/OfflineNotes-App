import SwiftUI
import SwiftData

struct NoteDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    var networkMonitor: NetworkMonitor

    var note: Note?
    @State private var content: String = ""

    private var isNew: Bool { note == nil }

    var body: some View {
        Form {
            Section("Content") {
                TextEditor(text: $content)
                    .frame(minHeight: 200)
            }
        }
        .navigationTitle(isNew ? "New Note" : "Edit Note")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    save()
                }
                .disabled(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .onAppear {
            if let note {
                content = note.content
            }
        }
    }

    private func save() {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)

        if let note {
            note.content = trimmed
            enqueueSync(noteId: note.id, operation: "update", content: trimmed, createdAt: note.createdAt)
        } else {
            let newNote = Note(content: trimmed)
            modelContext.insert(newNote)
            enqueueSync(noteId: newNote.id, operation: "create", content: trimmed, createdAt: newNote.createdAt)
        }

        try? modelContext.save()

        if networkMonitor.isConnected {
            triggerSync()
        }

        dismiss()
    }

    private func enqueueSync(noteId: UUID, operation: String, content: String, createdAt: Date) {
        let payload: [String: String] = [
            "content": content,
            "createdAt": ISO8601DateFormatter().string(from: createdAt)
        ]
        let json = (try? JSONEncoder().encode(payload)).flatMap { String(data: $0, encoding: .utf8) } ?? "{}"

        let syncOp = SyncOperation(noteId: noteId, operation: operation, payload: json)
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
