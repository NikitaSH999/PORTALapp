# POKROV VPN

`POKROV VPN` は、このリポジトリで管理している `Android + Windows` 向け Flutter クライアントです。

正規ドキュメント:

- [docs/README.md](docs/README.md)
- [docs/product/portal-vpn-v1-spec.md](docs/product/portal-vpn-v1-spec.md)
- [docs/architecture/app-first-session-flow.md](docs/architecture/app-first-session-flow.md)

主要事項:

- ブランド: `POKROV VPN`
- 初回導線: app-first
- トライアル: `5日`
- Telegram ボーナス: `+10日`
- 公式チャンネル: `@pokrov_vpn`
- メインボット: `@pokrov_vpnbot`

主な確認コマンド:

```powershell
flutter test test/features/portal
flutter build windows --release
flutter build apk --release
flutter build appbundle --release
```

公開と署名の方針: [../../docs/operations/publishing-and-signing-guide.md](../../docs/operations/publishing-and-signing-guide.md)。
