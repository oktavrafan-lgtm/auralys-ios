
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

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case artist_name
        case image = "album_image"
        case audio
        case duration
    }
}

struct TrackResponse: Decodable {
    let results: [MusicTrack]
}
