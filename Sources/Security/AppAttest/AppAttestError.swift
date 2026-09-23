import Foundation

/// Errors that can occur during App Attest operations.
enum AppAttestError: Error, LocalizedError, Sendable {
    case notSupported
    case noKeyId
    case keyGenerationFailed(underlying: Error?)
    case attestationFailed(underlying: Error?)
    case assertionFailed(underlying: Error?)
    case keychainSaveFailed(OSStatus)
    case keychainLoadFailed(OSStatus)
    case invalidChallenge
    case serverChallengeRequired

    var errorDescription: String? {
        switch self {
        case .notSupported:
            return "App Attest is not supported on this device (requires Secure Enclave)."
        case .noKeyId:
            return "No App Attest key identifier is available. Generate and attest a key first."
        case .keyGenerationFailed(let underlying):
            return "Failed to generate App Attest key: \(underlying?.localizedDescription ?? "unknown error")"
        case .attestationFailed(let underlying):
            return "App Attest key attestation failed: \(underlying?.localizedDescription ?? "unknown error")"
        case .assertionFailed(let underlying):
            return "App Attest assertion generation failed: \(underlying?.localizedDescription ?? "unknown error")"
        case .keychainSaveFailed(let status):
            return "Failed to save keyId to Keychain (OSStatus: \(status))."
        case .keychainLoadFailed(let status):
            return "Failed to load keyId from Keychain (OSStatus: \(status))."
        case .invalidChallenge:
            return "Challenge data is empty or invalid. Server must provide a high-entropy challenge (≥16 bytes recommended)."
        case .serverChallengeRequired:
            return "A fresh one-time challenge from the server is required for attestation or assertion."
        }
    }
}
