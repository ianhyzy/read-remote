// page-turner-case: XIAO nRF52840 + 402025 LiPo + 2 silent tactile switches
include <params.scad>

part = "assembly"; // base | lid | plunger_next | plunger_prev | assembly | exploded | section | layout
$fn = 32;

// ---------- derived layout (origin: X centred, Y = inner USB wall, Z = inner floor) ----------
inner_w   = max(batt[0] + 2*pocket_fit + 2*rail_w, xiao[0] + 2*side_gap);
z_pcb     = batt[2] + batt_gap;              // PCB underside
z_pcb_top = z_pcb + xiao[2];
inner_h   = z_pcb_top + xiao_comp_h + top_gap;
pcb_y0    = 0.3;
y_xiao1   = pcb_y0 + xiao[1];
y_batt0   = lead_gap;
y_batt1   = y_batt0 + batt[1] + 2*pocket_fit;
po        = sw_body + 2*pocket_fit + 2*pocket_wall;   // pocket outer size
y_sw0     = max(y_xiao1 + antenna_keepout, y_batt1 + 0.5);
sw_pitch  = cap[1] + cap_gap;
sw_y      = [y_sw0 + po/2, y_sw0 + po/2 + sw_pitch];
inner_l   = sw_y[1] + po/2 + 0.5;
outer     = [inner_w + 2*wall, inner_l + 2*wall, floor_t + inner_h + lid_t];
z_shelf   = inner_h - flange_t - sw_h + preload;
usb_w     = usb[0] + usb_slop;

assert(z_shelf >= 0.5, "switch too tall for stack: shelf below floor");
assert(z_shelf + pocket_wall_h <= inner_h - flange_t - 0.5, "flange would hit pocket wall");
assert(wall - (snap_bump + 0.1) >= 0.8, "snap groove leaves wall too thin");
assert(sw_pitch >= po, "switch pockets overlap");
echo(outer=outer, inner=[inner_w, inner_l, inner_h], z_shelf=z_shelf, sw_y=sw_y);

// ---------- helpers ----------
module rrect(s, r) { translate([r, r]) offset(r) square([s[0]-2*r, s[1]-2*r]); }
module rbox(s, r) { linear_extrude(s[2]) rrect([s[0], s[1]], r); }
module inner_rect() { translate([-inner_w/2, 0]) square([inner_w, inner_l]); }
module chamfered_block(s, c) { // c = 45deg underside chamfer height, overhang on +/-X only
  hull() { translate([0, 0, c]) cube([s[0], s[1], s[2]-c]); translate([c, 0, 0]) cube([s[0]-2*c, s[1], 1]); }
}
snap_ys = [inner_l*0.25, inner_l*0.75];

// ---------- base ----------
module base() {
  difference() {
    translate([-outer[0]/2, -wall, -floor_t]) rbox([outer[0], outer[1], floor_t + inner_h], corner_r);
    translate([-inner_w/2, 0, 0]) cube([inner_w, inner_l, inner_h + 1]);
    // USB-C notch (open to the top; lid closes it)
    translate([-usb_w/2, -wall - 1, z_pcb_top - 0.2]) cube([usb_w, wall + 2, 20]);
    // snap grooves in long walls
    for (s = [-1, 1], y = snap_ys)
      translate([s*inner_w/2 - (s > 0 ? 0 : snap_bump + 0.1), y - snap_len/2 - 0.3, inner_h - snap_z - 0.7])
        cube([snap_bump + 0.1, snap_len + 0.6, 1.4]);
    // pry notch at far end
    translate([-pry_notch[0]/2, inner_l - 1, inner_h - pry_notch[1]]) cube([pry_notch[0], wall + 2, 5]);
  }
  // PCB rails + end stops (stop blocks sit on the rail tops, chamfered underneath)
  for (s = [-1, 1]) {
    translate([s > 0 ? inner_w/2 - rail_w : -inner_w/2, 0, 0]) cube([rail_w, y_xiao1 + 1.2, z_pcb]);
    translate([s > 0 ? xiao[0]/2 - 2 : -inner_w/2, y_xiao1 + pocket_fit, z_pcb])
      chamfered_block([inner_w/2 - xiao[0]/2 + 2, 1.2, xiao[2] + 1.5], 1.0);
  }
  // switch pockets
  for (y = sw_y) difference() {
    translate([-po/2, y - po/2, 0]) cube([po, po, z_shelf + pocket_wall_h]);
    translate([-(sw_body/2 + pocket_fit), y - (sw_body/2 + pocket_fit), z_shelf]) cube([sw_body + 2*pocket_fit, sw_body + 2*pocket_fit, 10]);
    translate([-po/2 - 1, y - sw_leg_w/2, z_shelf]) cube([po + 2, sw_leg_w, sw_leg_h]);
  }
}

