import SwiftUI

struct ShowGrid: View {
    let shows: [Show]
    private let cols = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        LazyVGrid(columns: cols, spacing: 12) {
            ForEach(shows) { s in
                NavigationLink { DetailView(show: s) } label: { ShowCard(show: s) }
                    .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
    }
}

struct ExploreView: View {
    @EnvironmentObject var store: ShowStore
    @State private var query = ""
    @State private var chip = "All"
    private let chips = ["All", "Nova", "Spark", "NoSleep", "Kingdom", "New"]

    private var results: [Show] {
        let q = query.trimmingCharacters(in: .whitespaces).lowercased()
        return store.shows.filter { s in
            let okQuery = q.isEmpty || s.title.lowercased().contains(q) || s.genre.lowercased().contains(q)
            let okChip: Bool
            switch chip {
            case "Nova": okChip = s.channel == "nova"
            case "Spark": okChip = s.channel == "spark"
            case "NoSleep": okChip = s.channel == "night" || s.channel == "nosleep"
            case "Kingdom": okChip = s.channel == "kingdom"
            case "New": okChip = s.year >= 2025
            default: okChip = true
            }
            return okQuery && okChip
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass").foregroundColor(.vMuted)
                        TextField("Search titles, genres…", text: $query)
                            .foregroundColor(.white)
                            .autocorrectionDisabled()
                    }
                    .padding(14)
                    .background(Color.vCard)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(Color.vBorder, lineWidth: 1))
                    .padding(.horizontal, 16)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(chips, id: \.self) { c in
                                Button { chip = c } label: {
                                    Text(c)
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(chip == c ? .white : .vMuted)
                                        .padding(.horizontal, 16).padding(.vertical, 8)
                                        .background(chip == c ? Color(hex: 0x0E3A78) : Color.clear)
                                        .clipShape(Capsule())
                                        .overlay(Capsule().stroke(Color.vBorder, lineWidth: 1))
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                    }

                    if results.isEmpty {
                        Text("No titles found").foregroundColor(.vMuted)
                            .frame(maxWidth: .infinity).padding(.top, 40)
                    } else {
                        ShowGrid(shows: results)
                    }
                }
                .padding(.top, 16).padding(.bottom, 24)
            }
            .background(Color.vBackground.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

struct MyListView: View {
    @EnvironmentObject var store: ShowStore
    @EnvironmentObject var myList: MyListStore

    private var saved: [Show] {
        myList.ids.compactMap { id in store.shows.first { $0.id == id } }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                if saved.isEmpty {
                    VStack(spacing: 14) {
                        Image(systemName: "heart").font(.system(size: 54)).foregroundColor(.vAccent)
                        Text("Your list is empty").font(.system(size: 20, weight: .semibold)).foregroundColor(.vMuted)
                        Text("Save shows by tapping + on any title").foregroundColor(.vMuted)
                    }
                    .frame(maxWidth: .infinity).padding(.top, 140)
                } else {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("MY LIST").font(.vTitle(36)).tracking(3).foregroundColor(.white)
                            .padding(.horizontal, 16)
                        ShowGrid(shows: saved)
                    }
                    .padding(.top, 16).padding(.bottom, 24)
                }
            }
            .background(Color.vBackground.ignoresSafeArea())
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}
