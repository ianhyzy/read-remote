# page-turner-case

3D-printable case for a two-button ZMK page-turner remote: Seeed XIAO nRF52840 + 402025 LiPo + two 6×6×5 silent tactile switches. Hand-wired, no PCB. Everything drops in from the top; no glue.

Outer size with nominal parts: **26 × 69 × 17 mm** at the button half; the palm half is 3 mm lower and 1.35 mm narrower so the travel hood parks on it flush. Pebble-shaped (r10 ends, rounded edges). The default layout is `kobo` (big dished NEXT at the far end, small domed PREV below it). Five other layouts are built in (`variant` in `page_turner.scad`); see [DESIGNS.md](DESIGNS.md).

![layout](renders/kobo/layout.png) ![section](renders/kobo/section.png)

## Printed parts (7, plus a 3-piece fit coupon)
| part | what | print orientation |
|---|---|---|
| `base` | shell with PCB rails, battery bay, tray ledge; palm half lower and inset | as exported, open side up |
| `lid_front` | button-half lid: cap windows, 2 snap fingers | exported **top-face down** |
| `lid_back` | palm-half lid, 3 mm lower: reset/LED pinholes, PCB hold-down pillars, 2 snap fingers | exported **top-face down** |
| `tray` | drop-in plate carrying both switches | as exported, pockets up |
| `cover` | the hood: over the buttons for travel, parked backwards on the palm half while reading | as exported, outer face up, skirt on the bed (the plate bridges between the skirt walls) |
| `plunger_next` | big dished cap | as exported, cap up |
| `plunger_prev` | small domed cap | as exported, cap up |
| `coupon_base/lid/tray` | the button end only, for fit testing | same as the full parts |

**Print the coupon first** with both caps and real switches. It tests `fit`, `snap_bump`, `pocket_fit`, `tray_fit` and the cap stack height in a fraction of the time of the full set.

## Files
- `params.scad` — every dimension and clearance. Edit this, not the model.
- `page_turner.scad` — the model. `part=` selects what to render, `variant=` the button layout.
- `DESIGNS.md` — market research and the button-layout options.
- `render.sh <variant>` — exports `stl/<variant>/*.stl` and `renders/<variant>/*.png` (needs `openscad` on PATH; `brew install --cask openscad@snapshot`).

## Before printing: measure the real parts
Nominal values in `params.scad` are from datasheets. Caliper these and update:

| param | what to measure | nominal |
|---|---|---|
| `xiao` | PCB width × length × thickness | 17.8 × 21.0 × 1.0 |
| `xiao_comp_h` | PCB top to top of USB-C shell | 3.3 |
| `usb_overhang` | how far the USB-C shell nose sticks past the PCB edge | 1.0 |
| `reset_pos` | reset button centre: X from PCB centreline, Y from the USB edge | 4.5, 2.5 |
| `led_pos` | charge/status LED centre, same frame (1.5 mm light-pipe hole in the lid) | -4.5, 5.0 |
| `usb_plug` | your chunkiest cable's plug body W × H, plus 1 mm | 12.5 × 7.0 |
| `batt` | battery width × length × thickness, **including PCM hump and tape** | 20 × 25 × 4.5 |
| `sw_h` | switch: base to top of silicone dome, unpressed, **to 0.05 mm** | 5.0 |
| `sw_body` | switch body square | 6.0 |

`sw_h` matters most: the switch has 0.25 mm of travel, so the cap stack is built to ±0.1 mm. `preload` defaults to -0.1 (caps float 0.1 mm at rest, a faint tick if shaken, never pre-actuated). Only go positive if the caps rattle, and never above +0.1.

The model asserts that the PCB corners clear the rounded USB-end cavity and that the battery fits in its bay; if an assert fires it names the parameter to change.

## Hood
A half-length shell (3 mm plate, 1.2 mm skirt) with a 0.3 mm rib inside the skirt that snaps into a groove in the base wall. Two positions:
- **Travel**: over the button half. Both buttons covered. Its open end butts against the step in the lid.
- **Reading**: turned around and parked on the palm half, which is exactly one hood lower and one skirt narrower, so the top and sides come out flush and the bottom stays flat. Pinholes line up with reset and LED; a notch in the end skirt keeps USB usable.

Too tight or loose: `cov_fit`, `cov_rib`. The palm-half drop is `cov_t`; the neck inset follows `cov_skirt_t + cov_fit` automatically.

