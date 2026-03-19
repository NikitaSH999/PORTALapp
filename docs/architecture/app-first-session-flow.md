# App-First Session Flow

Last updated: 2026-03-20

## Document Status

This file is the living client architecture note for app-first identity and provisioning.

## Goal

Replace Telegram-first access with an app-native identity and provisioning flow.

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
   - `session_token`
   - `trial_expires_at`
   - `subscription_url`
   - experience payload
9. App silently imports the subscription URL and activates the profile.
10. Home screen changes to `Quick Connect`.

## Client-Side Foundation Already Present

As of 2026-03-20, the client-side foundation already covers:

- stable `install_id`
- runtime app `session_token`
- device context headers on portal API calls
- `Try free` action from the empty home screen
- silent subscription import into the existing profile pipeline
- automatic activation of the imported profile

That means the remaining work is mostly final UX polish and backend contract alignment rather than first-principles plumbing.

## Related Flows

### Telegram linking

Current platform contract:

- `POST /api/client/telegram/link`

### Telegram bonus claim

Current platform contract:

- `POST /api/bonuses/channel/claim`

Linked Telegram identity and membership in `@pokrov_vpn` can grant `+10 days`.

### Support

Support payloads should carry:

- app account context
- device record context
- platform
- app version
- last known IP when available

## Identity Strategy

- primary identifier: `install_id`
- secondary anti-abuse signal: `fingerprint_signal`
- human-readable identity: `device_name`

This is preferred over a Telegram-only identity model.
