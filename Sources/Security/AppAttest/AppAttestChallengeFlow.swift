import Foundation

/// Example server-challenge + App Attest flow helpers.
/// Replace the networking stubs with your real API client.
enum AppAttestChallengeFlow {

    /// Typical attestation sequence:
    /// 1. App requests a one-time challenge from the server.
    /// 2. App generates / loads keyId and calls `attest(challenge:)`.
    /// 3. App sends { keyId, attestation } to the server for verification.
    /// 4. Server stores the public key + counter for future assertions.
    static func performInitialAttestation(
        appAttest: AppAttestService,
        challengeProvider: () async throws -> Data,
        submitAttestation: (_ keyId: String, _ attestation: Data) async throws -> Void
    ) async throws {
        try await appAttest.prepareKeyIfNeeded()

        guard let keyId = appAttest.keyId else {
            throw AppAttestError.noKeyId
        }

        let challenge = try await challengeProvider()
        let attestation = try await appAttest.attest(challenge: challenge)
        try await submitAttestation(keyId, attestation)
    }

    /// Typical protected-request sequence:
    /// 1. App builds the request payload (include a fresh server challenge).
    /// 2. App calls `assert(clientData:)`.
    /// 3. App sends { keyId, assertion, clientData } to the server.
    /// 4. Server verifies signature + counter and processes the request.
    static func performProtectedRequest<
        Payload: Encodable
    >(
        appAttest: AppAttestService,
        payload: Payload,
        submit: (_ keyId: String, _ assertion: Data, _ clientData: Data) async throws -> Void
    ) async throws {
        guard let keyId = appAttest.keyId else {
            throw AppAttestError.noKeyId
        }

        let (clientData, assertion) = try await appAttest.assertJSON(payload)
        try await submit(keyId, assertion, clientData)
    }
}

// MARK: - Example payload types (adapt to your API)

struct AttestationChallengeRequest: Encodable {
    // empty or include device / user context if needed
}

struct ProtectedActionPayload: Encodable {
    let action: String
    let challenge: String          // base64 or hex of the server challenge
    let timestamp: Date
    // add any additional fields your endpoint expects
}
