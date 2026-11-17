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
        case image
        case album_image
        case audio
        case duration
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        artist_name = try container.decode(String.self, forKey: .artist_name)

        // Singles can return an empty album_image; fall back to the track image.
        let albumImage = Self.decodeURL(from: container, forKey: .album_image)
        image = albumImage ?? Self.decodeURL(from: container, forKey: .image)
        audio = Self.decodeURL(from: container, forKey: .audio)
        duration = try container.decodeIfPresent(Int.self, forKey: .duration)
    }

    private static func decodeURL(
        from container: KeyedDecodingContainer<CodingKeys>,
        forKey key: CodingKeys
    ) -> URL? {
        guard let value = try? container.decode(String.self, forKey: key),
              !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }
        return URL(string: value)
    }
}

struct TrackResponse: Decodable {
    let headers: JamendoResponseHeaders?
    let results: [MusicTrack]
}

struct JamendoResponseHeaders: Decodable {
    let code: Int
    let errorMessage: String

    enum CodingKeys: String, CodingKey {
        case code
        case errorMessage = "error_message"
    }
}
