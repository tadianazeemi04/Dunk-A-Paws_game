import SwiftUI

@main
struct DunkAPawsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(GameManager.shared)
                .environmentObject(GameProgressManager.shared)
        }
    }
}
