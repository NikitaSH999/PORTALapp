# PORTAL VPN v1 Product Spec

Last updated: 2026-03-18

## Summary

`PORTAL VPN` is a `consumer-first`, `app-first` VPN application for `Android` and `Windows`.

The product goal is simple:

- open the app
- tap `Try free`
- receive a real working trial subscription
- tap `Connect`

The app must not require Telegram for first use. Telegram remains an optional growth and recovery channel.

## Product Decisions

### Final product name

- `PORTAL VPN`

### Core strategy

- UX direction: `consumer-first`
- Account model: `app-first`
- Platforms in scope for v1: `Android`, `Windows`
- Default runtime core: `sing-box`
- `xray` support: advanced compatibility fallback only

### Trial

- Free trial duration: `5 days`
- Telegram reward: `+10 days`
- Trial must create a real device account and a real working subscription profile
- Trial state must never be a decorative UI-only state

### Telegram role

Telegram is not required for:

- first launch
- trial activation
- normal VPN usage
- renewal inside the app

Telegram is used for:

- optional account binding
- reward campaign `+10 days`
- recovery flows
- community and announcements

## Target User Experience

### First launch

The user sees a clean screen with:

- brand
- trust message
- `Try free` primary CTA
- a short explanation that the app will activate a trial on this device

The app does not ask for:

- keys
- subscription URLs
- Telegram login
- manual config import

### After trial activation

The app silently receives a real subscription payload, imports the working profile, and switches to a `Quick Connect` home screen.

The home screen must show:

- a large `Connect` button
- `Auto-select` server as the default
- current location or best location
- trial or subscription status
- quick access to devices, profile, and support

## Information Architecture

### Main tabs

1. `VPN`
2. `Locations`
3. `Devices`
4. `Profile`
5. `Support`

### VPN

Primary responsibilities:

- show `Try free` before activation
- show `Connect` after activation
- show connection state
- show selected or auto-selected location
- show trial or subscription status
- show Telegram reward CTA

### Locations

Primary responsibilities:

- `Auto-select`
- countries and cities
- `Free` / `Premium` segmentation
- latency and node health
- favorites

### Devices

Primary responsibilities:

- show all linked devices
- show current device
- rename device
- unlink device
- show owner device
- show recent activity

### Profile

Primary responsibilities:

- current plan and expiry
- trial status
- renewal and purchase
- Telegram binding
- promo and reward status
- legal links

### Support

Primary responsibilities:

- in-app tickets or chat
- FAQ
- send diagnostics

## Advanced Settings Policy

Advanced settings remain in the product but are not part of the first-layer user journey.

### Hidden from first layer

- block ads
- bypass LAN
- resolve destination
- strict route
- DNS routing details
- inbound settings
- TLS tricks
- WARP
- logs
- Clash API
- core switching

### Visible in Advanced

- use xray when possible
- DNS settings
- WARP settings
- TLS tricks
- logs
- LAN options
- custom subscription import
- debug and compatibility switches

## Branding Requirements

The app must be fully rebranded away from Hiddify.

### Must be replaced

- app name strings
- package-facing display names
- launcher icons
- splash assets
- tray icons
- update metadata
- release asset names
- visible `Hiddify` references in UI

### Brand source

- primary logo asset: [logogo.png](C:/Users/kiwun/Documents/ai/VPN/external/logogo.png)

## Localization

Russian must be a first-class user-facing language.

Requirements:

- natural Russian wording
- no machine-like literal phrasing
- no advanced networking jargon on first-layer screens
- clear consumer copy for trial, billing, devices, and support

## v1 Scope

### In scope

- app-first trial activation
- silent profile provisioning
- quick connect UX
- locations list
- devices management
- profile and renewal
- in-app support
- Telegram reward `+10 days`
- full rebrand cleanup for Android and Windows

### Out of scope

- mandatory Telegram login
- admin panel inside the client
- power-user-first navigation
- manual config import as the primary onboarding path

## Success Criteria

The product is successful when a new store user can:

1. install the app
2. tap `Try free`
3. get a real working trial
4. connect without importing a key
5. understand the rest of the app without technical knowledge

