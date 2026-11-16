
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var player: AudioPlayer
    @State private var searchText = ""

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

                        if player.tracks.isEmpty {
                            Text("Cari musik favoritmu")
                                .foregroundColor(.gray)
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

            TextField("Cari judul atau artis...", text: $searchText)
                .foregroundColor(.white)
                .submitLabel(.search)
                .onSubmit {
                    Task {
                        await player.search(searchText)
                    }
                }

            Button {
                Task {
                    await player.search(searchText)
                }
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

    private func trackRow(_ track: MusicTrack) -> some View {
        Button {
            player.play(track)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "music.note")
                    .font(.title2)
                    .foregroundColor(.cyan)
                    .frame(width: 48, height: 48)
                    .background(Color.white.opacity(0.08))
                    .cornerRadius(10)

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

                Image(systemName: "play.circle.fill")
                    .foregroundColor(.cyan)
                    .font(.title2)
            }
        }
    }

    private func miniPlayer(_ track: MusicTrack) -> some View {
        HStack {
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
                player.togglePlayback()
            } label: {
                Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                    .foregroundColor(.white)
                    .font(.title2)
            }

            Button {
                player.playNext()
            } label: {
                Image(systemName: "forward.end.fill")
                    .foregroundColor(.white)
                    .font(.title2)
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
}
