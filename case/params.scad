// ======================= page-turner-case params =======================
// All mm. Nominal values — MEASURE the real parts with calipers and update.

// ---- XIAO nRF52840 (standard) ----
xiao        = [17.8, 21.0, 1.0];   // PCB width (X), length (Y, USB edge first), PCB thickness
xiao_comp_h = 3.3;                 // tallest top-side part (USB-C shell) above PCB top
usb         = [9.0, 3.3];          // USB-C shell width, height (sits on PCB top)
usb_len     = 7.3;                 // USB-C shell length along the PCB
usb_overhang = 1.0;                // how far the shell nose sticks past the PCB edge (measure)
usb_plug    = [12.5, 7.0];         // cable overmold clearance (W x H): the plug body enters the case ~3.5 mm before the shell seats
usb_flare   = 1.2;                 // 45deg lead-in on the outer face, each side
pcb_setback = 3.3;                 // PCB USB edge to inner end wall (clears the r10 cavity corners; plug reaches through)
reset_pos   = [4.5, 2.5];          // reset button: X from PCB centre, Y from USB edge (MEASURE)
reset_hole_d = 2.0;                // pinhole diameter in lid
led_pos     = [-4.5, 5.0];         // charge/status LED: X from PCB centre, Y from USB edge (MEASURE; 0 dia to omit)
led_hole_d  = 1.5;                 // light-pipe hole in the lid above it
antenna_keepout = 3.0;             // empty zone past the PCB's far (antenna) edge (informational; see DESIGNS.md)
pad_free_end = 2.0;                // bare PCB at the antenna-end corners where the lid pillars land (no castellations there)

// ---- Battery 402025 w/ PCM (lies on the floor under the switch tray) ----
batt        = [20.0, 25.0, 4.5];   // width, length, thickness incl. PCM hump (MEASURE)
batt_fit    = 0.3;                 // per side, inside the ledge ring
batt_gap    = 0.5;                 // battery top to tray underside
lead_gap    = 1.0;                 // battery start past the PCB end stops (lead bend room)

// ---- 6x6x5 silent tactile switch, 2-pin SMD, legs on opposite sides ----
sw_body     = 6.0;                 // body square
sw_h        = 5.0;                 // tray-to-dome-apex height, unpressed (MEASURE to 0.05 — travel is only 0.25)
sw_dome_d   = 3.5;                 // silicone dome dia (cosmetic)

// ---- Clearances (tune for your printer) ----
fit         = 0.25;   // cap vs lid window, per side
pocket_fit  = 0.15;   // switch in tray pocket, PCB vs stops
tray_fit    = 0.15;   // tray outline vs cavity, per side
lid_fit     = 0.20;   // lid lip vs base inner wall, per side
preload     = -0.1;   // -0.1 = caps float 0.1 mm above the dome at rest (safe); +0.1 = dome pre-compressed (never exceed +0.1)

// ---- Case ----
wall        = 1.6;
floor_t     = 1.6;
lid_t       = 3.0;
r_plan_usb  = 10.0;   // plan corner radius, USB end
r_plan_far  = 10.0;   // plan corner radius, button end
r_top       = 2.5;    // lid top-edge fillet (<= lid_t)
r_bot       = 3.0;    // base bottom-edge fillet; both get a 45deg blend at the bed so they print clean
side_gap    = 2.3;    // min wire space beside the PCB (each side); width is the larger of this and the battery ring
rail_h      = 2.0;    // PCB sits on two rails this high (room for underside solder + kapton)
stop_t      = 1.2;    // PCB end-stop thickness (Y)
ledge_w     = 1.0;    // ring ledge the tray rests on, around the battery
tray_t      = 1.2;    // switch tray plate
pocket_wall = 1.0;    // switch pocket wall thickness
pocket_wall_h = 2.0;  // pocket wall height above the tray
lip_h       = 2.5;    // lid locating lip depth
lip_t       = 1.2;
finger_h    = 5.5;    // snap fingers hang this far below the lid (longer = softer)
finger_t    = 1.0;
finger_len  = 11.0;
relief_w    = 0.8;    // slot each side of a finger
snap_bump   = 0.3;    // finger bump protrusion
snap_len    = 5.0;
pry_notch   = [6, 1.2];  // fingernail slot in the base rim at the far end: width, depth
lanyard_d   = 2.2;    // hole through the far end wall, centred (0 = none)
lanyard_z   = 2.5;    // above the inner floor (under the tray, in the empty end zone)

// ---- Power cutoff: SS12D00G3 slide switch in the battery + lead, side wall, USB half ----
psw         = [8.6, 3.6, 3.5];     // body: length along the slide (Y), depth along the handle (X), height (Z)  (MEASURE)
psw_handle  = [2.0, 1.5, 3.0];     // handle: along the slide, across, length past the body (G3 = 3.0)
psw_travel  = 2.0;                 // slide throw (SS12D00: 2 +/- 0.3)
psw_y       = 12.0;                // travel centre from the inner USB wall (stay in the USB half, away from the antenna)
psw_side    = 1;                   // +1 right wall, -1 left wall (looking from the USB end, buttons up)
psw_lift    = 2.0;                 // body bottom above the PCB top (room for the GND wire and solder underneath)
psw_fit     = 0.15;                // body in its pocket, per side
knob        = [6.0, 4.0, 1.5];     // tile: along the slide, tall, corner radius; thickness = wall (flush)
knob_flange = 1.0;                 // inner flange thickness (sits between the wall and the switch body)
knob_fit    = 0.15;                // tile vs window, per side
knob_pocket_fit = 0.1;             // handle pocket, per side (press fit)
knob_groove = [0.6, 0.3];          // fingernail groove across the tile: width, depth
// ---- Magnets (optional, in the base floor under the PCB, printed in place: pause at the roof layer, drop them in) ----
magnet      = [0, 0];               // dia, thickness (0 dia = none). Two N52 6x1.5 discs, same pole up
magnet_pos  = [[-4.5, 17.5], [4.5, 17.5]];   // X from centre, Y from PCB USB edge: under the PCB's antenna half, clear of pads
magnet_fit  = 0.15;                // radial; pocket is magnet thickness + 0.2 tall

// ---- Buttons (layout chosen by `variant` in page_turner.scad) ----
cap_shift   = 2.5;          // slide both caps this far toward the palm (USB end); 0 = caps at the far end
lid_frame   = 1.0;          // lid material between a cap window and the lip
cap_gap     = 3.0;          // lid bar between caps
cap_recess  = 1.0;          // flat cap top sits this far below the lid surface (PREV dome apex ends up 0.2 below it)
cap_r       = 1.5;          // cap corner radius (default)
next_r      = 5.5;          // kobo NEXT cap corner radius (a 16.6 mm rounded square)
win_chamfer = 0.4;          // 45deg chamfer on the lid window top edges
flange_lip  = 1.0;          // under-lid retaining flange, each side
flange_t    = 1.0;
dish_depth  = 0.7;          // concave "dish" cap: depth at centre
dome_h      = 0.8;          // convex "dome" cap: rise at centre (peaks dome_h - cap_recess above the lid)
dot         = [4.0, 2.5, 0.7];   // "dot" cap: bump base dia, top dia, height
