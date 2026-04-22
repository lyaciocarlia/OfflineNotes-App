import Foundation
import SwiftData

final class SyncService {
    private let modelContext: ModelContext
    private let api = APIService.shared

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func syncAll() async {
        let descriptor = FetchDescriptor<SyncOperation>(sortBy: [SortDescriptor(\.id)])

        guard let operations = try? modelContext.fetch(descriptor), !operations.isEmpty else {
            return
        }

        for op in operations {
            do {
                switch op.operation {
                case "create":
                    let payload = try decodePayload(op.payload)
                    let date = ISO8601DateFormatter().date(from: payload["createdAt"] ?? "") ?? Date()
                    try await api.createNote(
                        id: op.noteId,
                        content: payload["content"] ?? "",
                        createdAt: date
                    )
                case "update":
                    let payload = try decodePayload(op.payload)
                    try await api.updateNote(
                        id: op.noteId,
                        content: payload["content"] ?? ""
                    )
                case "delete":
                    try await api.deleteNote(id: op.noteId)
                default:
                    break
                }
                modelContext.delete(op)
                try modelContext.save()
                print("[Sync] Completed \(op.operation) for note \(op.noteId)")
            } catch {
                print("[Sync] Failed \(op.operation) for note \(op.noteId): \(error)")
            }
        }
    }

    private func decodePayload(_ json: String) throws -> [String: String] {
        guard let data = json.data(using: .utf8) else { return [:] }
        return try JSONDecoder().decode([String: String].self, from: data)
    }
}
