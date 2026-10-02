import SwiftUI

struct Studio: Identifiable {
    let id = UUID()
    let name: String
    let tint: Color
    let text: Color
}

private let studios = [
    Studio(name: "NOVA", tint: Color(hex: 0x0E3A78), text: .vAccent),
    Studio(name: "SPARK", tint: Color(hex: 0x10244A), text: Color(hex: 0x6FA8FF)),
    Studio(name: "NOSLEEP", tint: Color(hex: 0x0A2A26), text: Color(hex: 0x2EE6B8)),
    Studio(name: "KINGDOM", tint: Color(hex: 0x2A2412), text: Color(hex: 0xC9A646)),
]

private let heroIds = [21, 31, 27]

struct HomeView: View {
    @EnvironmentObject var store: ShowStore

    private var live: [Show] { store.shows.filter { $0.comingSoon != true } }
    private var hero: Show? {
        heroIds.compactMap { id in store.shows.first { $0.id == id } }.first
    }

    var body: some View {
        NavigationStack {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                if let hero = hero {
                    HeroView(show: hero)
                } else {
                    Color.vBackground.frame(height: 360)
                }
                HStack(spacing: 10) {
                    ForEach(studios) { s in
                        Text(s.name)
                            .font(.vTitle(18)).foregroundColor(s.text)
                            .frame(maxWidth: .infinity, minHeight: 64)
                            .background(s.tint)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(RoundedRectangle(cornerRadius: 14).stroke(s.text.opacity(0.25), lineWidth: 1))
                    }
                }
                .padding(.horizontal, 16)

                if store.shows.isEmpty {
                    Text(store.loadFailed ? "Couldn't load titles. Check your connection." : "Loading…")
                        .foregroundColor(.vMuted)
                        .frame(maxWidth: .infinity)
                } else {
                    ShowRow(title: "Trending Now", shows: Array(live.reversed().prefix(8)))
                    ShowRow(title: "Recommended For You", shows: Array(live.prefix(8)))
                    ShowRow(title: "Top Rated", shows: Array(live.sorted { $0.rating > $1.rating }.prefix(8)))
                }
            }
            .padding(.bottom, 24)
        }
        .background(Color.vBackground.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        }
    }
}

struct HeroView: View {
    let show: Show
    @EnvironmentObject var myList: MyListStore
    @State private var playing: PlayItem?

    var body: some View {
        Color.vBackground
            .frame(maxWidth: .infinity)
            .frame(height: 520)
            .overlay(
                AsyncImage(url: show.imageURL) { phase in
                    if let img = phase.image {
                        img.resizable().scaledToFill()
                    } else {
                        Color.clear
                    }
                }
            )
            .clipped()
            .overlay(
                LinearGradient(colors: [.clear, Color.vBackground.opacity(0.85), .vBackground],
                               startPoint: .center, endPoint: .bottom)
            )
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 14) {
                    Label("\(show.channel.uppercased()) — \((show.isMovie ?? false) ? "FILM" : "SERIES")", systemImage: "bolt.fill")
                        .font(.caption.weight(.bold)).tracking(3)
                        .foregroundColor(.vAccent)
                        .padding(.horizontal, 12).padding(.vertical, 8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.vAccent.opacity(0.4), lineWidth: 1))
                    Text(show.title.uppercased())
                        .font(.vTitle(52)).tracking(3).foregroundColor(.white).lineLimit(3)
                    HStack(spacing: 8) {
                        Image(systemName: "star.fill").foregroundColor(.vAccent)
                        Text(show.ratingText)
                        Text(String(show.year))
                        if let rt = show.runtime, !rt.isEmpty { Text(rt) }
                        Text(show.genre).padding(.horizontal, 8).padding(.vertical, 3)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.vAccent.opacity(0.5), lineWidth: 1))
                    }
                    .font(.system(size: 15)).foregroundColor(.vMuted)
                    Text(show.desc)
                        .font(.system(size: 15)).foregroundColor(.vMuted).lineLimit(4)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: 12) {
                        Button { if let u = show.firstVideoURL { playing = PlayItem(url: u) } } label: {
                            Label("Play", systemImage: "play.fill")
                                .font(.system(size: 17, weight: .semibold)).foregroundColor(.black)
                                .padding(.horizontal, 28).padding(.vertical, 14)
                                .background(Color(hex: 0xF2F4F8))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                        Button { myList.toggle(show.id) } label: {
                            Image(systemName: myList.contains(show.id) ? "checkmark" : "plus").font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white).frame(width: 52, height: 52)
                                .overlay(Circle().stroke(Color.vMuted, lineWidth: 2))
                        }
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .fullScreenCover(item: $playing) { item in PlayerScreen(url: item.url) }
    }
}

struct ShowRow: View {
    let title: String
    let shows: [Show]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(title.uppercased()).font(.system(size: 20, weight: .bold)).foregroundColor(.white)
                Spacer()
                Text("See All").font(.subheadline).foregroundColor(.vMuted)
            }
            .padding(.horizontal, 16)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(shows) { s in
                        NavigationLink { DetailView(show: s) } label: {
                            ShowCard(show: s).frame(width: 190)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}

struct ShowCard: View {
    let show: Show

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                Color.black
                AsyncImage(url: show.imageURL) { phase in
                    if let img = phase.image {
                        img.resizable().scaledToFit()
                    } else {
                        LinearGradient(colors: [Color(hex: 0x10244A), .black],
                                       startPoint: .topLeading, endPoint: .bottomTrailing)
                    }
                }
            }
            .aspectRatio(3 / 2, contentMode: .fit)
            .clipped()
            VStack(alignment: .leading, spacing: 6) {
                Text(show.title).font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white).lineLimit(2)
                HStack(spacing: 6) {
                    Image(systemName: "star.fill").foregroundColor(.vAccent)
                    Text(show.ratingText)
                    Text("·")
                    Text(show.genre)
                    Text("·")
                    Text(show.kindLabel).fontWeight(.bold).foregroundColor(.vAccent)
                }
                .font(.system(size: 13)).foregroundColor(.vMuted)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.vCard)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.vBorder, lineWidth: 1))
    }
}
