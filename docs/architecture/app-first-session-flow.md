# App-First Session Flow

Last updated: 2026-04-12

## Document Status

This file is the living client architecture note for app-first identity and provisioning.

## Goal

Replace Telegram-first access with an app-native identity and provisioning flow for `POKROV VPN`.

## Core Principle

After `Try free`, the app must receive a real working VPN profile.

UI state alone is not enough. The backend must create a working account, a working device record, and a working subscription source.

## Current Flow

1. App generates and persists `install_id`.
2. App collects soft device context.
3. User taps `Try free`.
4. App calls `POST /api/client/session/start-trial`.
5. Backend validates anti-abuse rules.
6. Backend creates:
   - `app_account`
   - `device_record`
   - `app_session`
7. Backend provisions a real subscription source.
8. Backend returns:
   - `session`
   - `access`
   - `provisioning`
   - experience payload
9. App silently imports the subscription URL and activates the profile.
10. Home screen changes to `Quick Connect`.

UX guardrail:

- until step 9 completes with a real subscription payload, `Locations` stays behind an activation gate and does not render fake/demo countries as if the device already had live access

Contract note:

- the client no longer sends caller-controlled `trial_days`
- the backend always enforces the canonical `5-day` trial from the shared surface facts
- `provisioning.status` must expose whether the profile is ready immediately or still pending sync

## Client-Side Foundation Already Present

As of 2026-03-20, the client-side foundation already covers:

- stable `install_id`
- runtime app `session_token`
- device context headers on portal API calls
- `Try free` action from the empty home screen
- silent subscription import into the existing profile pipeline
- automatic activation of the imported profile

That means the remaining work is mostly final UX polish and backend contract alignment rather than first-principles plumbing.

Current consumer shell IA:

- `VPN`
- `Locations`
- `Devices`
- `Profile`
- `Support`

Legacy `/config-options`, `/about`, and `/logs` should survive only as compatibility redirects, not as the public navigation model.

Shared-surface config note:

- client public defaults are synced from root `shared/*.json`
- Flutter consumes the synced adapter file `lib/features/portal/config/shared_surface_facts.dart`

## Related Flows

### Telegram linking

Current platform contract:

- `POST /api/client/telegram/link`

### Telegram bonus claim

Current platform contract:

- `POST /api/bonuses/channel/claim`

Linked Telegram identity and membership in `@pokrov_vpn` can grant `+10 days`.

### Checkout continuation

- renewal and upgrade begin from the client UI
- the app opens the canonical hosted checkout in the external browser
- selected plans continue through the same backend checkout contract used by site and bot flows

### Support

Support payloads should carry:

- app account context
- device record context
- platform
- app version
- last known IP when available

Client UX rule:

- the support screen should prepare context and then continue through Telegram support or email
- plain connection links, manual import, and similar recovery tools should stay behind advanced/recovery surfaces after silent import succeeds
- the daily user journey should remain inside `VPN`, `Locations`, `Profile`, and `Support`, not bounce users back into raw config affordances
- do not imply a realtime in-app chat unless there is a real backend thread flow behind it
- diagnostics should expose only safe summaries such as routing mode and route category
- diagnostics must not leak raw config, keys, or detailed topology
- when no real session exists yet, support and profile surfaces may show prepared context and recovery entry points, but they must not pretend that live threads or live location inventory already exist

### Download surfaces

- the client fetches `/api/client/apps` and uses runtime URLs for Android `APK` / mirror and Windows `EXE` / mirror, plus docs/install fallback
- release handoff updates those runtime `APP_*` URLs on brain for the app, bot, and authenticated WebApp flows
- static marketing download CTAs are not driven by this runtime payload and must be rebuilt/redeployed when public Android or Windows URLs change
- signed release builds inject updater/source-code metadata through `PORTAL_RELEASE_REPOSITORY_URL`, `PORTAL_RELEASES_API_URL`, `PORTAL_RELEASES_LATEST_URL`, `PORTAL_RELEASES_APPCAST_URL`, and `PORTAL_WARP_DEFAULTS_URL`
- local non-release builds keep updater and source-code surfaces disabled instead of falling back to a personal repository URL
- `AAB`, `MSIX`, and portable `ZIP` remain release/store artifacts rather than first-layer client download targets today
- when `release_gate_check.py` includes Android build gates, it must also include `python scripts/android_localhost_audit.py` against a release-installed build on a physical device via `ANDROID_AUDIT_SERIAL`

## Identity Strategy

- primary identifier: `install_id`
- secondary anti-abuse signal: `fingerprint_signal`
- human-readable identity: `device_name`

This is preferred over a Telegram-only identity model.

## Scope Note

This client flow is the shipping `v1` path for:

- `Android`
- `Windows`

For `iOS` and `macOS`, this document is a readiness reference only until Apple publication is formally approved.
