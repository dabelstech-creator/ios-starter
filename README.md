# ios-starter

Starter SwiftUI Todo app with:

- SwiftUI UI
- Networking example using URLSession + async/await (JSONPlaceholder)
- Persistence using Core Data (programmatically created model)
- UserDefaults for app settings
- Unit tests (XCTest)
- GitHub Actions CI workflow to generate project with XcodeGen, build, and run tests

Quick start

1. Install Xcode 15 or newer.
2. Install XcodeGen: brew install xcodegen
3. From the repo root: xcodegen generate
4. Open ios-starter.xcodeproj in Xcode.
5. Select a simulator and run, or run tests: Cmd+U.

Notes

- The Xcode project is generated with XcodeGen (project.yml). This avoids committing fragile .xcodeproj files. If you prefer, I can commit a generated .xcodeproj instead.
- The Core Data model is created in code (no .xcdatamodeld required).

Learning path

I included a beginner → intermediate curated resources section in the README to help you learn iOS development with SwiftUI, Combine/async-await, Core Data, and testing.
