import XCTest
@testable import ios_starter

final class APIClientTests: XCTestCase {
    func testFetchTodosDecoding() async throws {
        // Use a local JSON to test decoding
        let json = "[ { \"userId\": 1, \"id\": 1, \"title\": \"Test\", \"completed\": false } ]"
        let data = Data(json.utf8)
        let decoder = JSONDecoder()
        let remote = try decoder.decode([APIClient.RemoteTodo].self, from: data)
        XCTAssertEqual(remote.count, 1)
        XCTAssertEqual(remote.first?.title, "Test")
    }

    func testAPIClientFetch() async throws {
        let client = APIClient()
        let todos = try await client.fetchTodos()
        XCTAssertNotNil(todos)
        // Expect it to return an array
        XCTAssertTrue(todos.count > 0)
    }
}

final class PersistenceTests: XCTestCase {
    func testSaveAndFetch() throws {
        let pc = PersistenceController(inMemory: true)
        let todo = Todo(title: "Persisted")
        try pc.save(todo: todo)
        let fetched = try pc.fetchTodos()
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.title, "Persisted")
    }
}
