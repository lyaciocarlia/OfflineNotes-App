import Foundation
import SwiftData

@Model
final class SyncOperation {
    var id: UUID
    var noteId: UUID
    var operation: String
    var payload: String

    init(id: UUID = UUID(), noteId: UUID, operation: String, payload: String) {
        self.id = id
        self.noteId = noteId
        self.operation = operation
        self.payload = payload
    }
}
