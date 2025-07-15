import SwiftUI

@main
struct DPIManagerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(width: 500, height: 700)
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .windowResizability(.contentSize)
    }
}
