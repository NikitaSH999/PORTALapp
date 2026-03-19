# PORTAL VPN v1 Product Spec

Last updated: 2026-03-20

## Document Status

This file is the living client product spec for `PORTAL VPN`.

## Summary

`PORTAL VPN` is a `consumer-first`, `app-first` VPN application for `Android` and `Windows`.

The target journey is:

- open the app
- tap `Try free`
- receive a real working trial subscription
- tap `Connect`

Telegram must remain optional for first use. It is a growth, recovery, and reward channel, not the primary login wall.

## Locked Product Decisions

- product name: `PORTAL VPN`
- UX direction: `consumer-first`
- account model: `app-first`
- default runtime core: `sing-box`
- `xray` support: advanced compatibility fallback only
- free trial: `5 days`
- Telegram reward: `+10 days`

## Target User Experience

### First launch

The user sees:

- brand and trust message
- `Try free` primary CTA
- short explanation that the trial activates on this device

The app should not ask for:

- keys
- subscription URLs
- Telegram login
- manual import as the primary path

### After trial activation

The app receives a real subscription payload, imports it silently, and switches to a `Quick Connect` home screen.

The home screen should show:

- a large `Connect` button
- `Auto-select` location by default
- current location or best location
- trial or subscription state
- quick access to devices, profile, and support

## Information Architecture

Primary tabs:

1. `VPN`
2. `Locations`
3. `Devices`
4. `Profile`
5. `Support`

## Telegram Role

Telegram is used for:

- optional account binding
- reward campaign `+10 days`
- recovery flows
- community and announcements

Current aligned channel and bot:

- channel: `@pokrov_vpn`
- main bot: `@portal_service_bot`

## Support Direction

Support should be reachable from:

- the app itself
- WebApp if the user is already in the platform
- helpbot `@portal_privacy_helpbot`

## Branding Requirements

The app must be fully rebranded away from Hiddify.

Replace:

- app name strings
- launcher icons
- splash assets
- tray icons
- update metadata
- release asset names
- visible `Hiddify` references in UI

Brand source:

- [logogo.png](C:/Users/kiwun/Documents/ai/VPN/external/logogo.png)

## v1 Scope

In scope:

- app-first trial activation
- silent profile provisioning
- quick connect UX
- locations list
- devices management
- profile and renewal
- in-app support
- Telegram reward `+10 days`
- full rebrand cleanup for Android and Windows

Out of scope:

- forced Telegram sign-in as the primary gate
- admin panel inside the client
- power-user-first navigation
- manual config import as the primary onboarding path
