// ======================= page-turner-case params =======================
// All mm. Nominal values — MEASURE the real parts with calipers and update.

// ---- XIAO nRF52840 (standard) ----
xiao        = [17.8, 21.0, 1.0];   // PCB width (X), length (Y, USB edge at y=0), PCB thickness
xiao_comp_h = 3.3;                 // tallest top-side part (USB-C shell) above PCB top
usb         = [9.0, 3.3];          // USB-C shell width, height (sits on PCB top)
usb_overhang = 1.0;                // how far the shell nose sticks past the PCB edge (measure)
usb_slop    = 1.2;                 // extra width/height on the USB notch for cable plugs
reset_pos   = [4.5, 2.5];          // reset button: X from PCB centre, Y from USB edge (MEASURE)
reset_hole_d = 1.6;                // pinhole diameter in lid
antenna_keepout = 3.0;             // empty zone past the PCB's far (antenna) edge

// ---- Battery 402025 w/ PCM ----
batt        = [20.0, 25.0, 4.5];   // width, length, thickness incl. PCM hump (MEASURE)
lead_gap    = 2.0;                 // space at USB end of battery pocket for lead bend
batt_gap    = 0.8;                 // kapton + solder bumps on the underside pads, between battery top and PCB

// ---- 6x6x5 silent tactile switch, 2-pin SMD ----
sw_body     = 6.0;                 // body square
sw_h        = 5.0;                 // floor-to-dome-apex height, unpressed (MEASURE)
sw_leg_w    = 2.0;                 // slot width for the two side legs
sw_leg_h    = 1.5;                 // slot height
sw_dome_d   = 3.5;                 // silicone dome dia (cosmetic)

// ---- Clearances (tune for your printer) ----
fit         = 0.25;   // plunger stem vs lid hole, per side
pocket_fit  = 0.15;   // part pockets, per side
lid_fit     = 0.20;   // lid lip vs base inner wall, per side
preload     = 0.0;    // raise switch shelf to take up plunger slack (0.1 if caps rattle)

// ---- Case ----
wall        = 1.6;
floor_t     = 1.6;
lid_t       = 2.0;
corner_r    = 3.0;
top_gap     = 0.3;    // USB shell top to lid underside
side_gap    = 1.5;    // min wire space beside the PCB (each side)
rail_w      = 0.8;    // PCB support rails along the long walls
pocket_wall = 1.0;    // switch pocket wall thickness
pocket_wall_h = 2.0;  // how far pocket walls rise above the switch shelf
lip_h       = 2.5;    // lid lip depth into base
lip_t       = 1.2;
snap_bump   = 0.4;    // lip bump protrusion
snap_len    = 5.0;
snap_z      = 1.4;    // bump centre below lid underside
pry_notch   = [8, 1.2];  // fingernail slot at the far end: width, depth

// ---- Buttons (layout chosen by `variant` in page_turner.scad) ----
lid_frame   = 1.0;          // lid material between a cap window and the lip
cap_gap     = 3.0;          // lid bar between caps
cap_recess  = 0.5;          // flat cap top sits this far below the lid surface
cap_r       = 1.5;          // cap corner radius
flange_lip  = 1.0;          // under-lid retaining flange, each side
flange_t    = 1.0;
dish_depth  = 0.7;          // concave "dish" cap: depth at centre
dome_h      = 0.8;          // convex "dome" cap: rise at centre (peaks dome_h - cap_recess above the lid)
dot         = [4.0, 2.5, 0.7];   // "dot" cap: bump base dia, top dia, height
end_cap     = [8.0, 5.0, 1.2];   // trigger variant end button: width, height, protrusion past the wall
lanyard_d   = 2.2;          // hole through the far end wall (0 = none)
