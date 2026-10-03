import SwiftUI

struct GalleryView: View {
    @State private var selected: GalleryItem?
    private let cols = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                Text("GALLERY OF THE KINGDOM")
                    .font(.outfit(18, .bold)).tracking(5).foregroundColor(.white)
                Rectangle().fill(Color(hex: 0x0E3A78)).frame(height: 2)
                LazyVGrid(columns: cols, spacing: 12) {
                    ForEach(galleryItems) { item in
                        Button { selected = item } label: { GalleryCard(item: item) }
                            .buttonStyle(.plain)
                    }
                }
            }
            .padding(16)
        }
        .background(Color.vBackground.ignoresSafeArea())
        .fullScreenCover(item: $selected) { item in
            ZStack(alignment: .topTrailing) {
                Color.black.ignoresSafeArea()
                AsyncImage(url: URL(string: item.url)) { phase in
                    if let img = phase.image { img.resizable().scaledToFit() } else { ProgressView() }
                }
                Button { selected = nil } label: {
                    Image(systemName: "xmark")
                        .font(.outfit(16, .bold)).foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(Color.white.opacity(0.18)).clipShape(Circle())
                }
                .padding(16)
            }
        }
    }
}

struct GalleryCard: View {
    let item: GalleryItem

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack {
                Color.vCard
                AsyncImage(url: URL(string: item.url)) { phase in
                    if let img = phase.image { img.resizable().scaledToFit() } else { Color.clear }
                }
            }
            .frame(height: 210)
            .clipped()
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name).font(.outfit(16, .bold).italic())
                    .foregroundColor(.white).lineLimit(1)
                Text("\(item.medium) · #\(item.id)").font(.outfit(12).italic())
                    .foregroundColor(.vMuted)
                Text("by \(item.artist)").font(.outfit(13)).foregroundColor(.vAccent)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: 0x080D18))
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.vBorder, lineWidth: 1))
    }
}
