import Foundation

struct APINote: Codable {
    let id: String
    let content: String
    let createdAt: String
}

final class APIService {
    static let shared = APIService()

    private let baseURL = "https://6807e425942707d722de7a47.mockapi.io/api/v1/notes"

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        return d
    }()

    private let encoder = JSONEncoder()

    private init() {}

    // MARK: - Fetch all notes

    func fetchNotes() async throws -> [APINote] {
        let url = URL(string: baseURL)!
        let (data, _) = try await URLSession.shared.data(from: url)
        return try decoder.decode([APINote].self, from: data)
    }

    // MARK: - Create

    func createNote(id: UUID, content: String, createdAt: Date) async throws {
        let url = URL(string: baseURL)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = [
            "id": id.uuidString,
            "content": content,
            "createdAt": ISO8601DateFormatter().string(from: createdAt)
        ]
        request.httpBody = try encoder.encode(body)

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }

    // MARK: - Update

    func updateNote(id: UUID, content: String) async throws {
        let url = URL(string: "\(baseURL)/\(id.uuidString)")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = ["content": content]
        request.httpBody = try encoder.encode(body)

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }

    // MARK: - Delete

    func deleteNote(id: UUID) async throws {
        let url = URL(string: "\(baseURL)/\(id.uuidString)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw URLError(.badServerResponse)
        }
    }
}
