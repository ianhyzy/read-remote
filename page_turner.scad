// page-turner-case: XIAO nRF52840 + 402025 LiPo + 2 silent tactile switches
// Stack (bottom up): floor | PCB on rails (USB end) ; battery on floor under a drop-in switch tray (button end) | caps | lid
include <params.scad>

part    = "assembly";   // base | lid | tray | plunger_next | plunger_prev | coupon_base | coupon_lid | coupon_tray | assembly | exploded | section | layout
variant = "kobo";       // kobo | rocker | dishdome | bars | sidebyside | dot
$fn = 48;

// ---------- derived layout (origin: X centred, Y = inner USB wall, Z = inner floor) ----------
v_extra_w = variant == "sidebyside" ? 8 : 0;
inner_w   = max(batt[0] + 2*(batt_fit + ledge_w), xiao[0] + 2*side_gap) + v_extra_w;
z_pcb     = rail_h;
z_pcb_top = z_pcb + xiao[2];
usb_zc    = z_pcb_top + usb[1]/2;
y_pcb1    = pcb_setback + xiao[1];
y_stop0   = y_pcb1 + pocket_fit;                 // PCB end stops
y_t0      = y_stop0;                             // tray front edge (rests on the stops)
y_batt0   = y_stop0 + stop_t + lead_gap;
y_batt1   = y_batt0 + batt[1] + 2*batt_fit;
z_ledge   = batt[2] + batt_gap;                  // tray underside
z_shelf   = z_ledge + tray_t;                    // switch sits here
inner_h   = z_shelf - preload + sw_h + flange_t; // cap flange top = lid underside
po        = sw_body + 2*pocket_fit + 2*pocket_wall;
W         = 2*(inner_w/2 - lid_fit - lip_t - lid_frame - fit);   // widest cap that fits the lid
yp0       = y_t0 + 1.0 + max(po/2, 5) + 1.0;    // first switch centre if the caps set the length
Ws        = (W - cap_gap)/2;  xs = (Ws + cap_gap)/2;
cap_h     = lid_t - cap_recess;

// caps: [cx, cy, w, l, shape, style, corner_r?]; caps[0] = PREV (near), caps[1] = NEXT (far)
caps0 =
  variant == "kobo"       ? [[0, yp0, 10, 10, "round", "dome"],      [0, yp0 + 15, W, W, "rect", "dish", next_r]] :
  variant == "rocker"     ? [[0, yp0 + 9, W, 28, "rect", "rocker"]] :
  variant == "dishdome"   ? [[0, yp0, W, 13, "rect", "dome"],        [0, yp0 + 16, W, 13, "rect", "dish"]] :
  variant == "bars"       ? [[0, yp0, W, 9, "rect", "flat"],         [0, yp0 + 17, W, 19, "rect", "flat"]] :
  variant == "sidebyside" ? [[-xs, yp0 + 6, Ws, 24, "rect", "dome"], [xs, yp0 + 6, Ws, 24, "rect", "dish"]] :
  /* dot */                 [[0, yp0, W, 13, "rect", "dot"],         [0, yp0 + 16, W, 13, "rect", "flat"]];
tail      = fit + lid_frame + lip_t + lid_fit;                          // cap end to inner far wall
inner_l_caps = max([for (c = caps0) c[1] + c[3]/2]) + tail;
inner_l   = max(inner_l_caps, y_batt1 + r_plan_far - wall);             // battery must end before the far-end arc
shift     = max(0, inner_l - inner_l_caps - cap_shift);                 // battery-driven slack minus the user shift, never past the tray front
caps      = [for (c = caps0) [c[0], c[1] + shift, c[2], c[3], c[4], c[5], is_undef(c[6]) ? cap_r : c[6]]];
yp        = yp0 + shift;
sws       = variant == "rocker" ? [[0, yp], [0, yp + 18]] : [for (c = caps) [c[0], c[1]]];
next_cap  = len(caps) > 1 ? caps[1] : caps[0];
prev_cap  = len(caps) > 1 ? caps[0] : undef;
outer     = [inner_w + 2*wall, inner_l + 2*wall, floor_t + inner_h + lid_t];
H_tot    = outer[2];
corners  = [for (sx = [-1, 1]) [sx*(outer[0]/2 - r_plan_usb), -wall + r_plan_usb, r_plan_usb],
            for (sx = [-1, 1]) [sx*(outer[0]/2 - r_plan_far), inner_l + wall - r_plan_far, r_plan_far]];
snap_ys  = [inner_l*0.25, inner_l*0.75];
z_bump   = inner_h - finger_h + 0.7;             // snap bump / groove centre

