import SwiftUI

struct Episode: Codable, Identifiable {
    var id: Int { num }
    let num: Int
    let title: String
    let desc: String?
    let duration: String?
    let video: String?
    let cover: String?
}

struct Season: Codable, Identifiable {
    var id: String { label }
    let label: String
    let episodes: [Episode]
}

struct Show: Codable, Identifiable {
    let id: Int
    let title: String
    let channel: String
    let genre: String
    let year: Int
    let rating: Double
    let image: String
    let desc: String
    let creator: String?
    let isMovie: Bool?
    let runtime: String?
    let comingSoon: Bool?
    let releaseDate: String?
    let seasons: [Season]?

    var imageURL: URL? { URL(string: image) }
    var playableEpisodes: [Episode] { (seasons ?? []).flatMap { $0.episodes } }
    var firstVideoURL: URL? { playableEpisodes.first.flatMap { $0.video }.flatMap { URL(string: $0) } }
    var kindLabel: String { (isMovie ?? false) ? "FILM" : "\(seasons?.count ?? 1)S" }
    var ratingText: String { rating == rating.rounded() ? String(Int(rating)) : String(rating) }
}

@MainActor
final class ShowStore: ObservableObject {
    @Published var shows: [Show] = []
    @Published var loadFailed = false

    func load() async {
        guard let url = URL(string: "https://watchvoltage.com/shows.json") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            shows = try JSONDecoder().decode([Show].self, from: data)
            loadFailed = false
        } catch {
            loadFailed = shows.isEmpty
        }
    }
}

final class MyListStore: ObservableObject {
    @Published private(set) var ids: [Int]

    init() {
        ids = UserDefaults.standard.array(forKey: "voltage.myList") as? [Int] ?? []
    }

    func contains(_ id: Int) -> Bool { ids.contains(id) }

    func toggle(_ id: Int) {
        if let i = ids.firstIndex(of: id) { ids.remove(at: i) } else { ids.insert(id, at: 0) }
        UserDefaults.standard.set(ids, forKey: "voltage.myList")
    }
}

struct PlayItem: Identifiable {
    let id = UUID()
    let url: URL
}
