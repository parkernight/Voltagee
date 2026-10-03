import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var auth: AuthStore
    @State private var confirmDelete = false
    @State private var note: String?

    private func card<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.outfit(13, .bold)).tracking(4).foregroundColor(.vMuted)
            VStack(alignment: .leading, spacing: 14) { content() }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.vCard)
                .clipShape(RoundedRectangle(cornerRadius: 18))
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(Color.vBorder, lineWidth: 1))
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("SETTINGS").font(.vTitle(40)).tracking(3).foregroundColor(.white)
                Text("Manage your account and preferences").foregroundColor(Color(hex: 0x1F3A63))

                card("ACCOUNT") {
                    if let n = auth.user?.displayName, !n.isEmpty {
                        Text(n).font(.outfit(17, .semibold)).foregroundColor(.white)
                    }
                    Text(auth.user?.email ?? "").foregroundColor(.vMuted)
                }
                card("PROFILES") {
                    Button { auth.profileChosen = false } label: {
                        Label("Switch or manage profiles", systemImage: "person.2").foregroundColor(.vAccent)
                    }
                }
                card("LINKS") {
                    Link("Open watchvoltage.com", destination: URL(string: "https://watchvoltage.com")!)
                        .foregroundColor(.vAccent)
                    Link("Contact us", destination: URL(string: "mailto:Voltage@WatchVoltage.com")!)
                        .foregroundColor(.vAccent)
                }
                card("ACCOUNT ACTIONS") {
                    Button { auth.signOut() } label: {
                        Text("Sign Out").font(.outfit(16, .semibold)).foregroundColor(Color(hex: 0xFF4D6D))
                    }
                    Button { confirmDelete = true } label: {
                        Text("Delete Account").font(.outfit(16)).foregroundColor(.vMuted)
                    }
                    if let note = note { Text(note).font(.outfit(13)).foregroundColor(Color(hex: 0xFF6B6B)) }
                }
                Text("© 2025 VOLTAGE Streaming · Made by Parker Night")
                    .font(.outfit(12)).foregroundColor(.vMuted)
            }
            .padding(16)
        }
        .background(Color.vBackground.ignoresSafeArea())
        .confirmationDialog("Delete your account and all saved profiles? This can't be undone.",
                            isPresented: $confirmDelete, titleVisibility: .visible) {
            Button("Delete Account", role: .destructive) {
                Task { note = await auth.deleteAccount() }
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}
