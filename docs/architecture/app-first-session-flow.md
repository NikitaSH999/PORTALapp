# App-First Session Flow

Last updated: 2026-03-19

## Goal

Replace Telegram-first access with an app-native identity and provisioning flow.

## Core Principle

The app must provision a real VPN profile after `Try free`.

UI state alone is not enough. The backend must create a working account, a working device record, and a working subscription payload.

## Entities

### app_account

Represents the primary account identity inside the app.

Suggested fields:

- `id`
- `status`
- `plan_code`
- `trial_expires_at`
- `subscription_expires_at`
- `telegram_user_id` nullable
- `reward_balance_days`
- `created_at`
- `updated_at`

### device_record

Represents one installation or device linked to an app account.

Suggested fields:

- `id`
- `app_account_id`
- `install_id`
- `fingerprint_signal`
- `device_name`
- `platform`
- `model`
- `app_version`
- `locale`
- `timezone`
- `last_ip`
- `last_seen_at`
- `is_owner`
- `is_active`

### app_session

Represents a renewable authenticated app session.

Suggested fields:

- `id`
- `app_account_id`
- `device_record_id`
- `session_token`
- `refresh_token`
- `expires_at`
- `created_at`
- `revoked_at`

### reward_claim

Represents reward campaigns such as Telegram bonus.

Suggested fields:

- `id`
- `app_account_id`
- `type`
- `status`
- `granted_days`
- `metadata`
- `created_at`

## First Launch Flow

1. App generates and persists `install_id`.
2. App collects soft device context.
3. User taps `Try free`.
4. App calls `POST /api/client/session/start-trial`.
5. Backend validates anti-abuse rules.
6. Backend creates:
   - `app_account`
   - `device_record`
   - `app_session`
7. Backend provisions a real VPN subscription or profile source.
8. Backend returns:
   - `session_token`
   - `trial_expires_at`
   - `subscription_url`
   - `best_location`
   - `available_locations`
   - `device_limit`
9. App silently imports the subscription URL and activates the profile.
10. Home screen changes to `Quick Connect`.

## Suggested API Surface

### `POST /api/client/session/start-trial`

Purpose:

- create a trial-backed account and a device

Request:

- `install_id`
- `device_name`
- `platform`
- `os_version`
- `app_version`
- `locale`
- `time_zone`
- `trial_days`

Response:

- `session_token`
- optional inline `experience` payload with:
  - `session`
  - `dashboard`
  - `user`
  - `plans`
  - `tickets`
  - `apps`
  - `node_status`

## Current app implementation

As of `2026-03-19`, the client already implements the app-side foundation for this flow:

- persists a stable `install_id`
- stores a runtime app `session_token`
- sends `install_id` and device context headers on portal API calls
- activates trial from the empty home screen via `Try free`
- silently imports the returned subscription URL into the existing profile pipeline
- marks the imported profile active automatically

This means the remaining work for full Phase 2 is now mostly backend contract alignment and final UX polish, not the core client plumbing.

### `POST /app/session/refresh`

Purpose:

- refresh app auth session

### `GET /app/me`

Purpose:

- return current app account, plan, and reward state

### `GET /app/locations`

Purpose:

- return available free and premium locations

### `GET /app/devices`

Purpose:

- return linked devices with names and status

### `PATCH /app/devices/{id}`

Purpose:

- rename a device

### `DELETE /app/devices/{id}`

Purpose:

- unlink a device

### `POST /app/rewards/claim-telegram`

Purpose:

- verify Telegram campaign completion and add `+10 days`

### `POST /app/support/thread`

Purpose:

- create a support conversation

### `POST /app/support/message`

Purpose:

- send an in-app support message with device context

## Identity Strategy

### Primary identifier

- `install_id`

### Secondary anti-abuse signal

- `fingerprint_signal`

### Human-readable identity

- `device_name`

This balance is preferred over hard-only HWID because it is more resilient to normal user changes while still supporting abuse detection.

## Device Limit Policy

Suggested defaults:

- trial: `1 device`
- paid: up to `5 devices`

The device limit should be enforced at the `app_account` level, not only by opaque profile links.

## Telegram Reward Flow

1. User taps `Get +10 days`.
2. App opens Telegram deep link.
3. User completes campaign action.
4. User returns to app.
5. App calls `POST /app/rewards/claim-telegram`.
6. Backend validates eligibility and idempotency.
7. Backend extends access by `10 days`.

## Failure Handling

If trial provisioning fails:

- show a friendly retry state
- do not show a fake active trial
- do not require manual key import as fallback on the first screen

## Observability

Every support and provisioning event should include:

- `app_account_id`
- `device_record_id`
- `device_name`
- `platform`
- `app_version`
- `last_ip`
