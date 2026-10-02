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
    @StateObject private var store = ShowStore()
    @StateObject private var myList = MyListStore()

    var body: some View {
        TabView {
            HomeView().tabItem { Label("HOME", systemImage: "house") }
            ExploreView().tabItem { Label("EXPLORE", systemImage: "plus.viewfinder") }
            MyListView().tabItem { Label("MY LIST", systemImage: "heart") }
            GalleryView().tabItem { Label("GALLERY", systemImage: "square.stack") }
            SettingsView().tabItem { Label("SETTINGS", systemImage: "gearshape") }
        }
        .tint(.vAccent)
        .environmentObject(store)
        .environmentObject(myList)
        .task { await store.load() }
    }
}
