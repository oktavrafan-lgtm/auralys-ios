import SwiftUI

struct ContentView: View {
    @EnvironmentObject var player: AudioPlayer

    @State private var searchText = ""
    @State private var isSearching = false
    @State private var hasSearched = false

    var body: some View {
        ZStack {
            Color(red: 0.035, green: 0.04, blue: 0.07)
                .ignoresSafeArea()

            VStack(spacing: 22) {
                header
                searchBar

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Discover")
                            .font(.title2.bold())
                            .foregroundColor(.white)

                        if isSearching {
                            ProgressView("Mencari musik...")
                                .tint(.cyan)
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity)
                                .padding(.top, 35)

                        } else if let error = player.searchError {
                            VStack(spacing: 10) {
                                Image(systemName: "wifi.exclamationmark")
                                    .font(.title)
                                    .foregroundColor(.orange)

                                Text("Pencarian gagal")
                                    .font(.headline)
                                    .foregroundColor(.white)

                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)

                                Button("Coba lagi") {
                                    performSearch()
                                }
                                .foregroundColor(.cyan)
                                .padding(.top, 4)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 35)

                        } else if player.tracks.isEmpty {
                            Text(
                                hasSearched
                                ? "Lagu tidak ditemukan. Coba judul lagu atau nama artis lain."
                                : "Cari musik favoritmu"
                            )
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 35)

                        } else {
                            ForEach(player.tracks) { track in
                                trackRow(track)
                            }
                        }
                    }
                }

                if let track = player.currentTrack {
                    miniPlayer(track)
                }
            }
            .padding()
        }
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text("AURALYS")
                    .font(.system(size: 27, weight: .bold))
                    .foregroundColor(.white)

                Text("Your music, your atmosphere.")
                    .font(.caption)
                    .foregroundColor(.gray)
            }

            Spacer()

            Image(systemName: "waveform")
                .font(.title)
                .foregroundColor(.cyan)
        }
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)

            TextField(
                "Cari judul atau artis...",
                text: $searchText
            )
            .foregroundColor(.white)
            .submitLabel(.search)
            .onSubmit {
                performSearch()
            }

            Button {
                performSearch()
            } label: {
                Image(systemName: "arrow.right.circle.fill")
                    .foregroundColor(.cyan)
                    .font(.title2)
            }
        }
        .padding()
        .background(Color.white.opacity(0.08))
        .cornerRadius(14)
    }

    private func performSearch() {
        let query = searchText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !query.isEmpty else { return }

        isSearching = true
        hasSearched = true

        Task {
            await player.search(query)
            isSearching = false
        }
    }

    private func trackRow(_ track: MusicTrack) -> some View {
        Button {
            player.play(track)
        } label: {
            HStack(spacing: 12) {
                Group {
                    if let imageURL = track.image {
                        AsyncImage(url: imageURL) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            coverPlaceholder
                        }
                    } else {
                        coverPlaceholder
                    }
                }
                .frame(width: 52, height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 10))

                VStack(alignment: .leading, spacing: 5) {
                    Text(track.title)
                        .foregroundColor(.white)
                        .lineLimit(1)

                    Text(track.artist)
                        .foregroundColor(.gray)
                        .font(.caption)
                        .lineLimit(1)
                }

                Spacer()

                Image(
                    systemName: player.currentTrack?.id == track.id
                    ? (player.isPlaying ? "waveform" : "pause.circle.fill")
                    : "play.circle.fill"
                )
                .foregroundColor(.cyan)
                .font(.title2)
            }
        }
        .buttonStyle(.plain)
    }

    private var coverPlaceholder: some View {
        ZStack {
            Color.white.opacity(0.08)

            Image(systemName: "music.note")
                .font(.title2)
                .foregroundColor(.cyan)
        }
    }

    private func miniPlayer(_ track: MusicTrack) -> some View {
        HStack(spacing: 12) {
            if let imageURL = track.image {
                AsyncImage(url: imageURL) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    coverPlaceholder
                }
                .frame(width: 45, height: 45)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                coverPlaceholder
                    .frame(width: 45, height: 45)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(track.title)
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text(track.artist)
                    .foregroundColor(.gray)
                    .font(.caption)
                    .lineLimit(1)
            }

            Spacer()

            Button {
                player.playPrevious()
            } label: {
                Image(systemName: "backward.end.fill")
                    .foregroundColor(.white)
            }

            Button {
                player.togglePlayback()
            } label: {
                Image(
                    systemName: player.isPlaying
                    ? "pause.fill"
                    : "play.fill"
                )
                .foregroundColor(.cyan)
                .font(.title2)
            }

            Button {
                player.playNext()
            } label: {
                Image(systemName: "forward.end.fill")
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
}
