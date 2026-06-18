import SwiftUI

@main
struct CravingConverterApp: App {
    @StateObject private var dataStore    = DataStore.shared
    @StateObject private var audioPlayer  = AudioPlayer.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(dataStore)
                .environmentObject(audioPlayer)
                .preferredColorScheme(.dark)
                .onAppear { audioPlayer.play() }
        }
    }
}

struct RootView: View {
    @EnvironmentObject var dataStore: DataStore
    @EnvironmentObject var audioPlayer: AudioPlayer
    @State private var showSession = false

    var body: some View {
        HomeView(showSession: $showSession)
            .sheet(isPresented: $showSession) {
                SessionFlowView(isPresented: $showSession)
                    .environmentObject(dataStore)
                    .environmentObject(audioPlayer)
            }
    }
}
