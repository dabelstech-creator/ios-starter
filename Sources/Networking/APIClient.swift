import Foundation

enum APIError: Error {
    case invalidURL
    case network(Error)
    case decoding(Error)
}

final class APIClient {
    private let baseURL: URL
    private let session: URLSession

    init(baseURL: URL = URL(string: "https://jsonplaceholder.typicode.com")!, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    // Fetch sample todos (JSONPlaceholder shape differs; map to local model)
    func fetchTodos() async throws -> [Todo] {
        let url = baseURL.appendingPathComponent("/todos")
        do {
            let (data, _) = try await session.data(from: url)
            // JSONPlaceholder Todo shape: {"userId":1,"id":1,"title":"...","completed":false}
            let remote = try JSONDecoder().decode([RemoteTodo].self, from: data)
            return remote.map { Todo(id: UUID(), title: $0.title, isCompleted: $0.completed, createdAt: Date()) }
        } catch let err as DecodingError {
            throw APIError.decoding(err)
        } catch {
            throw APIError.network(error)
        }
    }

    private struct RemoteTodo: Codable {
        let userId: Int
        let id: Int
        let title: String
        let completed: Bool
    }
}
