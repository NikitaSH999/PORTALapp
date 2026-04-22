# POKROV Client Docs

Last updated: 2026-04-15

This directory is the living client-docs baseline for the upstream intake branch pinned to `fbc6cbd4ed6a978e5923c8203a93080019a7777b` from `2026-04-02`.

These docs record only facts already confirmed by intake-repo code, root canonical docs, or baseline evidence captured for the mixed-lane wave. They do not claim that the POKROV overlay is fully re-applied in this worktree yet.

Legacy filename note:

- some client docs still use legacy filenames such as `portal-vpn-v1-spec.md`
- those filenames remain valid during this intake wave and do not authorize new public-facing `VPN` copy

## Source Of Truth

Platform canon still lives in the root repository docs:

- `C:/Users/kiwun/Documents/ai/VPN/docs/README.md`
- `C:/Users/kiwun/Documents/ai/VPN/docs/product/portal-vpn-product.md`
- `C:/Users/kiwun/Documents/ai/VPN/docs/architecture/system-overview.md`
- `C:/Users/kiwun/Documents/ai/VPN/docs/architecture/app-first-and-bonus-flows.md`
- `C:/Users/kiwun/Documents/ai/VPN/docs/operations/publishing-and-signing-guide.md`

Client-lane canon for this intake branch lives here:

- `docs/product/portal-vpn-v1-spec.md`
- `docs/architecture/app-first-session-flow.md`
- `docs/fork/fork-cleanup-tracker.md`
- `docs/implementation/portal-vpn-backlog.md`

## Confirmed Intake Baseline

- the intake branch is a fresh patch stack on top of upstream commit `fbc6cbd4ed6a978e5923c8203a93080019a7777b`
- upstream intake code already moved to Flutter `3.38.5`, Dart `3.10.4`, and `hiddify-core`
- `dependencies.properties` currently pins `core.version=4.1.0`
- internal upstream identifiers such as `name: hiddify` and version `4.1.2+40102` are intake realities, not public POKROV product truth
- Worker 10 owns `docs/**`, `CHANGELOG.md`, and final generated/artifact outputs in this intake lane only

## Guardrails

- document preserved POKROV behavior, not old commit history
- document only what is confirmed by code or captured baseline evidence
- keep deferred debt explicit instead of silently rewriting it away
- do not claim final closure, artifact readiness, or public release readiness from this branch yet
- Android public release remains blocked until the wrapper gates, physical-device localhost audit, and final handoff evidence are complete