// corner-fit checks: point (x,y) must lie inside a plan corner arc of radius r about (cx,cy)
function in_arc(x, y, cx, cy, r) = sqrt(pow(x - cx, 2) + pow(y - cy, 2)) <= r;
ri_usb = r_plan_usb - wall;
assert(pcb_setback >= ri_usb || in_arc(xiao[0]/2 + pocket_fit, pcb_setback, inner_w/2 - ri_usb, ri_usb, ri_usb),
       "PCB corners hit the rounded cavity: raise pcb_setback or lower r_plan_usb");
assert(wall - (snap_bump + 0.1) >= 0.8, "snap groove leaves wall too thin");
assert(inner_h - finger_h >= z_shelf + 0.4, "snap fingers would hit the tray: shorten finger_h");
assert(preload <= 0.1, "preload above 0.1 pre-actuates the switch");
echo(variant=variant, outer=outer, inner=[inner_w, inner_l, inner_h], z_pcb=z_pcb, z_shelf=z_shelf, caps=caps);

// ---------- 2D / shell helpers ----------
module plan2d() hull() for (c = corners) translate([c[0], c[1]]) circle(c[2]);
module cavity2d() offset(-wall) plan2d();
module edge_profile(rp) intersection() { square([rp, H_tot]); hull() {
  square([rp - max(r_bot, r_top), H_tot]); square([0.01, H_tot]);
  translate([rp - r_bot, r_bot]) circle(r_bot);
  translate([rp - r_top, H_tot - r_top]) circle(r_top);
  translate([rp - r_bot + 0.414*r_bot, 0]) square(0.01);              // 45deg blend at the bed (base)
  translate([rp - r_top + 0.414*r_top, H_tot - 0.01]) square(0.01);   // 45deg blend at the bed (lid prints top-down)
} }
module outer3d() hull() for (c = corners) translate([c[0], c[1], -floor_t]) rotate_extrude($fn = 96) edge_profile(c[2]);
module allowed2d() offset(-(lid_fit + lip_t + lid_frame + fit)) cavity2d();
module cap2d(c, grow = 0) intersection() {
  r = is_undef(c[6]) ? cap_r : c[6];
  if (c[4] == "round") circle(d = c[2] + 2*grow);
  else offset(r + grow) square([c[2] - 2*r, c[3] - 2*r], center = true);
  translate([-c[0], -c[1]]) offset(grow) allowed2d();
}
module zslab(z0, z1) translate([-100, -100, z0]) cube([200, 300, z1 - z0]);
module usb_funnel() {
  w = usb_plug[0]; h = usb_plug[1]; f = usb_flare;
  hull() {
    translate([-w/2 - f, -wall - 0.01, usb_zc - h/2 - f]) cube([w + 2*f, 0.01, h + f]);
    translate([-w/2, -wall + f, usb_zc - h/2]) cube([w, 0.01, h]);
    translate([-w/2, pcb_setback - usb_overhang - 0.3, usb_zc - h/2]) cube([w, 0.01, h]);
  }
}

// ---------- base ----------
module base() difference() {
  union() {
    difference() { intersection() { outer3d(); zslab(-floor_t - 1, inner_h); } linear_extrude(inner_h + 1) cavity2d(); }
    intersection() {
      translate([0, 0, -0.02]) linear_extrude(inner_h + 0.02) offset(-0.01) cavity2d();
      union() {
        // ledge ring around the battery bay; the tray rests on it
        translate([0, 0, -0.01]) linear_extrude(z_ledge + 0.01) intersection() {
          difference() { offset(0.5) cavity2d(); offset(-ledge_w) cavity2d(); }
          translate([-100, y_stop0 + stop_t - 0.01]) square([200, 200]);
        }
        // magnet bosses under the PCB (pockets cut below)
        if (magnet[0] > 0) for (mp = magnet_pos) translate([mp[0], pcb_setback + mp[1], -0.01]) cylinder(d = magnet[0] + 2*magnet_fit + 2, h = magnet[1] + 0.2 + 0.4 - 1.0 + 0.01);
        // PCB rails under the long edges, and full-height end stops (tray front also rests on these)
        for (s = [-1, 1]) {
          translate([s*(xiao[0]/2 - 0.4) - 0.6, 1.5, -0.01]) cube([1.2, y_pcb1 - 1.0, z_pcb + 0.01]);
          translate([s > 0 ? xiao[0]/2 - 1.5 : -inner_w/2 - 0.5, y_stop0, -0.01]) cube([inner_w/2 - xiao[0]/2 + 2, stop_t, z_ledge + 0.01]);
        }
      }
    }
  }
  usb_funnel();
  if (magnet[0] > 0) for (mp = magnet_pos)   // pocket floor 0.6 above the bed, roof 0.4 thick
    translate([mp[0], pcb_setback + mp[1], -floor_t + 0.6]) cylinder(d = magnet[0] + 2*magnet_fit, h = magnet[1] + 0.2);
  for (s = [-1, 1], y = snap_ys)   // grooves for the lid's snap fingers
    translate([s*inner_w/2 - (s > 0 ? 0 : snap_bump + 0.1), y - snap_len/2 - 0.3, z_bump - 0.7]) cube([snap_bump + 0.1, snap_len + 0.6, 1.4]);
  if (lanyard_d > 0) translate([0, inner_l - ledge_w - 1, 2.5]) rotate([-90, 0, 0]) cylinder(d = lanyard_d, h = r_plan_far + 2);
  translate([-pry_notch[0]/2, inner_l - 0.5, inner_h - pry_notch[1]]) cube([pry_notch[0], wall + 2, 5]);
}

