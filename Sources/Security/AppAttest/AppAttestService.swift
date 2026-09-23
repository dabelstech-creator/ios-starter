import Foundation
import DeviceCheck
import CryptoKit
import Observation

/// Production-ready App Attest service for cryptographic device binding.
///
/// Usage overview:
/// 1. Call `prepareKeyIfNeeded()` early (e.g. on launch or after login).
/// 2. Obtain a one-time challenge from your server.
/// 3. Call `attest(challenge:)` once and send the result + keyId to the server.
/// 4. For subsequent protected requests, call `assert(clientData:)` and send the assertion.
///
/// Always check `isSupported` and provide a graceful fallback path.
@Observable
final class AppAttestService: @unchecked Sendable {

    // MARK: - Public state

    /// Whether the current device supports App Attest (Secure Enclave required).
    var isSupported: Bool {
        DCAppAttestService.shared.isSupported
    }

    /// The currently loaded key identifier (nil until prepared).
    private(set) var keyId: String?

    /// Indicates whether a key has been generated and persisted.
    var hasKey: Bool { keyId != nil }

    // MARK: - Private

    private let service = DCAppAttestService.shared
    private let keyAccount = "appAttestKeyId"

    // MARK: - Key lifecycle

    /// Loads an existing keyId from Keychain or generates a new one.
    /// Call this once per user session or after detecting reinstall.
    @MainActor
    func prepareKeyIfNeeded() async throws {
        guard isSupported else {
            throw AppAttestError.notSupported
        }

        if let existing = try KeychainHelper.load(account: keyAccount) {
            keyId = existing
            return
        }

        do {
            let newKeyId = try await service.generateKey()
            try KeychainHelper.save(keyId: newKeyId, account: keyAccount)
            keyId = newKeyId
        } catch {
            throw AppAttestError.keyGenerationFailed(underlying: error)
        }
    }

    /// Forces generation of a new key (e.g. after reinstall or key compromise).
    @MainActor
    func rotateKey() async throws {
        try KeychainHelper.delete(account: keyAccount)
        keyId = nil
        try await prepareKeyIfNeeded()
    }

    // MARK: - Attestation (one-time certification)

    /// Asks Apple to attest the key. Requires a fresh, high-entropy challenge from your server.
    /// - Parameter challenge: Raw challenge bytes from the server (≥16 bytes recommended).
    /// - Returns: The attestation object to send to your server together with `keyId`.
    func attest(challenge: Data) async throws -> Data {
        guard isSupported else { throw AppAttestError.notSupported }
        guard let keyId else { throw AppAttestError.noKeyId }
        guard !challenge.isEmpty else { throw AppAttestError.invalidChallenge }

        let clientDataHash = Data(SHA256.hash(data: challenge))

        do {
            return try await service.attestKey(keyId, clientDataHash: clientDataHash)
        } catch {
            // On most errors discard the key and force regeneration next time.
            // serverUnavailable can be retried with the same key.
            if let dcError = error as? DCError, dcError.code == .serverUnavailable {
                throw AppAttestError.attestationFailed(underlying: error)
            }
            try? KeychainHelper.delete(account: keyAccount)
            self.keyId = nil
            throw AppAttestError.attestationFailed(underlying: error)
        }
    }

    // MARK: - Assertion (per protected request)

    /// Generates an assertion for a protected payload.
    /// - Parameter clientData: The exact data that will be sent to the server (include a fresh challenge).
    /// - Returns: The assertion object to accompany the request.
    func assert(clientData: Data) async throws -> Data {
        guard isSupported else { throw AppAttestError.notSupported }
        guard let keyId else { throw AppAttestError.noKeyId }
        guard !clientData.isEmpty else { throw AppAttestError.invalidChallenge }

        let clientDataHash = Data(SHA256.hash(data: clientData))

        do {
            return try await service.generateAssertion(keyId, clientDataHash: clientDataHash)
        } catch {
            throw AppAttestError.assertionFailed(underlying: error)
        }
    }

    /// Convenience: builds a JSON payload, hashes it, and returns both the data and the assertion.
    func assertJSON<T: Encodable>(_ payload: T) async throws -> (clientData: Data, assertion: Data) {
        let clientData = try JSONEncoder().encode(payload)
        let assertion = try await assert(clientData: clientData)
        return (clientData, assertion)
    }
}
