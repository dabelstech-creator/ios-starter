import Foundation
import Security

/// Secure Keychain storage helper for App Attest key identifiers.
/// Uses `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly` to keep the keyId
/// on-device and unavailable before first unlock.
enum KeychainHelper {

    private static let service = "com.dabelstech.ios-starter.appattest"

    /// Saves the App Attest keyId to the Keychain.
    static func save(keyId: String, account: String = "appAttestKeyId") throws {
        guard let data = keyId.data(using: .utf8) else {
            throw AppAttestError.keychainSaveFailed(errSecParam)
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        ]

        // Remove any existing item first
        SecItemDelete(query as CFDictionary)

        let status = SecItemAdd(query as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw AppAttestError.keychainSaveFailed(status)
        }
    }

    /// Loads the App Attest keyId from the Keychain.
    static func load(account: String = "appAttestKeyId") throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        switch status {
        case errSecSuccess:
            guard let data = result as? Data,
                  let keyId = String(data: data, encoding: .utf8) else {
                return nil
            }
            return keyId
        case errSecItemNotFound:
            return nil
        default:
            throw AppAttestError.keychainLoadFailed(status)
        }
    }

    /// Deletes the stored keyId (useful after reinstall detection or key rotation).
    static func delete(account: String = "appAttestKeyId") throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw AppAttestError.keychainSaveFailed(status)
        }
    }
}
