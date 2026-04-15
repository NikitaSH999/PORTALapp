# POKROV

`POKROV` is the consumer `Android + Windows` Flutter client used in this repository.

Canonical documentation lives in:

- [docs/README.md](docs/README.md)
- [docs/product/portal-vpn-v1-spec.md](docs/product/portal-vpn-v1-spec.md)
- [docs/architecture/app-first-session-flow.md](docs/architecture/app-first-session-flow.md)

Key release facts:

- brand: `POKROV`
- public beta line: `0.9.0-beta`
- onboarding: app-first
- trial: `5 days`
- Telegram reward: `+10 days`
- support bot: `@pokrov_supportbot`
- feedback bot: `@pokrov_feedbackbot`
- official public channel: `@pokrov_vpn`
- main bot: `@pokrov_vpnbot`
- `swazist_bot` and `portal_service_bot` are officially disabled legacy usernames

Focused verification from this workspace:

```powershell
flutter test test/features/portal
flutter build windows --release
flutter build apk --release
flutter build appbundle --release
```

Public release and signing policy is documented in [../../docs/operations/publishing-and-signing-guide.md](../../docs/operations/publishing-and-signing-guide.md).
