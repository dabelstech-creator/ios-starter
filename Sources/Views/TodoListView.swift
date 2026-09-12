import SwiftUI

struct TodoListView: View {
    @EnvironmentObject var viewModel: TodoViewModel
    @State private var newTitle: String = ""
    @State private var loading = false

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.todos.filter { viewModel.showCompleted ? true : !$0.isCompleted }) { todo in
                    HStack {
                        Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                            .onTapGesture { viewModel.toggle(todo) }
                        Text(todo.title)
                    }
                }
            }
            .navigationTitle("Todos")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack {
                        TextField("New todo", text: $newTitle)
                            .textFieldStyle(.roundedBorder)
                        Button("Add") {
                            guard !newTitle.isEmpty else { return }
                            viewModel.add(title: newTitle)
                            newTitle = ""
                        }
                    }
                    .frame(maxWidth: 520)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: loadRemote) {
                        if loading { ProgressView() } else { Image(systemName: "icloud.and.arrow.down") }
                    }
                }
            }
        }
    }

    func loadRemote() {
        loading = true
        Task {
            _ = await viewModel.fetchRemoteTodos()
            loading = false
        }
    }
}
