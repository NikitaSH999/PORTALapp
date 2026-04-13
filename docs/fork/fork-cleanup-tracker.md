# Fork Cleanup Tracker

Last updated: 2026-04-12

## Goal

Track the remaining brand-migration work for `POKROV VPN` without accidentally destabilizing the shipping client fork.

## Branding

| Area | Status | Notes |
|---|---|---|
| App display name | Mostly done | Runtime app surfaces ship as `POKROV VPN`; keep checking installer/store metadata and release payloads |
| Launcher icon | Pending | Must switch to final logo assets for public release |
| Splash assets | In progress | Runtime splash is aligned, launcher/store derivatives still need regeneration |
| Tray icons | Pending | Still depend on inherited asset pipeline |
| App update metadata | Done | Appcast, web manifest, release message, store descriptions, and release-url fallbacks no longer point to the personal repo and now use `POKROV VPN` branding |
| README and docs branding | Mostly done | Canonical docs and release handoff readmes are aligned; stale supporting history files may still exist |

## Remaining visible Hiddify references

| Area | Status | Notes |
|---|---|---|
| Supporting docs and inherited history files | Pending | Clean up only what can confuse public release or operator handoff |
| Binary names such as `HiddifyCli.exe` | Done | `libcore`, build scripts, and Windows release bundle now use `POKROVCli.exe` only |
| Advanced labels and old settings wording | Pending | Must be rewritten for consumer UX where visible to end users |
| Android namespace / test namespace | Deferred | `com.hiddify.hiddify` and `test.com.hiddify.hiddify` stay until the package tree is migrated as a dedicated refactor |
| Internal package name / imports | Deferred | `pubspec name: hiddify` and `package:hiddify/...` are internal refactor debt, not a last-minute public-v1 rename |

## UX cleanup

| Area | Status | Notes |
|---|---|---|
| Trial shown without working profile | Done | Portal tests cover live app-first trial provisioning and silent import |
| Fake demo nodes | Mostly done | Portal flows now use backend-backed data; keep validating release builds with real payloads |
| In-app support using demo copy | Mostly done | Support composer exists; final release verification still needed against production wiring |
| Russian copy polish | In progress | Consumer-facing copy improved, but advanced/legacy wording still needs a final pass |
| First-layer Hiddify power-user settings | In progress | Keep finishing the move of technical controls into `Advanced` |

## Product decisions already locked

- Product name: `POKROV VPN`
- Trial: `5 days`
- Telegram reward: `+10 days`
- Product direction: `consumer-first`
- Identity direction: `app-first`
- Default core: `sing-box`
- `xray` only in advanced compatibility mode

## Immediate implementation priorities

1. Regenerate launcher, tray, and store-facing assets from the final `POKROV VPN` brand set.
2. Run the connected-device Android localhost audit against a release-installed build before public Android publication.
3. Finish visible advanced-surface wording cleanup.
4. Recheck runtime support, reward, and profile flows in signed release-mode builds.
5. Keep internal package/import and Android namespace debt as a separate coordinated refactor instead of a last-minute public rename.