## Printing (Bambu P1S)
- PLA, 0.4 nozzle, **0.10 mm layers** (so the switch shelf and lid heights land on layer boundaries), 3 walls, no supports.
- Lid on the **smooth or cool plate**: it prints top-face down, and a textured plate would texture the top. Caps print top-up with **ironing** on for glossy tops.
- Rounded bottom (base) and top (lid) edges start with a 45° blend at the bed; expect a faint facet line ~1 mm up.
- All parts fit one plate.

## Fit tuning
| symptom | change |
|---|---|
| cap binds in lid window | `fit` 0.25 → 0.35 |
| cap rattles / sits low | `preload` -0.1 → 0 (max +0.1) |
| cap pre-pressed, button always on | `preload` → -0.2, re-measure `sw_h` |
| lid won't snap / too tight | `snap_bump` 0.3 → 0.2, or `finger_h` 5.5 → 7 (softer) |
| lid loose | `snap_bump` 0.3 → 0.4 |
| switch loose in tray pocket | `pocket_fit` 0.15 → 0.1 |
| tray rocks | `tray_fit` 0.15 → 0.1 |
| USB plug body doesn't fit | `usb_plug`, `usb_flare` |
| want deeper button recess | `cap_recess` 0.5 → 1.0 |
| dish too shallow / dome too subtle | `dish_depth`, `dome_h` |
| buttons too far from the palm / too close | `cap_shift` (default 2.5 toward the USB end; 0 puts them at the far end) |
| different layout | `variant`, or edit the `caps0` table |
| wider / rounder shell | `side_gap`, `r_plan_far`, `r_top`, `r_bot` |

## Assembly
Wire: NEXT switch → **D0** and **GND**, PREV switch → **D1** and **GND**. Use the pads at the USB end of the XIAO (D0, D1 left; GND right); the lid pillars land on the bare antenna-end corners, so leave those pads empty.

1. **Switches on the tray.** Drop each switch into its tray pocket (legs facing the open sides). Solder a ~40 mm 28 AWG wire to each leg right there; the tray is the fixture. Route the wires off the tray's front edge.
2. **Battery.** Solder its leads to BAT+ / BAT− on the XIAO's underside, Kapton over the joints. Lay the battery in the bay (the ring at the far end), lead end toward the PCB.
3. **PCB.** Set the XIAO on the two rails, component side up, USB-C toward the end opening. It is captured in Y between the rounded cavity corners and the end stops; nothing else to do.
4. **Tray.** Lower the tray onto the ledge ring; its front edge rests on the PCB end stops. Solder the switch wires to D0 / D1 / GND. The gap above the PCB is 9 mm, so there is plenty of room.
5. **Caps and lids.** Put `lid_front` face-down on the bench, drop the caps into their windows (flange up). Turn the loaded base over onto it (the tray and switches have only a few tenths of play) and press until its two fingers click. Flip over and press `lid_back` onto the palm half until its fingers click; its pillars land on the PCB.
6. **Open** with a fingernail in the notch at the far end. Thread a lanyard through the hole in the far wall and knot it inside.

Reset: paperclip into the pinhole above the USB end. Double-press for the UF2 bootloader. The second small hole next to it shows the charge/status LED.

## Design notes
- **Captured caps.** Each cap rests on its switch dome and is retained by a 1 mm flange under the lid. Travel stops on the switch; the cap sits 0.5 mm below the lid in a window with 0.25 mm clearance and a 0.4 mm chamfered edge, so plastic never meets plastic.
- **Battery away from the antenna.** The pouch (foil) sits under the switch tray, 3 mm past the board end and 2 mm below the antenna plane, instead of directly under the chip antenna.
- **PCB held three ways without glue.** Rails below; rounded cavity corners (front) and end stops (back) take plug insertion/removal loads; three lid pillars (two on bare PCB corners, one on the USB shell) stop it lifting.
- **Snap fingers.** Four 1 mm × 5.5 mm fingers on the lid lip with relief slots, 0.3 mm bumps into wall grooves: ~1.5–2 % strain, inside PLA's elastic range. The continuous lip only locates.
- **USB opening** is sized for the cable's plug body (the receptacle sits 3.3 mm behind the wall) with a 45° lead-in; it sits entirely in the base, below the lid seam.