// ---------- lid ----------
module lid() {
  difference() {
    union() {
      translate([-outer[0]/2, -wall, inner_h]) rbox([outer[0], outer[1], lid_t], corner_r);
      translate([0, 0, inner_h - lip_h]) linear_extrude(lip_h + 0.01)
        difference() { offset(-lid_fit) inner_rect(); offset(-lid_fit - lip_t) inner_rect(); }
      for (s = [-1, 1], y = snap_ys)
        translate([s*(inner_w/2 - lid_fit) - (s > 0 ? 0 : snap_bump), y - snap_len/2, inner_h - snap_z - 0.6])
          hull() { cube([0.01, snap_len, 1.2]); translate([s > 0 ? snap_bump - 0.01 : 0, 1, 0.3]) cube([0.01, snap_len - 2, 0.6]); }
    }
    for (y = sw_y) translate([-(stem[0]/2 + fit), y - (stem[1]/2 + fit), inner_h - 1]) cube([stem[0] + 2*fit, stem[1] + 2*fit, lid_t + 2]);
    translate([reset_pos[0], pcb_y0 + reset_pos[1], inner_h - 1]) cylinder(d = reset_hole_d, h = lid_t + 2);
    // clear the lip above the USB notch
    translate([-usb_w/2 - 0.5, -1, inner_h - lip_h - 1]) cube([usb_w + 1, lip_t + lid_fit + 1.5, lip_h + 1]);
  }
}

// ---------- plungers (printed cap-up; z=0 is flange underside) ----------
module plunger(prev = false) {
  z0 = flange_t + lid_t + cap_lift;
  translate([-flange[0]/2, -flange[1]/2, 0]) cube([flange[0], flange[1], flange_t]);
  translate([-stem[0]/2, -stem[1]/2, flange_t - 0.01]) cube([stem[0], stem[1], lid_t + cap_lift + 0.02]);
  hull() {
    translate([-stem[0]/2, -stem[1]/2, z0]) cube([stem[0], stem[1], 0.01]);
    translate([-cap[0]/2, -cap[1]/2, z0 + (cap[0] - stem[0])/2]) cube([cap[0], cap[1], 0.01]);
    translate([-cap[0]/2, -cap[1]/2, z0 + cap_t - 0.4]) cube([cap[0], cap[1], 0.01]);
    translate([-cap[0]/2 + 0.4, -cap[1]/2 + 0.4, z0 + cap_t]) cube([cap[0] - 0.8, cap[1] - 0.8, 0.01]);
  }
  if (prev) translate([-cap[0]/2 + 1, -ridge[0]/2, z0 + cap_t - 0.01]) cube([cap[0] - 2, ridge[0], ridge[1]]);
}

// ---------- hardware mockups ----------
module hw() {
  color("DarkSeaGreen") translate([-xiao[0]/2, pcb_y0, z_pcb]) cube([xiao[0], xiao[1], xiao[2]]);
  color("Silver") translate([-usb[0]/2, pcb_y0 - usb_overhang, z_pcb_top]) cube([usb[0], 7.3, usb[1]]);
  color("Gold") translate([reset_pos[0], pcb_y0 + reset_pos[1], z_pcb_top]) cylinder(d = 2.5, h = 1.5);
  color("Tan") translate([-xiao[0]/2, y_xiao1 - 3, z_pcb_top]) cube([xiao[0], 3, 1]); // antenna end
  color("SteelBlue") translate([-batt[0]/2, y_batt0 + pocket_fit, 0]) cube([batt[0], batt[1], batt[2]]);
  for (y = sw_y) {
    color("DimGray") translate([-sw_body/2, y - sw_body/2, z_shelf]) cube([sw_body, sw_body, sw_h - 1]);
    color("Gray") translate([0, y, z_shelf + sw_h - 1]) cylinder(d = sw_dome_d, h = 1);
  }
}

module plungers(dz = 0) for (i = [0, 1]) translate([0, sw_y[i], inner_h - flange_t + dz]) plunger(prev = i == 1);

module label(t, p, z = 25) color("Black") translate([p[0], p[1], z]) linear_extrude(0.5) text(t, size = 2.2, halign = "center", valign = "center");

// ---------- dispatch ----------
if (part == "base") translate([0, 0, floor_t]) base();
if (part == "lid") mirror([0, 0, 1]) translate([0, 0, -inner_h - lid_t]) lid(); // printed top-down
if (part == "plunger_next") plunger(false);
if (part == "plunger_prev") plunger(true);
if (part == "assembly") { color("Khaki") base(); color("LightSteelBlue", 0.7) lid(); color("Tomato") plungers(); hw(); }
if (part == "exploded") { color("Khaki") base(); hw(); translate([0, 0, 14]) color("LightSteelBlue") lid(); color("Tomato") plungers(24); }
// 2D cross-section through the button centres (plane x=0), length along X, height along Y
module cut(c) color(c) mirror([1, 0]) rotate(90) projection(cut = true) rotate([0, 90, 0]) children();
if (part == "section") { cut("Khaki") base(); cut("LightSteelBlue") lid(); cut("Tomato") plungers(); cut("DimGray") hw(); }
if (part == "layout") {
  color("Khaki") base(); hw();
  label("XIAO nRF52840", [0, pcb_y0 + 11]);
  label("USB-C", [0, -4]);
  label("reset pinhole", [reset_pos[0], pcb_y0 + reset_pos[1] + 2.5]);
  label("antenna end", [0, y_xiao1 - 1.5]);
  label("battery (below)", [0, y_batt1 - 2]);
  label("NEXT (flat)", [0, sw_y[0]]);
  label("PREV (ridge)", [0, sw_y[1]]);
  label("wires", [-inner_w/2 + 2, y_xiao1 + 1.5]);
}
