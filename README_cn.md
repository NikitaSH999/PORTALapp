# POKROV VPN

`POKROV VPN` 是此仓库中的 `Android + Windows` Flutter 客户端。

规范文档：

- [docs/README.md](docs/README.md)
- [docs/product/portal-vpn-v1-spec.md](docs/product/portal-vpn-v1-spec.md)
- [docs/architecture/app-first-session-flow.md](docs/architecture/app-first-session-flow.md)

关键信息：

- 品牌：`POKROV VPN`
- 首次体验：app-first
- 试用期：`5 天`
- Telegram 奖励：`+10 天`
- 官方频道：`@pokrov_vpn`
- 主机器人：`@pokrov_vpnbot`

常用验证：

```powershell
flutter test test/features/portal
flutter build windows --release
flutter build apk --release
flutter build appbundle --release
```

发布与签名策略见 [../../docs/operations/publishing-and-signing-guide.md](../../docs/operations/publishing-and-signing-guide.md)。
