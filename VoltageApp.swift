import SwiftUI

@main
struct VoltageApp: App {
    init() {
        let bar = UITabBarAppearance()
        bar.configureWithOpaqueBackground()
        bar.backgroundColor = UIColor(Color.vBackground)
        UITabBar.appearance().standardAppearance = bar
        UITabBar.appearance().scrollEdgeAppearance = bar
    }

    var body: some Scene {
        WindowGroup {
            RootView().preferredColorScheme(.dark)
        }
    }
}

struct RootView: View {
    var body: some View {
        TabView {
            HomeView().tabItem { Label("HOME", systemImage: "house") }
            PlaceholderView(title: "EXPLORE").tabItem { Label("EXPLORE", systemImage: "plus.viewfinder") }
            PlaceholderView(title: "MY LIST").tabItem { Label("MY LIST", systemImage: "heart") }
            PlaceholderView(title: "GALLERY").tabItem { Label("GALLERY", systemImage: "square.stack") }
            PlaceholderView(title: "SETTINGS").tabItem { Label("SETTINGS", systemImage: "gearshape") }
        }
        .tint(.vAccent)
    }
}

struct PlaceholderView: View {
    let title: String
    var body: some View {
        ZStack {
            Color.vBackground.ignoresSafeArea()
            Text(title).font(.vTitle(40)).tracking(4).foregroundColor(.white)
        }
    }
}
