# POKROV VPN

`POKROV VPN` کلاینت Flutter این مخزن برای `Android + Windows` است.

مستندات اصلی:

- [docs/README.md](docs/README.md)
- [docs/product/portal-vpn-v1-spec.md](docs/product/portal-vpn-v1-spec.md)
- [docs/architecture/app-first-session-flow.md](docs/architecture/app-first-session-flow.md)

نکات اصلی:

- برند: `POKROV VPN`
- شروع کار: app-first
- دوره آزمایشی: `5 روز`
- پاداش تلگرام: `+10 روز`
- کانال رسمی: `@pokrov_vpn`
- ربات اصلی: `@pokrov_vpnbot`

دستورهای بررسی:

```powershell
flutter test test/features/portal
flutter build windows --release
flutter build apk --release
flutter build appbundle --release
```

سیاست انتشار و امضا: [../../docs/operations/publishing-and-signing-guide.md](../../docs/operations/publishing-and-signing-guide.md).
