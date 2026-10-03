import SwiftUI
import AVKit

struct PlayerScreen: View {
    let url: URL
    @Environment(\.dismiss) private var dismiss
    @State private var player: AVPlayer?

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.black.ignoresSafeArea()
            if let player = player {
                VideoPlayer(player: player).ignoresSafeArea()
            }
            Button { dismiss() } label: {
                Image(systemName: "xmark")
                    .font(.outfit(16, .bold)).foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.black.opacity(0.55)).clipShape(Circle())
            }
            .padding(16)
        }
        .onAppear {
            try? AVAudioSession.sharedInstance().setCategory(.playback)
            try? AVAudioSession.sharedInstance().setActive(true)
            let p = AVPlayer(url: url)
            player = p
            p.play()
        }
        .onDisappear { player?.pause() }
    }
}

struct DetailView: View {
    let show: Show
    @EnvironmentObject var myList: AuthStore
    @State private var playing: PlayItem?

    private func play(_ url: URL?) {
        if let url = url { playing = PlayItem(url: url) }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                ZStack {
                    Color.black
                    AsyncImage(url: show.imageURL) { phase in
                        if let img = phase.image {
                            img.resizable().scaledToFit()
                        } else {
                            Color.clear
                        }
                    }
                }
                .aspectRatio(16 / 9, contentMode: .fit)

                VStack(alignment: .leading, spacing: 14) {
                    Text(show.title.uppercased())
                        .font(.vTitle(40)).tracking(2).foregroundColor(.white)
                    HStack(spacing: 8) {
                        Image(systemName: "star.fill").foregroundColor(.vAccent)
                        Text(show.ratingText)
                        Text(String(show.year))
                        if let rt = show.runtime, !rt.isEmpty { Text(rt) }
                        Text(show.genre).padding(.horizontal, 8).padding(.vertical, 3)
                            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.vAccent.opacity(0.5), lineWidth: 1))
                    }
                    .font(.outfit(15)).foregroundColor(.vMuted)

                    if show.comingSoon == true {
                        Text("Premieres \(show.releaseDate ?? "soon")")
                            .font(.outfit(17, .semibold)).foregroundColor(.vAccent)
                    } else {
                        HStack(spacing: 12) {
                            Button { play(show.firstVideoURL) } label: {
                                Label("Play", systemImage: "play.fill")
                                    .font(.outfit(17, .semibold)).foregroundColor(.black)
                                    .padding(.horizontal, 28).padding(.vertical, 14)
                                    .background(Color(hex: 0xF2F4F8))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            Button { myList.toggle(show.id, title: show.title) } label: {
                                Image(systemName: myList.contains(show.id) ? "checkmark" : "plus")
                                    .font(.outfit(20, .semibold))
                                    .foregroundColor(.white).frame(width: 52, height: 52)
                                    .overlay(Circle().stroke(Color.vMuted, lineWidth: 2))
                            }
                        }
                    }

                    Text(show.desc).font(.outfit(16)).foregroundColor(.vMuted)
                    if let c = show.creator, !c.isEmpty {
                        Text("Creator: \(c)").font(.outfit(14)).foregroundColor(.vMuted)
                    }

                    if show.isMovie != true && show.comingSoon != true {
                        Text("EPISODES").font(.outfit(20, .bold)).foregroundColor(.white)
                            .padding(.top, 8)
                        ForEach(show.playableEpisodes) { ep in
                            Button { play(ep.video.flatMap { URL(string: $0) }) } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "play.circle.fill")
                                        .font(.outfit(28)).foregroundColor(.vAccent)
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("\(ep.num). \(ep.title)")
                                            .font(.outfit(16, .semibold)).foregroundColor(.white)
                                        if let d = ep.duration, !d.isEmpty {
                                            Text(d).font(.outfit(13)).foregroundColor(.vMuted)
                                        }
                                    }
                                    Spacer()
                                }
                                .padding(14)
                                .background(Color.vCard)
                                .clipShape(RoundedRectangle(cornerRadius: 14))
                                .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.vBorder, lineWidth: 1))
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 30)
            }
        }
        .background(Color.vBackground.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.vBackground, for: .navigationBar)
        .fullScreenCover(item: $playing) { item in PlayerScreen(url: item.url) }
    }
}
