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
    @EnvironmentObject var auth: AuthStore

    private var live: [Show] { store.shows.filter { $0.comingSoon != true && auth.allows($0) } }
    private var hero: Show? {
        heroIds.compactMap { id in live.first { $0.id == id } }.first ?? live.first
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    if let hero = hero {
                        HeroView(show: hero)
                    } else {
                        Color.vBackground.frame(height: 300)
                    }
                    HStack(spacing: 8) {
                        ForEach(studios) { s in
                            Text(s.name)
                                .font(.vTitle(17)).tracking(1).foregroundColor(s.text)
                                .frame(maxWidth: .infinity, minHeight: 46)
                                .background(s.tint)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(s.text.opacity(0.25), lineWidth: 1))
                        }
                    }
                    .padding(.horizontal, 12)

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
                .padding(.bottom, 16)
            }
            .background(Color.vBackground.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

struct HeroView: View {
    let show: Show
    @EnvironmentObject var myList: AuthStore
    @State private var playing: PlayItem?

    var body: some View {
        Color.vBackground
            .frame(maxWidth: .infinity)
            .frame(height: 320)
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
                LinearGradient(colors: [Color.vBackground.opacity(0.1), Color.vBackground.opacity(0.85), .vBackground],
                               startPoint: .top, endPoint: .bottom)
            )
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 10) {
                    Label("\(show.channel.uppercased()) — \((show.isMovie ?? false) ? "FILM" : "SERIES")", systemImage: "bolt.fill")
                        .font(.outfit(10, .bold)).tracking(2.5)
                        .foregroundColor(.vAccent)
                        .padding(.horizontal, 9).padding(.vertical, 5)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.vAccent.opacity(0.4), lineWidth: 1))
                    Text(show.title.uppercased())
                        .font(.vTitle(46)).tracking(3).foregroundColor(.white)
                        .lineLimit(2).lineSpacing(-4)
                    HStack(spacing: 7) {
                        Image(systemName: "star.fill").foregroundColor(.vAccent)
                        Text(show.ratingText)
                        Text(String(show.year))
                        if let rt = show.runtime, !rt.isEmpty { Text(rt) }
                        Text(show.genre).padding(.horizontal, 6).padding(.vertical, 2)
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.vAccent.opacity(0.5), lineWidth: 1))
                    }
                    .font(.outfit(12)).foregroundColor(.vMuted)
                    Text(show.desc)
                        .font(.outfit(13)).foregroundColor(.vMuted).lineLimit(3)
                        .fixedSize(horizontal: false, vertical: true)
                    HStack(spacing: 10) {
                        Button { if let u = show.firstVideoURL { playing = PlayItem(url: u) } } label: {
                            Label("Play", systemImage: "play.fill")
                                .font(.outfit(15, .semibold)).foregroundColor(.black)
                                .padding(.horizontal, 20).padding(.vertical, 10)
                                .background(Color(hex: 0xF2F4F8))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        Button { myList.toggle(show.id, title: show.title) } label: {
                            Image(systemName: myList.contains(show.id) ? "checkmark" : "plus")
                                .font(.outfit(16, .semibold))
                                .foregroundColor(.white).frame(width: 40, height: 40)
                                .overlay(Circle().stroke(Color.vMuted, lineWidth: 1.5))
                        }
                    }
                }
                .padding(.horizontal, 14).padding(.bottom, 12)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .fullScreenCover(item: $playing) { item in PlayerScreen(url: item.url) }
    }
}

struct ShowRow: View {
    let title: String
    let shows: [Show]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title.uppercased()).font(.outfit(16, .semibold)).tracking(0.5).foregroundColor(.white)
                Spacer()
                Text("See All →").font(.outfit(13)).foregroundColor(.vMuted)
            }
            .padding(.horizontal, 12)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(shows) { s in
                        NavigationLink { DetailView(show: s) } label: {
                            ShowCard(show: s, compact: true).frame(width: 128)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 12)
            }
        }
    }
}

struct ShowCard: View {
    let show: Show
    var compact = false

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
            VStack(alignment: .leading, spacing: compact ? 4 : 6) {
                Text(show.title).font(.outfit(compact ? 13 : 15, .semibold))
                    .foregroundColor(.white).lineLimit(2)
                    .frame(maxWidth: .infinity, minHeight: compact ? 34 : 38, alignment: .topLeading)
                HStack(spacing: compact ? 4 : 6) {
                    Image(systemName: "star.fill").foregroundColor(.vAccent)
                    Text(show.ratingText)
                    Text("·")
                    Text(show.genre)
                    Text("·")
                    Text(show.kindLabel).fontWeight(.bold).foregroundColor(.vAccent)
                }
                .font(.outfit(compact ? 10.5 : 12)).foregroundColor(.vMuted).lineLimit(1)
            }
            .padding(compact ? 8 : 11)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.vCard)
        .clipShape(RoundedRectangle(cornerRadius: compact ? 12 : 14))
        .overlay(RoundedRectangle(cornerRadius: compact ? 12 : 14).stroke(Color.vBorder, lineWidth: 1))
    }
}