// ---------- switch tray (drop-in; solder the switches on it before installing) ----------
module tray_pocket(x, y) {
  d = sw_body/2 + pocket_fit;
  for (sy = [-1, 1]) translate([x - po/2, y + (sy > 0 ? d : -d - pocket_wall), tray_t - 0.01]) cube([po, pocket_wall, pocket_wall_h]);
  for (sx = [-1, 1], sy = [-1, 1])   // short corner returns; the leg sides stay open for the iron
    translate([x + (sx > 0 ? d : -d - pocket_wall), y + (sy > 0 ? d - 1.2 : -d + 0.2), tray_t - 0.01]) cube([pocket_wall, 1.0, pocket_wall_h]);
}
module tray() {
  linear_extrude(tray_t) intersection() { offset(-tray_fit) cavity2d(); translate([-100, y_t0]) square([200, 200]); }
  for (s = sws) tray_pocket(s[0], s[1]);
}

// ---------- lid ----------
module lid() difference() {
  union() {
    intersection() { outer3d(); zslab(inner_h, inner_h + lid_t + 1); }
    difference() {   // locating lip, with relief slots either side of each snap finger
      translate([0, 0, inner_h - lip_h]) linear_extrude(lip_h + 0.01)
        difference() { offset(-lid_fit) cavity2d(); offset(-lid_fit - lip_t) cavity2d(); }
      for (s = [-1, 1], y = snap_ys, e = [-1, 1])
        translate([s > 0 ? inner_w/2 - 3 : -inner_w/2, y + e*(finger_len/2 + relief_w/2) - relief_w/2, inner_h - lip_h - 1]) cube([3, relief_w, lip_h + 1]);
    }
    for (s = [-1, 1], y = snap_ys) {   // snap fingers with a tapered bump at the tip
      x0 = s > 0 ? inner_w/2 - lid_fit - finger_t : -inner_w/2 + lid_fit;
      translate([x0, y - finger_len/2, inner_h - finger_h]) cube([finger_t, finger_len, finger_h + 0.01]);
      translate([s > 0 ? inner_w/2 - lid_fit : -inner_w/2 + lid_fit - snap_bump, y - snap_len/2, z_bump - 0.6])
        hull() { translate([s > 0 ? 0 : snap_bump, 0, 0]) cube([0.01, snap_len, 1.2]); translate([s > 0 ? snap_bump - 0.01 : 0, 1, 0.3]) cube([0.01, snap_len - 2, 0.6]); }
    }
    // PCB hold-down pillars: two on the bare antenna-end corners, one on the USB shell
    for (s = [-1, 1]) translate([s*(xiao[0]/2 - 1.3) - 1.2, y_pcb1 - pad_free_end, z_pcb_top + 0.15]) cube([2.4, pad_free_end - 0.2, inner_h - z_pcb_top - 0.15 + 0.01]);
    translate([-1.5, pcb_setback + 3, z_pcb_top + usb[1] + 0.15]) cube([3, 2, inner_h - z_pcb_top - usb[1] - 0.15 + 0.01]);
  }
  for (c = caps) translate([c[0], c[1], 0]) {
    translate([0, 0, inner_h - 1]) linear_extrude(lid_t + 2) cap2d(c, fit);
    hull() {   // 45deg chamfer on the window's top edge
      translate([0, 0, inner_h + lid_t - win_chamfer]) linear_extrude(0.01) cap2d(c, fit);
      translate([0, 0, inner_h + lid_t]) linear_extrude(0.01) cap2d(c, fit + win_chamfer);
    }
  }
  translate([reset_pos[0], pcb_setback + reset_pos[1], inner_h - 1]) cylinder(d = reset_hole_d, h = lid_t + 2);
  if (led_hole_d > 0) translate([led_pos[0], pcb_setback + led_pos[1], inner_h - 1]) cylinder(d = led_hole_d, h = lid_t + 2);
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
      hull() {
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

// ---------- hardware mockups ----------
module hw() {
  color("DarkSeaGreen") translate([-xiao[0]/2, pcb_setback, z_pcb]) cube([xiao[0], xiao[1], xiao[2]]);
  color("Silver") translate([-usb[0]/2, pcb_setback - usb_overhang, z_pcb_top]) cube([usb[0], 7.3, usb[1]]);
  color("Gold") translate([reset_pos[0], pcb_setback + reset_pos[1], z_pcb_top]) cylinder(d = 2.5, h = 1.5);
  color("Red") translate([led_pos[0], pcb_setback + led_pos[1], z_pcb_top]) cylinder(d = 1.6, h = 0.6);
  if (magnet[0] > 0) color("Silver") for (mp = magnet_pos) translate([mp[0], pcb_setback + mp[1], -floor_t + 0.7]) cylinder(d = magnet[0], h = magnet[1]);
  color("Tan") translate([-xiao[0]/2, y_pcb1 - 3, z_pcb_top]) cube([xiao[0], 3, 1]);
  color("SteelBlue") translate([-batt[0]/2, y_batt0 + batt_fit, 0]) cube([batt[0], batt[1], batt[2]]);
  for (s = sws) {
    color("DimGray") translate([s[0] - sw_body/2, s[1] - sw_body/2, z_shelf]) cube([sw_body, sw_body, sw_h - 1]);
    color("Gray") translate([s[0], s[1], z_shelf + sw_h - 1]) cylinder(d = sw_dome_d, h = 1);
  }
}
module plungers(dz = 0) for (c = caps) translate([c[0], c[1], inner_h - flange_t + dz]) plunger(c);
module label(t, p, z = 30) color("Black") translate([p[0], p[1], z]) linear_extrude(0.5) text(t, size = 2.2, halign = "center", valign = "center");
module cut(x, c) color(c) mirror([1, 0]) rotate(90) projection(cut = true) rotate([0, 90, 0]) translate([-x, 0, 0]) children();

// ---------- fit coupon: the button end only (both caps, both pockets, the rear snap fingers, tray on its ledge) ----------
y_cpn = yp - max(po/2, 5) - 2;
module coupon(part_mod) intersection() { children(); translate([-100, y_cpn, -50]) cube([200, 200, 100]); }

// ---------- dispatch ----------
if (part == "base") translate([0, 0, floor_t]) base();
if (part == "lid") mirror([0, 0, 1]) translate([0, 0, -inner_h - lid_t]) lid();   // printed top-down
if (part == "tray") tray();
if (part == "coupon_base") translate([0, -y_cpn, floor_t]) coupon() base();
if (part == "coupon_lid") mirror([0, 0, 1]) translate([0, -y_cpn, -inner_h - lid_t]) coupon() lid();
if (part == "coupon_tray") translate([0, -y_cpn, 0]) coupon() tray();
if (part == "plunger_next") plunger(next_cap);
if (part == "plunger_prev") if (!is_undef(prev_cap)) plunger(prev_cap);
if (part == "assembly") { color("Khaki") base(); color("Wheat") translate([0, 0, z_ledge]) tray(); color("LightSteelBlue", 0.7) lid(); color("Tomato") plungers(); hw(); }
if (part == "exploded") { color("Khaki") base(); hw(); color("Wheat") translate([0, 0, z_ledge + 10]) tray(); translate([0, 0, 24]) color("LightSteelBlue") lid(); color("Tomato") plungers(36); }
if (part == "section" || part == "section_mag") { x = part == "section" ? next_cap[0] : magnet_pos[1][0]; cut(x, "Khaki") base(); cut(x, "Wheat") translate([0, 0, z_ledge]) tray(); cut(x, "LightSteelBlue") lid(); cut(x, "Tomato") plungers(); cut(x, "DimGray") hw(); }
if (part == "layout") {
  color("Khaki") base(); hw(); color("Wheat", 0.6) translate([0, 0, z_ledge]) tray(); color("Tomato", 0.5) plungers();
  label("XIAO nRF52840", [0, pcb_setback + 13.5]); label("USB-C", [0, -4]);
  label("reset", [reset_pos[0], pcb_setback + reset_pos[1] + 2.5]); label("LED", [led_pos[0], pcb_setback + led_pos[1] + 2.5]);
  if (magnet[0] > 0) label("magnets (below PCB)", [0, pcb_setback + magnet_pos[0][1] + 2.8]);
  label("antenna end / keepout", [0, y_pcb1 + 1.5]); label("battery under tray", [0, inner_l - 3]);
  if (len(caps) > 1) { label("PREV", caps[0]); label("NEXT", caps[1]); }
  else { label("NEXT (far end)", [0, caps[0][1] + 7]); label("PREV (near end)", [0, caps[0][1] - 7]); }
}
