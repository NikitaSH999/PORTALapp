# Fork Cleanup Tracker

Last updated: 2026-04-15

## Goal

Track the confirmed cleanup and deferred-debt state for the upstream intake branch without pretending the POKROV rebase wave is already closed.

## Confirmed Intake Baseline

- pinned upstream intake commit: `fbc6cbd4ed6a978e5923c8203a93080019a7777b`
- upstream toolchain baseline: Flutter `3.38.5`, Dart `3.10.4`
- upstream internal version line in `pubspec.yaml`: `4.1.2+40102`
- upstream core layout: `hiddify-core`
- upstream core pin in `dependencies.properties`: `4.1.0`

## Public-Surface Contracts To Preserve

| Area | Status | Notes |
| --- | --- | --- |
| Public branding | Must preserve | Android and Windows public surfaces must resolve to `POKROV` |
| Deep links | Must preserve | `pokrov://` stays canonical, `pokrovvpn://` stays hidden compatibility only |
| Public routing labels | Must preserve | Keep `All except RU` and `Full tunnel` as the only public presets |
| Route-mode onboarding | Must preserve | Keep the exact two-choice consumer flow and per-device selection semantics |
| Android package identity | Must preserve | Keep `space.pokrov.vpn` continuity |
| Release artifact names | Must preserve | Keep the current `pokrov-*` Android and Windows artifact canon |

## Deferred Internal Debt

| Area | Status | Notes |
| --- | --- | --- |
| `name: hiddify` | Deferred | Internal upstream identifier, not public product truth |
| `package:hiddify/...` imports | Deferred | Keep out of public-facing claims unless and until migrated |
| Android namespace and Kotlin tree | Deferred | `com.hiddify.hiddify` remains internal refactor debt unless it blocks public surfaces |
| MSIX publisher residue | Deferred unless required | Clean in this wave only if MSIX or Store publication is explicitly in scope |
| Non-public Hiddify history files | Deferred | Do not treat supporting history cleanup as release closure by itself |

## Worker 10 Ownership

Worker 10 owns these client-lane outputs in the intake worktree:

- `docs/**`
- `CHANGELOG.md`
- final generated outputs for the client intake lane
- final packaged artifacts for the client intake lane

Current rule:

- do not claim final closure yet
- do not regenerate final artifacts before the code lanes stabilize
- do not revert other workers' edits or clean up outputs that are still in active use

## Final Regen And Validation Still Reserved

The final Worker 10 pass still needs the settled client tree before it can own:

- regenerated docs snapshots tied to the final code state
- final packaged Windows outputs
- final generated client outputs needed by the rebased release flow
- final validation evidence for the intake branch
