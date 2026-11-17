
import Foundation

final class JamendoService {

    func searchTracks(query: String) async throws -> [MusicTrack] {

        guard JamendoConfig.isConfigured else {
            throw JamendoError.missingClientID
        }

        let keyword = query.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !keyword.isEmpty else {
            return []
        }

        guard var components = URLComponents(
            string: "\(JamendoConfig.baseURL)/tracks/"
        ) else {
            throw JamendoError.invalidURL
        }

        components.queryItems = [
            URLQueryItem(
                name: "client_id",
                value: JamendoConfig.clientID
            ),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "search", value: keyword),
            URLQueryItem(name: "limit", value: "30"),
            URLQueryItem(name: "audioformat", value: "mp32"),
            URLQueryItem(name: "type", value: "single albumtrack")
        ]

        guard let url = components.url else {
            throw JamendoError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(
            from: url
        )

        guard let http = response as? HTTPURLResponse,
              (200...299).contains(http.statusCode) else {
            throw JamendoError.badResponse
        }

        let result = try JSONDecoder().decode(
            TrackResponse.self,
            from: data
        )

        return result.results.filter {
            $0.audio != nil
        }
    }
}

enum JamendoError: LocalizedError {
    case missingClientID
    case invalidURL
    case badResponse

    var errorDescription: String? {
        switch self {
        case .missingClientID:
            return "Client ID Jamendo belum diatur."
        case .invalidURL:
            return "URL Jamendo tidak valid."
        case .badResponse:
            return "Server Jamendo memberikan respons gagal."
        }
    }
}
