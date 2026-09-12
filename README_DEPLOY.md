## TestFlight / App Store deployment (updated: auto-deploy on push to main + fastlane match support)

This repository is configured to automatically build and deploy to TestFlight when commits are pushed to the `main` branch and when the workflow is manually triggered. It also supports fetching signing identities and provisioning profiles from a private Fastlane Match repository.

WARNING (auto-deploy):
- Automatic deployment on every push to `main` is enabled. This will upload every successfully built commit to TestFlight and can consume processing quota and create many builds. Strongly consider protecting the `main` branch (require PRs and approvals) or switching to tag-only deployment for production releases.

What I changed
- deploy.yml: now triggers on push to `main` and workflow_dispatch.
- Fastfile: calls `match` (readonly) if MATCH_GIT_URL and MATCH_PASSWORD secrets are present, then builds and uploads via App Store Connect API key when available.
- Added environment variables consumed by the workflow for match and App Store Connect API key.

Required / optional GitHub Secrets
- APP_STORE_CONNECT_API_KEY (recommended): Base64-encoded .p8 private key from App Store Connect API Key.
- APP_STORE_CONNECT_KEY_ID: Key ID from App Store Connect
- APP_STORE_CONNECT_ISSUER_ID: Issuer ID from App Store Connect

For Fastlane Match (recommended for teams managing certs centrally):
- MATCH_GIT_URL: HTTPS URL to your private match git repo. If the repo is private, you can include a token in the URL (see example) or set up deploy keys.
  - Example using a personal access token (PAT):
    https://<PERSONAL_ACCESS_TOKEN>@github.com/your-org/fastlane-match-certs.git
  - Alternative: set up an SSH deploy key and configure the Actions runner to use it (more secure).
- MATCH_PASSWORD: Password used to encrypt the certificates in the match repo.
- MATCH_GIT_BRANCH (optional): branch name in your match repo (default: main)

Notes on using Match
- Initial setup: one admin should run `fastlane match init` and `fastlane match appstore` locally to create and push certificates and profiles to the match repo. After the repo has the certs, set MATCH_GIT_URL and MATCH_PASSWORD in GitHub Secrets so the Actions runner can fetch them (readonly).
- In CI we use `readonly: true` so the runner only pulls credentials and does not attempt to create or modify them.

How to prepare Match repo (high level)
1. On your dev machine, install fastlane and run:
   fastlane match appstore --app_identifier "com.dabelstech-creator.ios-starter" --git_url "https://github.com/your-org/fastlane-match-certs.git"
2. Follow prompts to create or use an existing certificate and provisioning profile; push them to the private repo.
3. Add the repo URL and MATCH_PASSWORD value to GitHub Secrets.

How to trigger a deployment
- Push to main: commits to `main` will automatically start the deploy workflow.
- Manual trigger: Actions -> Deploy to TestFlight -> Run workflow

Security recommendations
- Use a private match repo and a short-lived PAT or deploy key for access (avoid embedding permanent tokens directly in the URL if possible).
- Use branch protection on `main` and require PR reviews before merging.
- Use the App Store Connect API key rather than P12 uploads to Actions where possible.

If you want, I can:
- Add an example action step to configure an SSH deploy key for match (more secure than PAT-in-URL).
- Or modify the workflow to only deploy on protected branch merges or tags instead of every push.
