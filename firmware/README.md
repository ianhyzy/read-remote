# Read Remote firmware (ZMK)

ZMK config for the Seeed XIAO nRF52840 in the [case](../case/). Two direct-wired buttons, no matrix.

| key | wire | default |
|---|---|---|
| NEXT (big dished cap) | D0 ↔ GND | Page Down |
| PREV (small domed cap) | D1 ↔ GND | Page Up; **hold 5 s = power off** |

KOReader turns pages on Page Down / Page Up out of the box. Most other reader apps do too.

## Get the firmware
GitHub Actions builds it on every push to `firmware/`. Open the latest run under **Actions**, download the `read_remote` artifact, unzip to get `read_remote-seeeduino_xiao_ble-zmk.uf2`.

## Flash
1. Plug in USB-C. Double-press the reset button through the pinhole; a `XIAO-SENSE` drive appears.
2. Drag the `.uf2` onto it. The drive ejects itself and the remote reboots.

Pairings misbehaving? Flash the `settings_reset` artifact the same way, then flash `read_remote` again. That wipes all bonds.

## Pair
On the e-reader, Bluetooth settings → pair **Read Remote**. ZMK keeps up to 5 bonds; it reconnects to the last one.

## Power
- Deep sleep after 30 min idle (`CONFIG_ZMK_IDLE_SLEEP_TIMEOUT`); any press wakes it, first press may be swallowed.
- Hold PREV 5 s: full power off. Press either button to wake.
- Battery level appears in the host's Bluetooth device details.

## Change the keymap
- **ZMK Studio** (no rebuild): plug in USB-C, open https://zmk.studio in Chrome, pick the device. Studio is enabled in `build.yaml`.
- Or edit `config/read_remote.keymap` and push; Actions rebuilds.

## Files
- `build.yaml` — which images to build (`read_remote` + `settings_reset`).
- `config/read_remote.keymap`, `config/read_remote.conf` — keymap and settings.
- `config/boards/shields/read_remote/` — the shield: pins, physical layout, metadata.
- `config/west.yml` — pulls ZMK `main`.
