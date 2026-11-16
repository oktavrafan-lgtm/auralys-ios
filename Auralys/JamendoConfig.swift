import Foundation

enum JamendoConfig {
    static let baseURL = "https://api.jamendo.com/v3.0"

    // Isi dengan Client ID Jamendo milikmu nanti
    static let clientID = "YOUR_JAMENDO_CLIENT_ID"

    static var isConfigured: Bool {
        clientID != "YOUR_JAMENDO_CLIENT_ID" &&
        !clientID.isEmpty
    }
}
