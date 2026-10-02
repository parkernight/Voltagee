import SwiftUI

struct SettingsView: View {
    private func card<Content: View>(_ title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title).font(.system(size: 13, weight: .bold)).tracking(4).foregroundColor(.vMuted)
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
                card("ABOUT") {
                    Text("Voltage").font(.system(size: 18, weight: .semibold)).foregroundColor(.white)
                    Text("Welcome to the Kingdom").foregroundColor(.vMuted)
                }
                card("LINKS") {
                    Link("Open watchvoltage.com", destination: URL(string: "https://watchvoltage.com")!)
                        .foregroundColor(.vAccent)
                    Link("Contact us", destination: URL(string: "mailto:Voltage@WatchVoltage.com")!)
                        .foregroundColor(.vAccent)
                }
                Text("© 2025 VOLTAGE Streaming · Made by Parker Night")
                    .font(.system(size: 12)).foregroundColor(.vMuted)
            }
            .padding(16)
        }
        .background(Color.vBackground.ignoresSafeArea())
    }
}
