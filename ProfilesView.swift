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
                    .font(.system(size: size * 0.45, weight: .heavy)).foregroundColor(.white)
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

struct ProfilesView: View {
    @EnvironmentObject var auth: AuthStore
    @State private var adding = false
    private let cols = [GridItem(.adaptive(minimum: 100), spacing: 20)]

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(hex: 0x0C1730), Color(hex: 0x050A14)],
                           startPoint: .top, endPoint: .bottom).ignoresSafeArea()
            ScrollView {
                VStack(spacing: 22) {
                    Text("VOLTAGE").font(.vTitle(64)).tracking(14).foregroundColor(.white).padding(.top, 60)
                    Text("WELCOME TO THE KINGDOM").font(.vTitle(20)).tracking(8).foregroundColor(.white)
                    Text("WHO'S WATCHING?").font(.system(size: 14, weight: .semibold)).tracking(6)
                        .foregroundColor(.vMuted).padding(.top, 20)

                    LazyVGrid(columns: cols, spacing: 26) {
                        ForEach(auth.profiles) { p in
                            Button { auth.selectProfile(p.id) } label: {
                                VStack(spacing: 8) {
                                    AvatarView(profile: p)
                                        .overlay(RoundedRectangle(cornerRadius: 18)
                                            .stroke(p.id == auth.activeProfileId ? Color.vAccent : Color.clear, lineWidth: 3))
                                    Text(p.name).font(.system(size: 16, weight: .medium)).foregroundColor(.vMuted)
                                    if p.id == auth.activeProfileId {
                                        Text("● Active").font(.system(size: 13)).foregroundColor(.vAccent)
                                    }
                                    if p.isKids {
                                        Text("KIDS").font(.system(size: 10, weight: .bold)).foregroundColor(.black)
                                            .padding(.horizontal, 6).padding(.vertical, 2)
                                            .background(Color.vAccent).clipShape(Capsule())
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                            .contextMenu {
                                if p.id != "guest" {
                                    Button(role: .destructive) { auth.removeProfile(p) } label: {
                                        Label("Remove profile", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        if auth.profiles.count < 6 {
                            Button { adding = true } label: {
                                VStack(spacing: 8) {
                                    RoundedRectangle(cornerRadius: 18)
                                        .strokeBorder(style: StrokeStyle(lineWidth: 2, dash: [6]))
                                        .foregroundColor(Color.vBorder)
                                        .frame(width: 96, height: 96)
                                        .overlay(Image(systemName: "plus").font(.system(size: 26)).foregroundColor(.vMuted))
                                    Text("Add Profile").font(.system(size: 16, weight: .medium)).foregroundColor(.vMuted)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 24)
                    Text("Press and hold a profile to remove it").font(.system(size: 12)).foregroundColor(.vMuted)
                        .padding(.top, 8)
                }
                .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $adding) { AddProfileSheet().environmentObject(auth) }
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
        Text(s).font(.system(size: 13, weight: .bold)).tracking(5).foregroundColor(.vMuted)
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
                                Text("COLOR").font(.system(size: 12, weight: .bold)).foregroundColor(.white)
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
                        Text("Create Profile").font(.system(size: 17, weight: .semibold)).foregroundColor(.white)
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
