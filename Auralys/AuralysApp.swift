import SwiftUI

@main
struct AuralysApp: App {
    @StateObject private var player = AudioPlayer()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(player)
                .preferredColorScheme(.dark)
        }
    }
}
