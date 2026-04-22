# App-First Session Flow

Last updated: 2026-04-15

## Document Status

This file records the app-first contract that must be re-applied on top of upstream intake commit `fbc6cbd4ed6a978e5923c8203a93080019a7777b`.

It captures confirmed preserve requirements and known re-port risks. It does not claim that the upstream intake already satisfies the full POKROV portal contract.

## Must-Preserve Endpoint Contract

The rebased client must keep these backend contracts aligned with the platform lane:

- `POST /api/client/session/start-trial`
- `GET /api/client/profile/managed`
- `POST /api/client/route-policy`
- `POST /api/client/nodes/latency-samples`
- `POST /api/client/telegram/link`
- `POST /api/bonuses/channel/claim`
- `/api/tickets*`
- `GET /api/client/apps`

## App-First Provisioning Baseline

The preserved app-first path is:

1. create and persist `install_id`
2. call `POST /api/client/session/start-trial`
3. receive app-first session, access, provisioning, and `client_policy`
4. fetch the managed profile through `GET /api/client/profile/managed`
5. import the managed payload
6. ask for the route-mode choice before the first live route activation
7. continue into `Quick Connect`

Managed-profile rules that are already confirmed by root docs and code review:

- `GET /api/client/profile/managed` is the primary app-managed provisioning endpoint
- the managed endpoint returns a manifest-shaped payload, not a raw legacy config body
- `subscription_url` remains compatibility and recovery fallback only
- the older `managed-manifest` style path is not the current source of truth

## Route-Mode Baseline

The preserved route-mode contract is:

- first-run choice must show exactly `Optimize everything on this device` and `Only selected apps`
- the choice must remain editable later from a dedicated route-mode screen
- backend-owned fields remain the contract truth:
  - `route_mode`
  - `selected_apps`
  - `requires_elevated_privileges`
  - `route_policy.mode`
  - `route_policy.selected_apps`
  - `route_policy.requires_elevated_privileges`
- Windows uses an executable/process picker for selected-apps mode
- Android uses an installed-package picker for selected-apps mode

Confirmed baseline nuance:

- the previous fork stored route-mode onboarding state in local preferences
- baseline review did not find a fully implemented live rehydration path from backend-owned route-policy fields back into local state
- this rebase wave must preserve backend round-trip truth instead of drifting back to local-only state

## Routing, Catalog, And Deep-Link Compatibility

Confirmed preserve rules from code review:

- public routing modes remain `All except RU` and `Full tunnel`
- hidden/internal `Blocked only` must stay non-public
- Android split-tunnel assistance depends on a curated direct package catalog
- Windows split-tunnel assistance depends on executable discovery
- `package_catalog_version` is support and diagnostics truth today, not a remote catalog-selection contract
- canonical deep-link scheme remains `pokrov://`
- hidden compatibility deep-link scheme remains `pokrovvpn://`

## Known Re-Port Risks Already Confirmed

- upstream router and layout architecture moved, so the old home/settings/router files are not safe cherry-picks
- upstream no longer matches the old `lib/features/config_option/**` route-mode lane shape, so route-mode behavior needs deliberate reimplementation on the new stack
- deep-link parsing and platform registration must be re-ported explicitly on Android and Windows
- prior fork tests and activation code still showed contract drift around managed-profile import, so the rebased lane must target the current managed-manifest contract rather than replaying the older raw-import assumption
