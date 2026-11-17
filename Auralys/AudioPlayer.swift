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
    @Published var searchError: String?

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
        searchError = nil
        tracks = []
        currentIndex = 0

        do {
            tracks = try await service.searchTracks(query: query)
        } catch {
            searchError = error.localizedDescription
            print("Search error: \(error)")
        }
    }

    func play(_ track: MusicTrack) {
        guard let url = track.audio else { return }

        if let index = tracks.firstIndex(of: track) {
            currentIndex = index
        }

        currentTrack = track
        player = AVPlayer(url: url)
        player?.play()

        isPlaying = true
        updateNowPlaying()
    }

    func togglePlayback() {
        if isPlaying {
            pause()
        } else {
            resume()
        }
    }

    func pause() {
        player?.pause()
        isPlaying = false
        updateNowPlaying()
    }

    func resume() {
        guard player != nil else { return }

        player?.play()
        isPlaying = true
        updateNowPlaying()
    }

    func playNext() {
        guard !tracks.isEmpty else { return }

        currentIndex = (currentIndex + 1) % tracks.count
        play(tracks[currentIndex])
    }

    func playPrevious() {
        guard !tracks.isEmpty else { return }

        currentIndex = currentIndex > 0
            ? currentIndex - 1
            : tracks.count - 1

        play(tracks[currentIndex])
    }

    private func updateNowPlaying() {
        guard let track = currentTrack else { return }

        var info: [String: Any] = [
            MPMediaItemPropertyTitle: track.title,
            MPMediaItemPropertyArtist: track.artist,
            MPNowPlayingInfoPropertyIsLiveStream: false,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0
        ]

        if let duration = track.duration {
            info[MPMediaItemPropertyPlaybackDuration] = Double(duration)
        }

        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    private func configureRemoteCommands() {
        let center = MPRemoteCommandCenter.shared()

        center.playCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                self?.resume()
            }
            return .success
        }

        center.pauseCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                self?.pause()
            }
            return .success
        }

        center.nextTrackCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                self?.playNext()
            }
            return .success
        }

        center.previousTrackCommand.addTarget { [weak self] _ in
            Task { @MainActor in
                self?.playPrevious()
            }
            return .success
        }
    }
}
