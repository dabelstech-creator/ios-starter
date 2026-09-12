## TestFlight / App Store deployment

This repo includes a template GitHub Actions workflow and a Fastlane configuration to build the app and upload it to TestFlight.

Important: uploading to TestFlight requires valid App Store Connect credentials, certificates, and provisioning profiles. The workflow below is a template and needs secrets configured in the repository settings before it will work.

Required GitHub Secrets (choose one approach below):

A) App Store Connect API key (recommended):
- APP_STORE_CONNECT_API_KEY: Base64-encoded JSON key content for the App Store Connect API Key (the private key JSON file). Example to create and encode locally:
  1. Download the API key JSON from App Store Connect (Keys section).
  2. base64 -w0 AuthKey_XXXXXX.json
  3. Copy the output into the secret value.
- APP_STORE_CONNECT_KEY_ID: the Key ID from App Store Connect (e.g., XXXXXX)
- APP_STORE_CONNECT_ISSUER_ID: the Issuer ID from App Store Connect (UUID)

B) Certificate + provisioning profile (alternative):
- CERTIFICATE_P12: Base64-encoded .p12 certificate (including private key). Create with:
    openssl pkcs12 -export -out cert.p12 -inkey private.key -in certificate.crt -certfile intermediate.crt
    base64 -w0 cert.p12
- CERTIFICATE_P12_PASSWORD: password used when exporting the .p12
- PROVISIONING_PROFILE: Base64-encoded .mobileprovision file
- PROVISIONING_PROFILE_NAME: The provisioning profile name to match in export options
- APPLE_ID: Your Apple ID (email) if using app-specific password for fastlane deliver (not required when using API key)
- APP_SPECIFIC_PASSWORD: App-specific password for your Apple ID (if using username/password upload)

Optional / alternative: Use Fastlane Match (recommended for teams):
- MATCH_PASSWORD: password for the match repo (if using match to manage certs) and configure a private repo for match.

How it works
1. The workflow decodes provisioning and certificate secrets (if provided) and installs them into the macOS runner.
2. It runs `xcodegen` to generate the Xcode project, builds an archive, and then invokes Fastlane to upload to TestFlight.

Manual steps before you run the workflow
- Register your app (bundle id: com.dabelstech-creator.ios-starter) in App Store Connect and create an app record.
- Create an App Store Connect API Key (recommended) or export a certificate and provisioning profile from the Developer portal.
- Add the required secrets to the GitHub repository (Settings → Secrets and variables → Actions).

Triggering deployment
- The workflow is configured to run on push to `main` and via manual `workflow_dispatch` so you can trigger deployments on demand from the Actions tab.

Security notes
- Keep certificates and keys secret. Use a private match repo or App Store Connect API keys where possible.
- Rotate keys and revoke compromised credentials immediately.
