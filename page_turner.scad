// page-turner-case: XIAO nRF52840 + 402025 LiPo + 2 silent tactile switches
include <params.scad>

part    = "assembly";   // base | lid | plunger_next | plunger_prev | assembly | exploded | section | layout
variant = "kobo";       // kobo | rocker | dishdome | bars | sidebyside | trigger | dot
$fn = 48;

// ---------- derived layout (origin: X centred, Y = inner USB wall, Z = inner floor) ----------
v_extra_w = variant == "sidebyside" ? 8 : 0;
inner_w   = max(batt[0] + 2*pocket_fit + 2*rail_w, xiao[0] + 2*side_gap) + v_extra_w;
z_pcb     = batt[2] + batt_gap;
z_pcb_top = z_pcb + xiao[2];
inner_h   = z_pcb_top + xiao_comp_h + top_gap;
pcb_y0    = pcb_setback;
y_xiao1   = pcb_y0 + xiao[1];
y_batt0   = lead_gap;
y_batt1   = y_batt0 + batt[1] + 2*pocket_fit;
po        = sw_body + 2*pocket_fit + 2*pocket_wall;          // switch pocket outer size
W         = 2*(inner_w/2 - lid_fit - lip_t - lid_frame - fit); // widest cap that fits the lid
yp        = y_batt1 + 0.5 + po/2;                             // nearest switch centre clear of the battery
Ws        = (W - cap_gap)/2;  xs = (Ws + cap_gap)/2;          // side-by-side caps
cap_h     = lid_t - cap_recess;
z_shelf   = inner_h - flange_t - sw_h + preload;
usb_w     = usb[0] + usb_slop;

// caps: [cx, cy, w, l, shape, style]; caps[0] = PREV, caps[1] = NEXT (single-cap variants: see below)
caps =
  variant == "kobo"       ? [[0, yp, 10, 10, "round", "dome"],      [0, yp + 15, W, 17, "rect", "dish"]] :
  variant == "rocker"     ? [[0, yp + 9, W, 28, "rect", "rocker"]] :
  variant == "dishdome"   ? [[0, yp, W, 13, "rect", "dome"],        [0, yp + 16, W, 13, "rect", "dish"]] :
  variant == "bars"       ? [[0, yp, W, 9, "rect", "flat"],         [0, yp + 17, W, 19, "rect", "flat"]] :
  variant == "sidebyside" ? [[-xs, yp + 6, Ws, 24, "rect", "dome"], [xs, yp + 6, Ws, 24, "rect", "dish"]] :
  variant == "trigger"    ? [[0, yp + 4, W, 18, "rect", "dish"]] :
  /* dot */                 [[0, yp, W, 13, "rect", "dot"],         [0, yp + 16, W, 13, "rect", "flat"]];
sws      = variant == "rocker" ? [[0, yp], [0, yp + 18]] : [for (c = caps) [c[0], c[1]]];
end_btn  = variant == "trigger";
next_cap = len(caps) > 1 ? caps[1] : caps[0];
prev_cap = len(caps) > 1 ? caps[0] : undef;
cap_end  = max([for (c = caps) c[1] + c[3]/2]);
end_z    = 3.5;                                               // end-switch / end-cap centre height
inner_l  = max(cap_end + fit + lid_frame + lip_t + lid_fit,
               end_btn ? cap_end + flange_lip + 0.3 + 1.5 + sw_h + flange_t : 0);
outer    = [inner_w + 2*wall, inner_l + 2*wall, floor_t + inner_h + lid_t];

assert(z_shelf >= 0.5, "switch too tall for stack");
assert(z_shelf + pocket_wall_h <= inner_h - flange_t - 0.5, "flange would hit pocket wall");
assert(wall - (snap_bump + 0.1) >= 0.8, "snap groove leaves wall too thin");
for (s = sws) assert(s[1] >= yp - 0.01, "switch pocket overlaps battery");
ri = r_plan_usb - wall;   // cavity corner radius at the USB end
function corner_ok(x, y) = y >= ri || sqrt(pow(x - (inner_w/2 - ri), 2) + pow(y - ri, 2)) <= ri;
assert(corner_ok(xiao[0]/2 + pocket_fit, pcb_y0), "PCB corners hit the rounded cavity: raise pcb_setback or lower r_plan_usb");
assert(corner_ok(batt[0]/2 + pocket_fit, y_batt0 + pocket_fit), "battery corners hit the rounded cavity: raise lead_gap or lower r_plan_usb");
echo(variant=variant, outer=outer, inner=[inner_w, inner_l, inner_h], caps=caps, sws=sws);

