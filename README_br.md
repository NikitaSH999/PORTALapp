# POKROV VPN

`POKROV VPN` é o cliente Flutter para `Android + Windows` mantido neste repositório.

Documentação canônica:

- [docs/README.md](docs/README.md)
- [docs/product/portal-vpn-v1-spec.md](docs/product/portal-vpn-v1-spec.md)
- [docs/architecture/app-first-session-flow.md](docs/architecture/app-first-session-flow.md)

Fatos principais:

- marca: `POKROV VPN`
- fluxo inicial: app-first
- teste grátis: `5 dias`
- bônus do Telegram: `+10 dias`
- canal público: `@pokrov_vpn`
- bot principal: `@pokrov_vpnbot`

Verificação focada:

```powershell
flutter test test/features/portal
flutter build windows --release
flutter build apk --release
flutter build appbundle --release
```

Política de publicação e assinatura: [../../docs/operations/publishing-and-signing-guide.md](../../docs/operations/publishing-and-signing-guide.md).
