# POKROV VPN v1 Product Spec

Last updated: 2026-04-15

## Document Status

This file is the intake-baseline product spec for rebasing `PORTALapp/main` onto upstream commit `fbc6cbd4ed6a978e5923c8203a93080019a7777b`.

It records the user-facing behavior that must survive the upstream intake. It does not claim that every POKROV surface is already re-applied in this worktree.

## Must-Preserve Product Truth

- public product name: `POKROV`
- legacy client identifier: `POKROV VPN` only where compatibility removal is not yet feasible
- product direction: `consumer-first`
- identity direction: `app-first`
- public scope in this wave: `Android + Windows`
- Apple scope in this wave: readiness only
- default client core: `sing-box`
- `xray` remains advanced compatibility fallback only
- free trial: `5 days`
- Telegram reward: `+10 days`
- public version line: `0.x.x-beta`

## Must-Preserve First-Layer Experience

The rebased client must preserve these public contracts:

- `Try free` creates a real app-first session and imports a managed profile
- first-layer navigation remains `VPN`, `Locations`, `Devices`, `Profile`, `Support`
- first route-mode onboarding asks exactly `Optimize everything on this device` or `Only selected apps`
- public routing modes remain `All except RU` and `Full tunnel`
- hidden/internal `Blocked only` stays non-public until the routing and DNS layer is truly verified
- canonical deep links are `pokrov://`, with `pokrovvpn://` kept only as hidden compatibility
- support and checkout continuity remain first-layer consumer flows instead of power-user config flows

## Must-Preserve Platform And Packaging Truth

- Android package continuity stays on `space.pokrov.vpn`
- public release artifacts remain:
  - `pokrov-android-universal.apk`
  - `pokrov-android-market.aab`
  - `pokrov-windows-setup-x64.exe`
  - `pokrov-windows-setup-x64.msix`
  - `pokrov-windows-portable-x64.zip`
- repo-local Windows canonical packaging may defer `pokrov-windows-setup-x64.msix` when `scripts/package_windows.ps1` is run with `PACKAGE_WINDOWS_EXE_FIRST=1`; public Windows distribution remains `EXE`-first unless Store scope is explicitly included
- public Android and Windows branding must resolve to `POKROV`

## Confirmed Intake Baseline From Upstream Code

The intake branch already confirms these upstream realities:

- `pubspec.yaml` still uses internal package name `hiddify`
- `pubspec.yaml` currently reports version `4.1.2+40102`
- upstream toolchain in `pubspec.yaml` targets Flutter `3.38.5` and Dart `3.10.4`
- the core layout is now `hiddify-core`
- `dependencies.properties` currently pins `core.version=4.1.0`

These are intake implementation realities to port around. They are not public POKROV product truth.

## Deferred Internal Rename Debt

The intake wave does not automatically clear every inherited internal identifier. The following remain deferred unless they block public Android or Windows surfaces:

- `name: hiddify`
- `package:hiddify/...` imports
- Android namespace and Kotlin package-tree debt under `com.hiddify.hiddify`
- hidden non-public Hiddify identifiers that do not leak into user-visible release surfaces

## Release Status For This Lane

This docs lane does not claim final release closure.

Still required before any final public-ready claim:

- mixed-lane code integration completed on the client branch
- final client gate suite and artifact builds green
- Windows packaging validation on the rebased tree
- Android physical-device localhost audit on a release-installed build
- final handoff evidence for `current-origin`, `brain-origin`, and `RU-origin`
