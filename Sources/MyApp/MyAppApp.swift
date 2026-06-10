import SwiftUI
import MyAppCore

@main
struct MyAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

private struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("MyApp")
                .font(.largeTitle)
            Text("Version \(AppVersion.marketing)")
                .foregroundStyle(.secondary)
            Text("Replace this view with your app.")
                .font(.callout)
        }
        .frame(minWidth: 420, minHeight: 280)
        .padding()
    }
}
