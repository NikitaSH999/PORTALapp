# PORTAL VPN Implementation Backlog

Last updated: 2026-03-19

## Phase 1: Product foundation

- Replace `PORTALapp` naming with final `PORTAL VPN`
- Add final logo assets based on `logogo.png`
- Define Android and Windows branding output map
- Remove or hide remaining visible `Hiddify` strings

## Phase 2: App-first trial

- Done: introduce app session client contracts
- Done: persist `install_id`
- Done: collect soft device context from app runtime
- Done: implement `Try free` action on the empty home screen
- Done: silently import returned subscription
- Done: activate the working profile automatically
- Next: replace demo portal payloads with final backend contract
- Next: persist and refresh runtime app auth beyond initial trial bootstrap

## Phase 3: Quick Connect UX

- Redesign home screen around one primary action
- Add auto-select location card
- Add trial and subscription state card
- Add Telegram reward CTA

## Phase 4: Consumer navigation

- Add `Locations` flow
- Replace fake device screen with real device management
- Rebuild `Profile` around plan, rewards, and bindings
- Rebuild `Support` around in-app messaging

## Phase 5: Advanced split

- Move technical toggles out of first-layer screens
- Create `Advanced` section with warning copy
- Keep sing-box defaults hidden unless the user opts in

## Phase 6: Release cleanup

- Replace launcher icons
- Replace splash and tray icons
- Update packaging assets
- Rebuild Android release
- Rebuild Windows package
