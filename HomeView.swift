import SwiftUI

struct Show: Identifiable {
    let id = UUID()
    let name: String
    let rating: String
    let genre: String
    let kind: String
}

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

private let trending = [
    Show(name: "Paintings On The Wall", rating: "9", genre: "Drama", kind: "FILM"),
    Show(name: "Ghosts", rating: "9.1", genre: "Horror", kind: "FILM"),
    Show(name: "Monday Mourning", rating: "9", genre: "Drama", kind: "FILM"),
]
private let recommended = [
    Show(name: "Mr Static", rating: "9", genre: "Horror", kind: "FILM"),
    Show(name: "Ritual", rating: "9", genre: "Horror", kind: "FILM"),
    Show(name: "Or Forever Hold Your Peace", rating: "9.1", genre: "Comedy", kind: "FILM"),
]
private let topRated = [
    Show(name: "Suicide Note", rating: "9", genre: "Drama", kind: "FILM"),
    Show(name: "180", rating: "9.1", genre: "Thriller", kind: "FILM"),
    Show(name: "Ghosts", rating: "9.1", genre: "Horror", kind: "FILM"),
]

struct HomeView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                HeroView()
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
                ShowRow(title: "Trending Now", shows: trending)
                ShowRow(title: "Recommended For You", shows: recommended)
                ShowRow(title: "Top Rated", shows: topRated)
            }
            .padding(.bottom, 24)
        }
        .background(Color.vBackground.ignoresSafeArea())
    }
}

struct HeroView: View {
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(colors: [Color(hex: 0x0B3A63), .vBackground],
                           startPoint: .topTrailing, endPoint: .bottom)
            VStack(alignment: .leading, spacing: 14) {
                Label("NIGHT — FILM", systemImage: "bolt.fill")
                    .font(.caption.weight(.bold)).tracking(3)
                    .foregroundColor(.vAccent)
                    .padding(.horizontal, 12).padding(.vertical, 8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.vAccent.opacity(0.4), lineWidth: 1))
                Text("MR\nSTATIC").font(.vTitle(64)).tracking(4).foregroundColor(.white)
                HStack(spacing: 8) {
                    Image(systemName: "star.fill").foregroundColor(.vAccent)
                    Text("9")
                    Text("2025")
                    Text("9m 17s")
                    Text("Horror").padding(.horizontal, 8).padding(.vertical, 3)
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.vAccent.opacity(0.5), lineWidth: 1))
                }
                .font(.system(size: 15)).foregroundColor(.vMuted)
                Text("A woman discovers a mysterious television broadcast airing a live feed of brutal crimes, forcing her into a desperate game of survival where looking away could mean certain death.")
                    .font(.system(size: 15)).foregroundColor(.vMuted)
                HStack(spacing: 12) {
                    Button { } label: {
                        Label("Play", systemImage: "play.fill")
                            .font(.system(size: 17, weight: .semibold)).foregroundColor(.black)
                            .padding(.horizontal, 28).padding(.vertical, 14)
                            .background(Color(hex: 0xF2F4F8))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                    Button { } label: {
                        Image(systemName: "plus").font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white).frame(width: 52, height: 52)
                            .overlay(Circle().stroke(Color.vMuted, lineWidth: 2))
                    }
                }
            }
            .padding(20)
        }
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
                    ForEach(shows) { ShowCard(show: $0).frame(width: 190) }
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
            // Placeholder until thumbnails load from Firebase
            LinearGradient(colors: [Color(hex: 0x10243F), .black],
                           startPoint: .topLeading, endPoint: .bottomTrailing)
                .aspectRatio(16 / 9, contentMode: .fit)
            VStack(alignment: .leading, spacing: 6) {
                Text(show.name).font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white).lineLimit(2)
                HStack(spacing: 6) {
                    Image(systemName: "star.fill").foregroundColor(.vAccent)
                    Text(show.rating)
                    Text("·")
                    Text(show.genre)
                    Text("·")
                    Text(show.kind).fontWeight(.bold).foregroundColor(.vAccent)
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
