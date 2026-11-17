
import Foundation

struct MusicTrack: Identifiable, Decodable, Hashable {
    let id: String
    let name: String
    let artist_name: String
    let image: URL?
    let audio: URL?
    let duration: Int?

    var title: String {
        name
    }

    var artist: String {
        artist_name
    }

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case artist_name
        case image
        case album_image
        case audio
        case duration
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(
            keyedBy: CodingKeys.self
        )

        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        artist_name = try container.decode(
            String.self,
            forKey: .artist_name
        )

        image = try container.decodeIfPresent(
            URL.self,
            forKey: .album_image
        ) ?? container.decodeIfPresent(
            URL.self,
            forKey: .image
        )

        audio = try container.decodeIfPresent(
            URL.self,
            forKey: .audio
        )

        duration = try container.decodeIfPresent(
            Int.self,
            forKey: .duration
        )
    }
}

struct TrackResponse: Decodable {
    let results: [MusicTrack]
}
