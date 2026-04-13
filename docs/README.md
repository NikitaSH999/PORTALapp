# POKROV VPN Client Docs

Last updated: 2026-04-12

This folder contains living client-fork-specific documentation for `POKROV VPN`.

Legacy filename note:

- some client docs still use legacy filenames such as `portal-vpn-v1-spec.md` and `portal-vpn-backlog.md`
- those files are still current for the `POKROV VPN` client fork until a separate rename pass happens

For platform-wide truth, start at the root docs index:

- [Root Docs Index](C:/Users/kiwun/Documents/ai/VPN/docs/README.md)
- [Root Product Overview](C:/Users/kiwun/Documents/ai/VPN/docs/product/portal-vpn-product.md)
- [Root Architecture Overview](C:/Users/kiwun/Documents/ai/VPN/docs/architecture/system-overview.md)
- [Publishing And Signing Guide](C:/Users/kiwun/Documents/ai/VPN/docs/operations/publishing-and-signing-guide.md)

## Client Source Of Truth

### Product

- [POKROV VPN v1 Product Spec](C:/Users/kiwun/Documents/ai/VPN/external/client-fork/app/docs/product/portal-vpn-v1-spec.md)

### Architecture

- [App-First Session Flow](C:/Users/kiwun/Documents/ai/VPN/external/client-fork/app/docs/architecture/app-first-session-flow.md)

### Forking And Cleanup

- [Fork Cleanup Tracker](C:/Users/kiwun/Documents/ai/VPN/external/client-fork/app/docs/fork/fork-cleanup-tracker.md)

### Implementation

- [POKROV VPN Implementation Backlog](C:/Users/kiwun/Documents/ai/VPN/external/client-fork/app/docs/implementation/portal-vpn-backlog.md)

## Alignment Rules

- Client docs must stay aligned with the platform canon on brand, account model, trial length, Telegram reward, and support entrypoints.
- Client docs must treat `Android + Windows` as the full public `v1` scope.
- Client docs must treat `iOS` and `macOS` as readiness-only in this release wave unless a later canonical doc changes that status.
- If a client doc conflicts with root canonical docs, update the client doc or explicitly mark the difference as planned work.
- Client docs must not claim Android public-release readiness until release-build localhost/control-surface checks are complete.
- Client docs must not present RU-aware routing as fully shipped until the routing strategy layer, DNS split rules, and leak checks are actually verified.
- Client docs must describe only the currently shipped routing modes `Global` and `Все, кроме РФ`; keep `Только заблокированное` as planned work until it exists in code and passes release verification.
- Client docs must distinguish current public download targets from release/store artifacts: app surfaces currently expose Android `Play` / `APK` / mirror and Windows `EXE` / mirror, while `AAB`, `MSIX`, and portable `ZIP` stay operator/store artifacts.
