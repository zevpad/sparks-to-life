import SwiftUI

@main
struct CravingConverterApp: App {
    @StateObject private var dataStore = DataStore.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(dataStore)
                .preferredColorScheme(.dark)
        }
    }
}

struct RootView: View {
    @EnvironmentObject var dataStore: DataStore
    @State private var showSession = false

    var body: some View {
        HomeView(showSession: $showSession)
            .sheet(isPresented: $showSession) {
                SessionFlowView(isPresented: $showSession)
                    .environmentObject(dataStore)
            }
    }
}
