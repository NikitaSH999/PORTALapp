# POKROV VPN

`POKROV VPN` — Flutter-клиент этого репозитория для `Android + Windows`.

Канонические документы:

- [docs/README.md](docs/README.md)
- [docs/product/portal-vpn-v1-spec.md](docs/product/portal-vpn-v1-spec.md)
- [docs/architecture/app-first-session-flow.md](docs/architecture/app-first-session-flow.md)

Ключевые факты:

- бренд: `POKROV VPN`
- первый сценарий: app-first
- триал: `5 дней`
- бонус Telegram: `+10 дней`
- публичный канал: `@pokrov_vpn`
- основной бот: `@pokrov_vpnbot`

Быстрая проверка:

```powershell
flutter test test/features/portal
flutter build windows --release
flutter build apk --release
flutter build appbundle --release
```

Правила публикации и подписания: [../../docs/operations/publishing-and-signing-guide.md](../../docs/operations/publishing-and-signing-guide.md).
