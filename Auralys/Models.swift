
import Foundation

struct MusicTrack: Identifiable, Decodable, Hashable {
    let id: String
    let name: String
    let artist_name: String
    let image: URL?
    let audio: URL?
    let duration: Int?

    var title: String { name }
    var artist: String { artist_name }
}

struct TrackResponse: Decodable {
    let results: [MusicTrack]
}
