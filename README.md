# read-remote

A silent two-button Bluetooth page turner for e-readers (KOReader on Android), built around a Seeed XIAO nRF52840 running ZMK.

- [`case/`](case/) — 3D-printable pebble case (OpenSCAD, STLs, renders, assembly guide).
- [`config/`](config/) + [`build.yaml`](build.yaml) — ZMK firmware config; GitHub Actions builds the `.uf2`. See [FIRMWARE.md](FIRMWARE.md).

![case](case/renders/kobo/iso.png)

## v2 ideas (parked)
- **Find-me beeper.** 12 mm piezo disc glued to the inside of the floor under the PCB (fits in the 2 mm under the rails), wired to D2/D3, driven by a small ZMK module exposing the BLE Immediate Alert Service (Zephyr `CONFIG_BT_IAS`); trigger with nRF Connect or a one-button app. Only works while connected, so it needs a much longer idle-sleep timeout than the current 30 min. Same beeper could chirp on power-on, lock toggle and low battery.
