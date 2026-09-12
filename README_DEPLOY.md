## TestFlight / App Store deployment (updated)

This repo now deploys to TestFlight only when you push a release tag (e.g., v1.0.0) or when you manually trigger the workflow.

Trigger
- Push a Git tag matching v*.*.* to run automatic deploys (recommended for releases), or trigger manually from the Actions tab (Deploy to TestFlight workflow).

Required GitHub Secrets (App Store Connect API key method - recommended)
- APP_STORE_CONNECT_API_KEY: Base64-encoded .p8 private key file content for the App Store Connect API Key.
  - Example to create the value locally:
    base64 -w0 AuthKey_ABC123.p8
    Copy the output into the secret value.
- APP_STORE_CONNECT_KEY_ID: the Key ID from App Store Connect (e.g., ABC123XYZ)
- APP_STORE_CONNECT_ISSUER_ID: the Issuer ID (UUID) from App Store Connect

Optional (only if you also want to provide profiles/certs):
- PROVISIONING_PROFILE_NAME: Name of the provisioning profile (used by fastlane export options). If you manage signing with Xcode automatic signing or App Store Connect API, this can be left empty.

How it works
1. The workflow decodes APP_STORE_CONNECT_API_KEY into AuthKey.p8 on the runner.
2. Fastlane uses the API key file, increments the build number (timestamp-based), builds an archive, and uploads it to TestFlight.

Security notes
- Do NOT commit credentials into the repository. Add them as encrypted secrets in GitHub: Settings → Secrets and variables → Actions.
- Prefer App Store Connect API key over uploading certificates to Actions.

Versioning
- The workflow will increment the build number automatically using a timestamp at each deploy. Use semantic version tags (e.g., v1.2.3) when pushing tags to indicate the release version in App Store Connect.
