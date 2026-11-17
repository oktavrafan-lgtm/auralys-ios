import Foundation

final class JamendoService {

    func searchTracks(query: String) async throws -> [MusicTrack] {
        guard JamendoConfig.isConfigured else {
            throw JamendoError.missingClientID
        }

        let keyword = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !keyword.isEmpty else { return [] }

        guard var components = URLComponents(
            string: "\(JamendoConfig.baseURL)/tracks/"
        ) else {
            throw JamendoError.invalidURL
        }

        // Jamendo's `search` field checks track, album, and artist names.
        components.queryItems = [
            URLQueryItem(name: "client_id", value: JamendoConfig.clientID),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "search", value: keyword),
            URLQueryItem(name: "limit", value: "30"),
            URLQueryItem(name: "audioformat", value: "mp32"),
            URLQueryItem(name: "type", value: "single albumtrack")
        ]

        guard let url = components.url else {
            throw JamendoError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 20
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch let error as URLError {
            throw JamendoError.network(error.localizedDescription)
        }

        guard let http = response as? HTTPURLResponse else {
            throw JamendoError.badResponse
        }

        guard (200...299).contains(http.statusCode) else {
            throw JamendoError.httpStatus(http.statusCode)
        }

        let result: TrackResponse
        do {
            result = try JSONDecoder().decode(TrackResponse.self, from: data)
        } catch {
            throw JamendoError.invalidData
        }

        if let headers = result.headers, headers.code != 0 {
            throw JamendoError.api(headers.errorMessage.isEmpty
                ? "Jamendo mengembalikan kode error \(headers.code)."
                : headers.errorMessage)
        }

        return result.results.filter { $0.audio != nil }
    }
}

enum JamendoError: LocalizedError {
    case missingClientID
    case invalidURL
    case network(String)
    case badResponse
    case httpStatus(Int)
    case invalidData
    case api(String)

    var errorDescription: String? {
        switch self {
        case .missingClientID:
            return "Client ID Jamendo belum diatur."
        case .invalidURL:
            return "Alamat pencarian Jamendo tidak valid."
        case .network(let message):
            return "Tidak dapat terhubung ke internet. \(message)"
        case .badResponse:
            return "Respons server Jamendo tidak valid."
        case .httpStatus(let status):
            return "Server Jamendo mengalami kendala (HTTP \(status))."
        case .invalidData:
            return "Data dari Jamendo tidak dapat dibaca."
        case .api(let message):
            return "Jamendo: \(message)"
        }
    }
}
