
import Foundation

final class JamendoService {
    func searchTracks(query: String) async throws -> [MusicTrack] {
        guard JamendoConfig.isConfigured else {
            throw JamendoError.missingClientID
        }

        var components = URLComponents(
            string: "\(JamendoConfig.baseURL)/tracks/"
        )!

        components.queryItems = [
            URLQueryItem(name: "client_id", value: JamendoConfig.clientID),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "namesearch", value: query),
            URLQueryItem(name: "limit", value: "30"),
            URLQueryItem(name: "audioformat", value: "mp32")
        ]

        guard let url = components.url else {
            throw JamendoError.invalidURL
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(
            TrackResponse.self,
            from: data
        )

        return response.results.filter { $0.audio != nil }
    }
}

enum JamendoError: Error {
    case missingClientID
    case invalidURL
}
