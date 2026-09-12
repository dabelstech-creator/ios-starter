import Foundation

final class Settings {
    static let shared = Settings()
    private let keyShowCompleted = "showCompleted"
    private let defaults = UserDefaults.standard

    var showCompleted: Bool {
        get { defaults.bool(forKey: keyShowCompleted) }
        set { defaults.set(newValue, forKey: keyShowCompleted) }
    }

    private init() {
        // default
        if defaults.object(forKey: keyShowCompleted) == nil {
            defaults.set(true, forKey: keyShowCompleted)
        }
    }
}