// ---------- helpers ----------
H_tot   = floor_t + inner_h + lid_t;
r_far   = end_btn ? min(r_plan_far, 6) : r_plan_far;   // trigger variant needs a flat end wall
corners = [for (sx = [-1, 1]) [sx*(outer[0]/2 - r_plan_usb), -wall + r_plan_usb, r_plan_usb],
           for (sx = [-1, 1]) [sx*(outer[0]/2 - r_far), inner_l + wall - r_far, r_far]];
module plan2d() hull() for (c = corners) translate([c[0], c[1]]) circle(c[2]);
module cavity2d() offset(-wall) plan2d();
module edge_profile(rp) intersection() { square([rp, H_tot]); hull() {   // vertical half-profile of one corner: fillets with 45deg blends at bed/top
  square([rp - max(r_bot, r_top), H_tot]); square([0.01, H_tot]);
  translate([rp - r_bot, r_bot]) circle(r_bot);
  translate([rp - r_top, H_tot - r_top]) circle(r_top);
  translate([rp - r_bot + 0.414*r_bot, 0]) square(0.01);
  translate([rp - r_top + 0.414*r_top, H_tot - 0.01]) square(0.01);
} }
module outer3d() hull() for (c = corners) translate([c[0], c[1], -floor_t]) rotate_extrude($fn = 96) edge_profile(c[2]);
module allowed2d() offset(-(lid_fit + lip_t + lid_frame + fit)) cavity2d();   // where a cap body may be
module cap2d(c, grow = 0) {   // cap footprint, centred on origin, clipped to what fits inside the lid frame
  intersection() {
    if (c[4] == "round") circle(d = c[2] + 2*grow);
    else offset(cap_r + grow) square([c[2] - 2*cap_r, c[3] - 2*cap_r], center = true);
    translate([-c[0], -c[1]]) offset(grow) allowed2d();
  }
}
module chamfered_block(s, c) {
  hull() { translate([0, 0, c]) cube([s[0], s[1], s[2]-c]); translate([c, 0, 0]) cube([s[0]-2*c, s[1], 1]); }
}
snap_ys = [inner_l*0.25, inner_l*0.75];

// ---------- base ----------
module sw_pocket(x, y) difference() {
  translate([x - po/2, y - po/2, 0]) cube([po, po, z_shelf + pocket_wall_h]);
  translate([x - (sw_body/2 + pocket_fit), y - (sw_body/2 + pocket_fit), z_shelf]) cube([sw_body + 2*pocket_fit, sw_body + 2*pocket_fit, 10]);
  translate([x - po/2 - 1, y - sw_leg_w/2, z_shelf]) cube([po + 2, sw_leg_w, sw_leg_h]);
}
module end_pocket() {   // switch lying on its side at the far wall, dome facing +Y
  yb = inner_l - flange_t - sw_h;                     // switch base plane
  translate([-5, yb - 1.5, 0]) cube([10, 1.5, 7]);    // backstop
  translate([-(sw_body/2 + pocket_fit) - 1, yb, 0]) cube([1, sw_h - 0.5, end_z + sw_body/2 + 1]);  // side guides
  translate([sw_body/2 + pocket_fit, yb, 0]) cube([1, sw_h - 0.5, end_z + sw_body/2 + 1]);
  translate([-5, yb, 0]) cube([10, sw_h, end_z - sw_body/2]);   // shelf
}
module base() {
  difference() {
    intersection() { outer3d(); translate([-50, -50, -floor_t - 1]) cube([100, 200, floor_t + inner_h + 1]); }
    linear_extrude(inner_h + 1) cavity2d();
    translate([-usb_w/2, -wall - 1, z_pcb_top - 0.2]) cube([usb_w, wall + 2, 20]);     // USB-C notch
    for (s = [-1, 1], y = snap_ys)
      translate([s*inner_w/2 - (s > 0 ? 0 : snap_bump + 0.1), y - snap_len/2 - 0.3, inner_h - snap_z - 0.7])
        cube([snap_bump + 0.1, snap_len + 0.6, 1.4]);
    if (lanyard_d > 0) translate([end_btn ? 7 : 0, inner_l - 1, 4]) rotate([-90, 0, 0]) cylinder(d = lanyard_d, h = r_plan_far + 2);
    if (end_btn) translate([-(end_cap[0]/2 + fit), inner_l - 1, end_z - end_cap[1]/2 - fit]) cube([end_cap[0] + 2*fit, wall + 2, end_cap[1] + 2*fit]);
  }
  intersection() {   // PCB rails + chamfered end stops, clipped to the rounded cavity
    linear_extrude(inner_h) offset(-0.01) cavity2d();   // -0.01 avoids coplanar preview artefacts
    for (s = [-1, 1]) {
      translate([s > 0 ? inner_w/2 - rail_w : -inner_w/2, 0, 0]) cube([rail_w, y_xiao1 + 1.2, z_pcb]);
      translate([s > 0 ? xiao[0]/2 - 2 : -inner_w/2, y_xiao1 + pocket_fit, z_pcb])
        chamfered_block([inner_w/2 - xiao[0]/2 + 2, 1.2, xiao[2] + 1.5], 1.0);
    }
  }
  for (s = sws) sw_pocket(s[0], s[1]);
  if (end_btn) end_pocket();
}

