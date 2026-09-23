# App Attest Module (Device Binding)

Production-ready integration of Apple’s **App Attest** (`DCAppAttestService`) for cryptographic device binding.

## Files

| File | Purpose |
|------|---------|
| `AppAttestService.swift` | Core observable service – key generation, attestation, assertion |
| `KeychainHelper.swift` | Secure, device-only storage of the `keyId` |
| `AppAttestError.swift` | Typed errors with localized descriptions |
| `AppAttestChallengeFlow.swift` | Example orchestration of the server-challenge → attest / assert flow |

## Quick Start

```swift
import DeviceCheck

@MainActor
let appAttest = AppAttestService()

do {
    // 1. Prepare key (loads from Keychain or generates new)
    try await appAttest.prepareKeyIfNeeded()

    // 2. Obtain challenge from your backend
    let challenge = try await apiClient.fetchAttestationChallenge()

    // 3. Attest
    let attestation = try await appAttest.attest(challenge: challenge)

    // 4. Send to server for verification
    try await apiClient.submitAttestation(
        keyId: appAttest.keyId!,
        attestation: attestation
    )
} catch AppAttestError.notSupported {
    // Graceful fallback – device has no Secure Enclave
} catch {
    // Handle other errors
}
```

## Protected Request Example

```swift
let payload = ProtectedActionPayload(
    action: "getPremiumContent",
    challenge: serverChallengeBase64,
    timestamp: .now
)

let (clientData, assertion) = try await appAttest.assertJSON(payload)

try await apiClient.sendProtectedRequest(
    keyId: appAttest.keyId!,
    assertion: assertion,
    clientData: clientData
)
```

## Requirements

- iOS 14.0+
- Device with Secure Enclave (simulator is **not** supported)
- `DeviceCheck.framework` linked
- Server-side verification of attestation & assertion objects (mandatory)

## Security Notes

- One key per user account (or one key for the whole app).
- Keys do **not** survive reinstall / device restore → regenerate.
- Always use a fresh high-entropy challenge (≥16 bytes).
- Never treat App Attest or TestFlight detection as a sole security boundary.
- Prefer Keychain with `AfterFirstUnlockThisDeviceOnly`.

## TestFlight / Environment

TestFlight and App Store builds automatically use the **production** App Attest environment.
Combine with your existing `sandboxReceipt` detection for analytics / feature flags only.
