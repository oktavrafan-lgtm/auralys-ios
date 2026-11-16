
import Foundation
import AVFoundation
import MediaPlayer
import Combine

@MainActor
final class AudioPlayer: ObservableObject {
    @Published var currentTrack: MusicTrack?
    @Published var isPlaying = false
    @Published var tracks: [MusicTrack] = []
    @Published var currentIndex = 0

    private var player: AVPlayer?
    private let service = JamendoService()

    init() {
        configureAudioSession()
        configureRemoteCommands()
    }

    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session error: \(error)")
        }
    }

    func search(_ query: String) async {
        do {
            tracks = try await service.searchTracks(query: query)
        } catch {
            print("Search error: \(error)")
        }
    }

    func play(_ track: MusicTrack) {
        guard let url = track.audio else { return }

        currentTrack = track
        player = AVPlayer(url: url)
        player?.play()
        isPlaying = true
        updateNowPlaying()
    }

    func togglePlayback() {
        if isPlaying {
            player?.pause()
            isPlaying = false
        } else {
            player?.play()
            isPlaying = true
        }
        updateNowPlaying()
    }

    func playNext() {
        guard !tracks.isEmpty else { return }

        currentIndex = (currentIndex + 1) % tracks.count
        play(tracks[currentIndex])
    }

    private func updateNowPlaying() {
        guard let track = currentTrack else { return }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = [
            MPMediaItemPropertyTitle: track.title,
            MPMediaItemPropertyArtist: track.artist,
            MPNowPlayingInfoPropertyIsLiveStream: false
        ]
    }

    private func configureRemoteCommands() {
        let center = MPRemoteCommandCenter.shared()

        center.playCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.togglePlayback() }
            return .success
        }

        center.pauseCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.togglePlayback() }
            return .success
        }

        center.nextTrackCommand.addTarget { [weak self] _ in
            Task { @MainActor in self?.playNext() }
            return .success
        }
    }
}