// ---------- lid ----------
module lid() {
  difference() {
    union() {
      intersection() { outer3d(); translate([-50, -50, inner_h]) cube([100, 200, lid_t + 1]); }
      translate([0, 0, inner_h - lip_h]) linear_extrude(lip_h + 0.01)
        difference() { offset(-lid_fit) cavity2d(); offset(-lid_fit - lip_t) cavity2d(); }
      for (s = [-1, 1], y = snap_ys)
        translate([s*(inner_w/2 - lid_fit) - (s > 0 ? 0 : snap_bump), y - snap_len/2, inner_h - snap_z - 0.6])
          hull() { cube([0.01, snap_len, 1.2]); translate([s > 0 ? snap_bump - 0.01 : 0, 1, 0.3]) cube([0.01, snap_len - 2, 0.6]); }
    }
    for (c = caps) translate([c[0], c[1], inner_h - 1]) linear_extrude(lid_t + 2) cap2d(c, fit);
    translate([reset_pos[0], pcb_y0 + reset_pos[1], inner_h - 1]) cylinder(d = reset_hole_d, h = lid_t + 2);
    translate([-usb_w/2 - 0.5, -1, inner_h - lip_h - 1]) cube([usb_w + 1, lip_t + lid_fit + 1.5, lip_h + 1]);
  }
}

// ---------- caps (printed top-up; z=0 is flange underside) ----------
function sph_r(chord, h) = (chord*chord/4 + h*h) / (2*h);
module dish(w, l) { r = sph_r(min(w, l) - 2, dish_depth); translate([0, 0, r - dish_depth]) sphere(r = r, $fn = 160); }
module dome(w, l) { r = sph_r(max(w, l), dome_h); translate([0, 0, -r + dome_h]) sphere(r = r, $fn = 160); }
module bump() cylinder(d1 = dot[0], d2 = dot[1], h = dot[2]);
module plunger(c) {
  w = c[2]; l = c[3]; st = c[5]; zt = flange_t + cap_h;
  linear_extrude(flange_t) cap2d(c, flange_lip);
  difference() {
    union() {
      hull() {   // body with 0.4 top chamfer
        translate([0, 0, flange_t - 0.01]) linear_extrude(cap_h - 0.4) cap2d(c);
        linear_extrude(zt) cap2d(c, -0.4);
      }
      if (st == "dome") intersection() { translate([0, 0, zt - 0.01]) linear_extrude(dome_h) cap2d(c, -0.4); translate([0, 0, zt]) dome(w, l); }
      if (st == "dot") translate([0, 0, zt - 0.01]) bump();
      if (st == "rocker") translate([0, -l/4, zt - 0.01]) bump();
    }
    if (st == "dish") translate([0, 0, zt]) dish(w, l);
    if (st == "rocker") translate([0, l/4, zt]) dish(w, l/2);
  }
}
module end_plunger() {   // trigger variant: PREV button through the far wall, printed flange-down
  linear_extrude(flange_t) offset(1.5) square([end_cap[0], end_cap[1]], center = true);
  h = wall + end_cap[2];
  hull() {
    translate([0, 0, flange_t - 0.01]) linear_extrude(h - 1) offset(1) square([end_cap[0] - 2, end_cap[1] - 2], center = true);
    linear_extrude(flange_t + h) offset(0.5) square([end_cap[0] - 3, end_cap[1] - 3], center = true);
  }
}

