import SwiftUI
import FirebaseCore
import CoreText

@main
struct VoltageApp: App {
    init() {
        for ext in ["ttf", "otf"] {
            for url in Bundle.main.urls(forResourcesWithExtension: ext, subdirectory: nil) ?? [] {
                CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
            }
        }
        if Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") != nil {
            FirebaseApp.configure()
        }
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
    @StateObject private var auth = AuthStore()

    var body: some View {
        Group {
            if !auth.ready {
                ZStack {
                    Color(hex: 0x07090F).ignoresSafeArea()
                    VStack(spacing: 14) {
                        Text("STREAMING").font(.outfit(13, .medium)).tracking(8)
                            .foregroundColor(Color(hex: 0x2E6F73))
                        Text("VOLTAGE").font(.vTitle(56)).tracking(14).foregroundColor(.white)
                    }
                }
            } else if auth.user == nil {
                AuthView()
            } else if !auth.profileChosen {
                ProfilesView()
            } else {
                TabView {
                    HomeView().tabItem { Label("HOME", systemImage: "house") }
                    ExploreView().tabItem { Label("EXPLORE", systemImage: "plus.viewfinder") }
                    MyListView().tabItem { Label("MY LIST", systemImage: "heart") }
                    GalleryView().tabItem { Label("GALLERY", systemImage: "square.stack") }
                    SettingsView().tabItem { Label("SETTINGS", systemImage: "gearshape") }
                }
                .tint(.vAccent)
            }
        }
        .environmentObject(store)
        .environmentObject(auth)
        .task { await store.load() }
    }
}
