import SwiftUI

struct AvatarView: View {
    let profile: Profile
    var size: CGFloat = 96

    var body: some View {
        ZStack {
            Rectangle().fill(profile.gradient)
            if let url = profile.imageURL {
                AsyncImage(url: url) { phase in
                    if let img = phase.image { img.resizable().scaledToFill() } else { Color.clear }
                }
            } else {
                Text(String(profile.name.prefix(1)).uppercased())
                    .font(.outfit(size * 0.45, .heavy)).foregroundColor(.white)
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

struct ProfilesView: View {
    @EnvironmentObject var auth: AuthStore
    @State private var adding = false

    private enum Cell: Identifiable {
        case profile(Profile)
        case add
        var id: String {
            switch self {
            case .profile(let p): return p.id
            case .add: return "add"
            }
        }
    }

    private var cells: [Cell] {
        auth.profiles.map { Cell.profile($0) } + (auth.profiles.count < 6 ? [Cell.add] : [])
    }

    private var rows: [[Cell]] {
        stride(from: 0, to: cells.count, by: 3).map { Array(cells[$0..<min($0 + 3, cells.count)]) }
    }

    var body: some View {
        ZStack {
            VoltageBackdrop()
            VStack(spacing: 20) {
                Text("VOLTAGE").font(.vTitle(70)).tracking(16).foregroundColor(.white)
                    .lineLimit(1).minimumScaleFactor(0.5).padding(.horizontal, 20)
                Text("WELCOME TO THE KINGDOM").font(.vTitle(21)).tracking(9).foregroundColor(.white)
                    .lineLimit(1).minimumScaleFactor(0.5).padding(.horizontal, 20)
                Text("WHO'S WATCHING?").font(.outfit(14, .semibold)).tracking(7)
                    .foregroundColor(Color(hex: 0x9AA3B5)).padding(.top, 24).padding(.bottom, 6)
                ForEach(rows.indices, id: \.self) { i in
                    HStack(alignment: .top, spacing: 22) {
                        ForEach(rows[i]) { cell in cellView(cell) }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom, 70)
        }
        .sheet(isPresented: $adding) { AddProfileSheet().environmentObject(auth) }
    }

    @ViewBuilder
    private func cellView(_ cell: Cell) -> some View {
        switch cell {
        case .profile(let p): profileTile(p)
        case .add: addTile
        }
    }

    private func profileTile(_ p: Profile) -> some View {
        let active = p.id == auth.activeProfileId
        return VStack(spacing: 8) {
            Button { auth.selectProfile(p.id) } label: {
                AvatarView(profile: p, size: 96)
                    .overlay(RoundedRectangle(cornerRadius: 18)
                        .stroke(active ? Color(hex: 0x4FB3E0) : Color.clear, lineWidth: 3))
            }
            .buttonStyle(.plain)
            Text(p.name).font(.outfit(16, .medium)).foregroundColor(Color(hex: 0x9AA3B5))
            if active {
                Text("● Active").font(.outfit(13)).foregroundColor(Color(hex: 0x4FB3E0))
            }
            if p.isKids {
                Text("KIDS").font(.outfit(10, .bold)).foregroundColor(.black)
                    .padding(.horizontal, 6).padding(.vertical, 2)
                    .background(Color.vAccent).clipShape(Capsule())
            }
            if active && p.id != "guest" {
                Button { auth.removeProfile(p) } label: {
                    Text("remove").font(.outfit(13)).underline().foregroundColor(Color(hex: 0x4A5F8A))
                }
            }
        }
        .frame(width: 100)
    }

    private var addTile: some View {
        Button { adding = true } label: {
            VStack(spacing: 8) {
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [6]))
                    .foregroundColor(Color(hex: 0x2A3556))
                    .background(Color.white.opacity(0.03))
                    .frame(width: 96, height: 96)
                    .overlay(Image(systemName: "plus").font(.outfit(26)).foregroundColor(Color(hex: 0x3A4A75)))
                Text("Add Profile").font(.outfit(16, .medium)).foregroundColor(Color(hex: 0x9AA3B5))
            }
            .frame(width: 100)
        }
        .buttonStyle(.plain)
    }
}

struct AddProfileSheet: View {
    @EnvironmentObject var auth: AuthStore
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var image: String? = nil
    @State private var color = "linear-gradient(135deg,#1a6cf5,#00d4ff)"
    @State private var kids = false

    private let images = ["photos/guest.png", "photos/mts.png", "photos/parkernight.png", "photos/tv.png", "photos/two.png"]
    private let colors = [
        "linear-gradient(135deg,#1a6cf5,#00d4ff)", "linear-gradient(135deg,#9b30c0,#d860ff)",
        "linear-gradient(135deg,#c0392b,#ff6b6b)", "linear-gradient(135deg,#f0b429,#ff8c00)",
        "linear-gradient(135deg,#1a5c00,#3aab00)", "linear-gradient(135deg,#006080,#00c4d4)",
    ]

    private func label(_ s: String) -> some View {
        Text(s).font(.outfit(13, .bold)).tracking(5).foregroundColor(.vMuted)
    }

    var body: some View {
        ZStack {
            Color(hex: 0x0B0D14).ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HStack {
                        Text("ADD PROFILE").font(.vTitle(40)).tracking(3).foregroundColor(Color(hex: 0xC9DCEE))
                        Spacer()
                        Button { dismiss() } label: {
                            Image(systemName: "xmark").foregroundColor(.vAccent)
                                .frame(width: 42, height: 42).background(Color.vCard).clipShape(Circle())
                        }
                    }
                    Text("Choose a name and picture.").foregroundColor(Color(hex: 0x1F3A63))
                    label("PROFILE NAME")
                    TextField("e.g. Kelis", text: $name)
                        .foregroundColor(.white).padding(16)
                        .background(Color(hex: 0x16171F)).clipShape(RoundedRectangle(cornerRadius: 14))
                    label("PROFILE PICTURE")
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 64), spacing: 12)], spacing: 12) {
                        Button { image = nil } label: {
                            ZStack {
                                LinearGradient(colors: [Color(hex: 0x1A6CF5), Color(hex: 0x00D4FF)], startPoint: .topLeading, endPoint: .bottomTrailing)
                                Text("COLOR").font(.outfit(12, .bold)).foregroundColor(.white)
                            }
                            .frame(width: 64, height: 64).clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(RoundedRectangle(cornerRadius: 12).stroke(image == nil ? Color.vAccent : Color.clear, lineWidth: 3))
                        }
                        ForEach(images, id: \.self) { path in
                            Button { image = path } label: {
                                AsyncImage(url: URL(string: "https://watchvoltage.com/" + path)) { phase in
                                    if let img = phase.image { img.resizable().scaledToFill() } else { Color.vCard }
                                }
                                .frame(width: 64, height: 64).clipShape(RoundedRectangle(cornerRadius: 12))
                                .overlay(RoundedRectangle(cornerRadius: 12).stroke(image == path ? Color.vAccent : Color.clear, lineWidth: 3))
                            }
                        }
                    }
                    label("AVATAR COLOR")
                    HStack(spacing: 12) {
                        ForEach(colors, id: \.self) { c in
                            let p = Profile(id: "x", name: "", color: c, image: nil, isKids: false)
                            Button { color = c } label: {
                                Circle().fill(p.gradient).frame(width: 38, height: 38)
                                    .overlay(Circle().stroke(color == c ? Color.white : Color.clear, lineWidth: 3))
                            }
                        }
                    }
                    Toggle(isOn: $kids) {
                        Text("Kids profile (restricts horror content)").foregroundColor(Color(hex: 0x3B6FA8))
                    }
                    .tint(.vAccent)
                    Button {
                        let n = name.trimmingCharacters(in: .whitespaces)
                        guard !n.isEmpty else { return }
                        auth.addProfile(name: n, color: color, image: image, isKids: kids)
                        dismiss()
                    } label: {
                        Text("Create Profile").font(.outfit(17, .semibold)).foregroundColor(.white)
                            .frame(maxWidth: .infinity, minHeight: 56)
                            .background(Color(hex: 0x0F2A57)).clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.top, 8)
                }
                .padding(24)
            }
        }
    }
}
