# Fork Release Setup (Android + Windows)

Workflow: `.github/workflows/fork-android-windows-release.yml`

## Required for builds

- `ANDROID_SIGNING_KEY` (base64 keystore, optional but recommended)
- `ANDROID_SIGNING_STORE_PASSWORD` (optional with key)
- `ANDROID_SIGNING_KEY_PASSWORD` (optional with key)
- `ANDROID_SIGNING_KEY_ALIAS` (optional with key)

- `WINDOWS_SIGNING_KEY` (base64 `.pfx`, optional)
- `WINDOWS_SIGNING_PASSWORD` (optional with key)

## Recommended repository variables (branding overrides)

- `BRAND_NAME` (example: `PORTALapp`)
- `ANDROID_APPLICATION_ID` (example: `com.kiwunaka.portalapp`)
- `ANDROID_NAMESPACE` (example: `com.kiwunaka.portalapp`)
- `ANDROID_TEST_NAMESPACE` (example: `test.com.kiwunaka.portalapp`)
- `URI_SCHEME` (example: `portalapp`)
- `WINDOWS_IDENTITY_NAME` (example: `Kiwunaka.PortalApp`)
- `WINDOWS_PUBLISHER_NAME` (example: `Kiwunaka`)
- `WINDOWS_INSTALL_DIR` (example: `PORTALapp`)
- `WINDOWS_EXE_STEM` (example: `PORTALapp`)
- `BRAND_COPYRIGHT` (optional custom copyright line)

## Required for Play upload (optional)

- `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON`
- Repository variable `ANDROID_PACKAGE_NAME` (defaults to `app.hiddify.com` if missing)

## Required for mirror upload (optional)

- `MIRROR_SSH_HOST`
- `MIRROR_SSH_USER`
- `MIRROR_SSH_KEY` (private key in PEM/OpenSSH format)

## Manual run

1. Open Actions -> `Fork Android + Windows Release`.
2. Set:
   - `release_tag` (example: `v1.0.0`)
   - `channel` (`prod` for stable, `dev` for test channel)
   - enable `create_github_release`
   - enable `upload_to_play` when AAB should be pushed to Play track
   - enable `push_to_mirror` when mirror upload is configured
3. Run workflow.
4. Download artifact `release-handoff` and apply links via:
   - `pwsh external/client-fork/scripts/release_handoff.ps1`
   - `python external/client-fork/scripts/check_release_urls.py --env-file external/client-fork/release-links.env`
