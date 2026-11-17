import Foundation

enum JamendoConfig {
    static let baseURL = "https://api.jamendo.com/v3.0"

    static let clientID = "cc23d157"

    static var isConfigured: Bool {
        !clientID.isEmpty &&
        clientID != "YOUR_JAMENDO_CLIENT_ID"
    }
}
