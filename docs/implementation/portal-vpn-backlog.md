# POKROV VPN Implementation Backlog

Last updated: 2026-04-15

## Current Status

This backlog now tracks the upstream intake wave on top of `fbc6cbd4ed6a978e5923c8203a93080019a7777b`.

The docs lane is active, but this branch is not in final closure state. Product contracts below reflect confirmed preserve requirements and intake-baseline facts only.

## Confirmed Intake Decisions

- strategy is a fresh patch stack, not an in-place rebase of the old branch
- the wave accepts the current upstream toolchain and core layout
- behavior must be preserved even where commit history is discarded
- docs must stay truthful about what is confirmed, deferred, or still blocked

## Open Client Lanes

### Portal contract lane

- reapply app-first provisioning against `GET /api/client/profile/managed`
- preserve route-policy round-trip through backend-owned fields
- preserve support, Telegram link, reward, and checkout continuity

### Routing and deep-link lane

- reapply the two-choice route-mode onboarding on the modern upstream shell
- preserve `All except RU` and `Full tunnel` as the only public routing presets
- preserve `pokrov://` with `pokrovvpn://` hidden compatibility

### Android and Windows platform lanes

- reapply public POKROV branding on Android and Windows release surfaces
- preserve Android package identity and Windows artifact naming
- keep Windows packaging guardrails and Android local-surface release gates in place

### Client CI and release lane

- reconcile workflow assumptions with the upstream toolchain and `hiddify-core`
- keep release wrappers and artifact expectations aligned with the rebased tree

### Docs and closure lane

- keep client docs aligned only to confirmed facts
- maintain cleanup and deferred-debt tracking
- own final generated outputs and packaged artifacts after code lanes settle
- avoid any closure claim until the final gate suite and packaging evidence exist

## Closure Blockers Still Open

- final client integration on the intake branch
- final `run_client_release_gate.py` validation on the rebased tree
- final Windows packaging validation
- final Android physical-device localhost audit
- CI rehearsal for the release workflow
- mixed-lane closure evidence across both client and root lanes