// ---------- hardware mockups ----------
module hw() {
  color("DarkSeaGreen") translate([-xiao[0]/2, pcb_y0, z_pcb]) cube([xiao[0], xiao[1], xiao[2]]);
  color("Silver") translate([-usb[0]/2, pcb_y0 - usb_overhang, z_pcb_top]) cube([usb[0], 7.3, usb[1]]);
  color("Gold") translate([reset_pos[0], pcb_y0 + reset_pos[1], z_pcb_top]) cylinder(d = 2.5, h = 1.5);
  color("Tan") translate([-xiao[0]/2, y_xiao1 - 3, z_pcb_top]) cube([xiao[0], 3, 1]);
  color("SteelBlue") translate([-batt[0]/2, y_batt0 + pocket_fit, 0]) cube([batt[0], batt[1], batt[2]]);
  for (s = sws) {
    color("DimGray") translate([s[0] - sw_body/2, s[1] - sw_body/2, z_shelf]) cube([sw_body, sw_body, sw_h - 1]);
    color("Gray") translate([s[0], s[1], z_shelf + sw_h - 1]) cylinder(d = sw_dome_d, h = 1);
  }
  if (end_btn) color("DimGray") translate([-sw_body/2, inner_l - flange_t - sw_h, end_z - sw_body/2]) cube([sw_body, sw_h - 1, sw_body]);
}

module plungers(dz = 0) {
  for (c = caps) translate([c[0], c[1], inner_h - flange_t + dz]) plunger(c);
  if (end_btn) translate([0, inner_l - flange_t + dz, end_z]) rotate([-90, 0, 0]) end_plunger();
}
module label(t, p, z = 25) color("Black") translate([p[0], p[1], z]) linear_extrude(0.5) text(t, size = 2.2, halign = "center", valign = "center");
module cut(x, c) color(c) mirror([1, 0]) rotate(90) projection(cut = true) rotate([0, 90, 0]) translate([-x, 0, 0]) children();

// ---------- dispatch ----------
if (part == "base") translate([0, 0, floor_t]) base();
if (part == "lid") mirror([0, 0, 1]) translate([0, 0, -inner_h - lid_t]) lid();   // printed top-down
if (part == "plunger_next") plunger(next_cap);
if (part == "plunger_prev") { if (end_btn) end_plunger(); else if (!is_undef(prev_cap)) plunger(prev_cap); }
if (part == "assembly") { color("Khaki") base(); color("LightSteelBlue", 0.7) lid(); color("Tomato") plungers(); hw(); }
if (part == "exploded") { color("Khaki") base(); hw(); translate([0, 0, 14]) color("LightSteelBlue") lid(); color("Tomato") plungers(24); }
if (part == "section") { x = next_cap[0]; cut(x, "Khaki") base(); cut(x, "LightSteelBlue") lid(); cut(x, "Tomato") plungers(); cut(x, "DimGray") hw(); }
if (part == "layout") {
  color("Khaki") base(); hw(); color("Tomato", 0.5) plungers();
  label("XIAO nRF52840", [0, pcb_y0 + 11]); label("USB-C", [0, -4]);
  label("reset pinhole", [reset_pos[0], pcb_y0 + reset_pos[1] + 2.5]);
  label("antenna end", [0, y_xiao1 - 1.5]); label("battery (below)", [0, y_batt1 - 3.5]);
  if (len(caps) > 1) { label("PREV", caps[0]); label("NEXT", caps[1]); }
  else if (end_btn) { label("NEXT", caps[0]); label("PREV: end trigger", [0, inner_l + 4]); }
  else { label("NEXT (far end)", [0, caps[0][1] + 7]); label("PREV (near end)", [0, caps[0][1] - 7]); }
}
