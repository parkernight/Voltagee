import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

struct Profile: Identifiable, Equatable {
    var id: String
    var name: String
    var color: String
    var image: String?
    var isKids: Bool

    init(id: String, name: String, color: String, image: String?, isKids: Bool) {
        self.id = id
        self.name = name
        self.color = color
        self.image = image
        self.isKids = isKids
    }

    init?(dict: [String: Any]) {
        guard let id = dict["id"] as? String, let name = dict["name"] as? String else { return nil }
        self.id = id
        self.name = name
        self.color = dict["color"] as? String ?? ""
        self.image = dict["image"] as? String
        self.isKids = dict["isKids"] as? Bool ?? false
    }

    var dict: [String: Any] {
        var d: [String: Any] = ["id": id, "name": name, "color": color, "isKids": isKids]
        if let image = image { d["image"] = image } else { d["image"] = NSNull() }
        return d
    }

    var imageURL: URL? {
        guard let image = image, !image.isEmpty else { return nil }
        return URL(string: "https://watchvoltage.com/" + image)
    }

    var gradient: LinearGradient {
        let hexes: [UInt32] = color.components(separatedBy: "#").dropFirst().compactMap { part in
            let h = String(part.prefix(while: { $0.isHexDigit }))
            let full = h.count == 3 ? h.map { "\($0)\($0)" }.joined() : h
            return UInt32(full, radix: 16)
        }
        let c1 = Color(hex: hexes.first ?? 0x1A6CF5)
        let c2 = Color(hex: hexes.count > 1 ? hexes[1] : 0x00D4FF)
        return LinearGradient(colors: [c1, c2], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

@MainActor
final class AuthStore: ObservableObject {
    @Published var ready = false
    @Published var user: User?
    @Published var profiles: [Profile] = []
    @Published var activeProfileId: String?
    @Published var profileChosen = false
    @Published private(set) var ids: [Int] = []

    private var profileData: [String: Any] = [:]
    private var handle: AuthStateDidChangeListenerHandle?
    private let configured: Bool

    init() {
        configured = FirebaseApp.app() != nil
        guard configured else {
            ready = true
            return
        }
        handle = Auth.auth().addStateDidChangeListener { [weak self] _, u in
            Task { @MainActor in await self?.handleUser(u) }
        }
    }

    var isKids: Bool { profiles.first { $0.id == activeProfileId }?.isKids ?? false }

    func allows(_ s: Show) -> Bool {
        !(isKids && (s.channel == "night" || s.channel == "nosleep"))
    }

    private var userDoc: DocumentReference? {
        guard configured, let u = user else { return nil }
        return Firestore.firestore().collection("users").document(u.uid)
    }

    private func handleUser(_ u: User?) async {
        user = u
        if let u = u {
            await loadCloud(u)
        } else {
            profiles = []
            activeProfileId = nil
            profileChosen = false
            ids = []
            profileData = [:]
        }
        ready = true
    }

    private func loadCloud(_ u: User) async {
        do {
            let snap = try await Firestore.firestore().collection("users").document(u.uid).getDocument()
            let d = snap.data() ?? [:]
            let raw = d["profiles"] as? [[String: Any]] ?? []
            var list = raw.compactMap { Profile(dict: $0) }
            if list.isEmpty {
                list = [Profile(id: "guest", name: "Guest", color: "linear-gradient(135deg,#333,#555)", image: "photos/guest.png", isKids: false)]
            }
            profiles = list
            profileData = d["profileData"] as? [String: Any] ?? [:]
            let active = d["activeProfileId"] as? String
            activeProfileId = list.contains(where: { $0.id == active }) ? active : list.first?.id
            refreshIds()
        } catch {
            profiles = [Profile(id: "guest", name: "Guest", color: "linear-gradient(135deg,#333,#555)", image: "photos/guest.png", isKids: false)]
            activeProfileId = "guest"
        }
    }

    private func refreshIds() {
        guard let pid = activeProfileId,
              let pd = profileData[pid] as? [String: Any],
              let ml = pd["myList"] as? [[String: Any]] else {
            ids = []
            return
        }
        ids = ml.compactMap { ($0["showId"] as? NSNumber)?.intValue }.reversed()
    }

    // MARK: My List (synced per profile, same format as the website)

    func contains(_ id: Int) -> Bool { ids.contains(id) }

    func toggle(_ showId: Int, title: String = "") {
        guard let pid = activeProfileId, let doc = userDoc else { return }
        var pd = profileData[pid] as? [String: Any] ?? [:]
        var ml = pd["myList"] as? [[String: Any]] ?? []
        if let i = ml.firstIndex(where: { ($0["showId"] as? NSNumber)?.intValue == showId }) {
            ml.remove(at: i)
        } else {
            ml.append(["showId": showId, "showTitle": title, "addedAt": Int(Date().timeIntervalSince1970 * 1000)])
        }
        pd["myList"] = ml
        profileData[pid] = pd
        refreshIds()
        doc.setData(["profileData": [pid: ["myList": ml]]], merge: true)
    }

    // MARK: Profiles

    func selectProfile(_ id: String) {
        activeProfileId = id
        profileChosen = true
        refreshIds()
        saveProfiles()
    }

    func addProfile(name: String, color: String, image: String?, isKids: Bool) {
        guard profiles.count < 6 else { return }
        let p = Profile(id: "p_\(Int(Date().timeIntervalSince1970 * 1000))", name: name, color: color, image: image, isKids: isKids)
        profiles.append(p)
        saveProfiles()
    }

    func removeProfile(_ p: Profile) {
        guard p.id != "guest" else { return }
        profiles.removeAll { $0.id == p.id }
        if activeProfileId == p.id { activeProfileId = profiles.first?.id }
        refreshIds()
        saveProfiles()
    }

    private func saveProfiles() {
        guard let doc = userDoc else { return }
        var data: [String: Any] = ["profiles": profiles.map { $0.dict }]
        if let a = activeProfileId { data["activeProfileId"] = a }
        if let e = user?.email { data["email"] = e }
        doc.setData(data, merge: true)
    }

    // MARK: Account

    func signIn(email: String, password: String) async -> String? {
        guard configured else { return "The app isn't connected to Firebase yet." }
        do {
            _ = try await Auth.auth().signIn(withEmail: email, password: password)
            return nil
        } catch {
            return error.localizedDescription
        }
    }

    func signUp(name: String, email: String, password: String) async -> String? {
        guard configured else { return "The app isn't connected to Firebase yet." }
        do {
            let r = try await Auth.auth().createUser(withEmail: email, password: password)
            let change = r.user.createProfileChangeRequest()
            change.displayName = name
            try await change.commitChanges()
            try await Firestore.firestore().collection("users").document(r.user.uid)
                .setData(["email": email, "name": name], merge: true)
            return nil
        } catch {
            return error.localizedDescription
        }
    }

    func resetPassword(email: String) async -> String? {
        guard configured else { return "The app isn't connected to Firebase yet." }
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            return nil
        } catch {
            return error.localizedDescription
        }
    }

    func signOut() {
        try? Auth.auth().signOut()
    }

    func deleteAccount() async -> String? {
        guard let u = user, let doc = userDoc else { return nil }
        do {
            try await doc.delete()
            try await u.delete()
            return nil
        } catch {
            return error.localizedDescription + " If this says you need to sign in again, sign out, sign back in, and retry."
        }
    }
}
