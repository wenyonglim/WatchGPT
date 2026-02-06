import Foundation
import Security

enum KeychainService {
    private static var service: String {
        Bundle.main.bundleIdentifier ?? "WatchGPT"
    }

    private static let account = "openai_api_key"

    static let didChangeNotification = Notification.Name("KeychainService.didChangeAPIKey")

    static func getAPIKey() -> String? {
        var query = baseQuery()
        query[kSecReturnData as String] = kCFBooleanTrue
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var item: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess, let data = item as? Data else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }

    static func setAPIKey(_ key: String) throws {
        let data = Data(key.utf8)

        let query = baseQuery()
        let update: [String: Any] = [
            kSecValueData as String: data,
        ]

        let status = SecItemUpdate(query as CFDictionary, update as CFDictionary)
        if status == errSecItemNotFound {
            var addQuery = baseQuery()
            addQuery[kSecValueData as String] = data
            let addStatus = SecItemAdd(addQuery as CFDictionary, nil)
            guard addStatus == errSecSuccess else {
                throw KeychainError.unhandled(status: addStatus)
            }
            notifyKeyDidChange()
            return
        }

        guard status == errSecSuccess else {
            throw KeychainError.unhandled(status: status)
        }

        notifyKeyDidChange()
    }

    static func deleteAPIKey() throws {
        let status = SecItemDelete(baseQuery() as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unhandled(status: status)
        }

        notifyKeyDidChange()
    }

    static func hasAPIKey() -> Bool {
        guard let key = getAPIKey() else { return false }
        return !key.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private static func baseQuery() -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
        ]
    }

    private static func notifyKeyDidChange() {
        NotificationCenter.default.post(name: didChangeNotification, object: nil)
    }
}

enum KeychainError: LocalizedError {
    case unhandled(status: OSStatus)

    var errorDescription: String? {
        switch self {
        case .unhandled(let status):
            return "Keychain error: \(status)"
        }
    }
}
