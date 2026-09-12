import SwiftUI

final class TodoViewModel: ObservableObject {
    @Published private(set) var todos: [Todo] = []
    @Published var showCompleted: Bool = Settings.shared.showCompleted {
        didSet { Settings.shared.showCompleted = showCompleted }
    }

    private let api = APIClient()
    private let persistence = PersistenceController.shared

    init() {
        // load persisted
        do {
            todos = try persistence.fetchTodos()
        } catch {
            todos = []
        }
    }

    func add(title: String) {
        let todo = Todo(title: title)
        todos.append(todo)
        try? persistence.save(todo: todo)
    }

    func toggle(_ todo: Todo) {
        guard let idx = todos.firstIndex(of: todo) else { return }
        todos[idx].isCompleted.toggle()
        // Persist: delete and re-save for simplicity
        try? persistence.delete(todoID: todo.id)
        try? persistence.save(todo: todos[idx])
    }

    func fetchRemoteTodos() async -> Result<[Todo], Error> {
        do {
            let remote = try await api.fetchTodos()
            // For demo, append first 5
            let slice = Array(remote.prefix(5))
            for t in slice {
                try? persistence.save(todo: t)
            }
            todos.append(contentsOf: slice)
            return .success(slice)
        } catch {
            return .failure(error)
        }
    }
}
