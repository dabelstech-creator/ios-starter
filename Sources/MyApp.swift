import SwiftUI

@main
struct MyApp: App {
    @StateObject private var viewModel = TodoViewModel()

    var body: some Scene {
        WindowGroup {
            TodoListView()
                .environmentObject(viewModel)
        }
    }
}
