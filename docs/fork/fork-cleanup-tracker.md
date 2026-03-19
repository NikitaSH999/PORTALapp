# Fork Cleanup Tracker

Last updated: 2026-03-18

## Goal

Track all remaining Hiddify references and incomplete brand migration work for `PORTAL VPN`.

## Branding

| Area | Status | Notes |
|---|---|---|
| App display name | In progress | `PORTALapp` exists in several places, final product name must be `PORTAL VPN` |
| Launcher icon | Pending | Must switch to final logo assets |
| Splash assets | Pending | Must use final PORTAL VPN branding |
| Tray icons | Pending | Still based on inherited asset pipeline |
| App update metadata | In progress | Constants and packaging partially changed |
| README and docs branding | Pending | Multiple Hiddify references remain |

## Remaining visible Hiddify references

| Area | Status | Notes |
|---|---|---|
| `README_*.md` | Pending | Still reference `hiddify-next` |
| `CHANGELOG.md` and `HISTORY.md` | Pending | Historical naming still visible |
| Binary names such as `HiddifyCli.exe` | Pending | Decide whether to rename binary or hide it inside packaging |
| Advanced labels and old settings wording | Pending | Must be rewritten for consumer UX |

## UX cleanup

| Area | Status | Notes |
|---|---|---|
| Trial shown without working profile | Must fix | Current portal demo state is not a real trial flow |
| Fake demo nodes | Must fix | Netherlands / Poland placeholders must be replaced with real data |
| In-app support using demo copy | Must fix | Needs real support backend integration |
| Russian copy polish | Must fix | User-facing Russian should be rewritten and simplified |
| First-layer Hiddify power-user settings | Must fix | Move to `Advanced` |

## Product decisions already locked

- Product name: `PORTAL VPN`
- Trial: `5 days`
- Telegram reward: `+10 days`
- Product direction: `consumer-first`
- Identity direction: `app-first`
- Default core: `sing-box`
- `xray` only in advanced compatibility mode

## Immediate implementation priorities

1. Replace decorative trial with real app-first trial provisioning.
2. Build `Quick Connect` home flow.
3. Replace fake location and device data with backend data.
4. Move power-user settings into `Advanced`.
5. Replace remaining visual and textual Hiddify branding.
6. Integrate real in-app support payloads.
7. Finalize Android and Windows asset branding using the real logo.

