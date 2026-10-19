// page-turner-case: XIAO nRF52840 + 402025 LiPo + 2 silent tactile switches
// Stack (bottom up): floor | PCB on rails (palm/USB half) ; battery on floor under a drop-in switch tray (button half) | caps | lid
// The palm half is cov_t lower (and its wall inset by the hood skirt) so the travel hood parks there, flush, while reading.
include <params.scad>

part    = "assembly";   // base | lid_front | lid_back | tray | cover | plunger_next | plunger_prev | coupon_* | assembly | assembly_cover | assembly_stored | section | section_mag | exploded | layout
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
inner_h   = z_shelf - preload + sw_h + flange_t; // button half: cap flange top = lid underside
drop      = cov_t;                               // palm half sits this much lower
inner_h_b = inner_h - drop;                      // palm half lid underside
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
zone_len  = inner_l_caps - min([for (c = caps0) c[1] - c[3]/2]) + fit + lid_frame;   // first window edge (+frame) to inner far wall
inner_l   = max(inner_l_caps, y_batt1 + r_plan_far - wall, 2*(zone_len + 0.5));     // hood = half the case and must cover the whole zone
shift     = max(0, inner_l - inner_l_caps - cap_shift);
caps      = [for (c = caps0) [c[0], c[1] + shift, c[2], c[3], c[4], c[5], is_undef(c[6]) ? cap_r : c[6]]];
yp        = yp0 + shift;
sws       = variant == "rocker" ? [[0, yp], [0, yp + 18]] : [for (c = caps) [c[0], c[1]]];
next_cap  = len(caps) > 1 ? caps[1] : caps[0];
prev_cap  = len(caps) > 1 ? caps[0] : undef;
step_y    = inner_l/2;                            // palm half | button half
outer     = [inner_w + 2*wall, inner_l + 2*wall, floor_t + inner_h + lid_t];
H_tot     = outer[2];
corners   = [for (sx = [-1, 1]) [sx*(outer[0]/2 - r_plan_usb), -wall + r_plan_usb, r_plan_usb],
             for (sx = [-1, 1]) [sx*(outer[0]/2 - r_plan_far), inner_l + wall - r_plan_far, r_plan_far]];
snap_ys   = [inner_l*0.25, inner_l*0.75];
z_bump_a  = inner_h - finger_h + 0.7;             // snap bump / groove centre, button half
z_bump_b  = inner_h_b - finger_h_b + 0.7;         // palm half
neck      = cov_skirt_t + cov_fit;                // palm-half wall inset above neck_z

function in_arc(x, y, cx, cy, r) = sqrt(pow(x - cx, 2) + pow(y - cy, 2)) <= r;
ri_usb = r_plan_usb - wall;
assert(pcb_setback >= ri_usb || in_arc(xiao[0]/2 + pocket_fit, pcb_setback, inner_w/2 - ri_usb, ri_usb, ri_usb),
       "PCB corners hit the rounded cavity: raise pcb_setback or lower r_plan_usb");
assert(wall - (snap_bump + 0.1) >= 0.8, "snap groove leaves wall too thin");
assert(inner_h - finger_h >= z_shelf + 0.4, "snap fingers would hit the tray: shorten finger_h");
assert(z_bump_b - 0.7 >= neck_z + 0.2, "palm-half snap bump below the neck band: shorten finger_h_b");
assert(min([for (c = caps) c[1] - c[3]/2]) - fit - lid_frame >= step_y, "button window crosses the lid split: lengthen the case");
assert(preload <= 0.1, "preload above 0.1 pre-actuates the switch");
echo(variant=variant, outer=outer, inner=[inner_w, inner_l, inner_h], step_y=step_y, caps=caps);

// ---------- 2D / shell helpers ----------
module plan2d() hull() for (c = corners) translate([c[0], c[1]]) circle(c[2]);
module cavity2d() offset(-wall) plan2d();
module half2d(front) translate([-100, front ? step_y : -100]) square([200, front ? 200 : 100 + step_y]);   // y >= step (front/button) or y < step (back/palm)
module edge_profile(rp, H) intersection() { square([rp, H]); hull() {
  square([rp - max(r_bot, r_top), H]); square([0.01, H]);
  translate([rp - r_bot, r_bot]) circle(r_bot);
  translate([rp - r_top, H - r_top]) circle(r_top);
  translate([rp - r_bot + 0.414*r_bot, 0]) square(0.01);          // 45deg blend at the bed (base)
  translate([rp - r_top + 0.414*r_top, H - 0.01]) square(0.01);   // 45deg blend at the bed (lids print top-down)
} }
module outer3d(H = H_tot, inset = 0) hull() for (c = corners) translate([c[0], c[1], -floor_t]) rotate_extrude($fn = 96) edge_profile(c[2] - inset, H);
module zslab(z0, z1) translate([-100, -100, z0]) cube([200, 300, z1 - z0]);
module yslab(front) linear_extrude(100, center = true) half2d(front);
module allowed2d() offset(-(lid_fit + lip_t + lid_frame + fit)) cavity2d();
module cap2d(c, grow = 0) intersection() {
  r = is_undef(c[6]) ? cap_r : c[6];
  if (c[4] == "round") circle(d = c[2] + 2*grow);
  else offset(r + grow) square([c[2] - 2*r, c[3] - 2*r], center = true);
  translate([-c[0], -c[1]]) offset(grow) allowed2d();
}
module usb_funnel() {   // overmold-sized opening with a 45deg lead-in; open to the top of the (lowered) palm wall
  w = usb_plug[0]; h = usb_plug[1]; f = usb_flare;
  hull() {
    translate([-w/2 - f, -wall - 1, usb_zc - h/2 - f]) cube([w + 2*f, 0.01, h + f]);
    translate([-w/2, -wall + f, usb_zc - h/2]) cube([w, 0.01, h]);
    translate([-w/2, pcb_setback - usb_overhang - 0.3, usb_zc - h/2]) cube([w, 0.01, h]);
  }
  translate([-w/2, -wall - 1, usb_zc]) cube([w, wall + 1 + pcb_setback - usb_overhang - 0.3, inner_h_b + 1 - usb_zc]);
}
// hood groove ring at the far end (top face); mirrored for the palm end
module far_ring2d(o_out, o_in) difference() { intersection() { offset(o_out) plan2d(); half2d(true); } intersection() { offset(o_in) plan2d(); half2d(true); } }

// ---------- base ----------
module base() difference() {
  union() {
    difference() {
      union() {
        intersection() { outer3d(); zslab(-floor_t - 1, inner_h); yslab(true); }                                // button half, full height
        intersection() { outer3d(H_tot - drop); zslab(-floor_t - 1, neck_z); yslab(false); }                       // palm half, lower part full width
        intersection() { outer3d(H_tot - drop, neck); zslab(neck_z - 0.01, inner_h_b); yslab(false); }             // palm half, inset neck band
      }
      linear_extrude(neck_z) cavity2d();                                                                            // full cavity below the neck
      translate([0, 0, neck_z - 0.01]) linear_extrude(inner_h + 1) intersection() { offset(-neck) cavity2d(); half2d(false); }   // narrower cavity in the neck band
      translate([0, 0, neck_z - 0.01]) linear_extrude(inner_h + 1) intersection() { cavity2d(); half2d(true); }
    }
    intersection() {
      translate([0, 0, -0.02]) linear_extrude(inner_h + 0.02) offset(-0.01) cavity2d();
      union() {
        translate([0, 0, -0.01]) linear_extrude(z_ledge + 0.01) intersection() {   // ledge ring around the battery bay
          difference() { offset(0.5) cavity2d(); offset(-ledge_w) cavity2d(); }
          translate([-100, y_stop0 + stop_t - 0.01]) square([200, 200]);
        }
        if (magnet[0] > 0) for (mp = magnet_pos) translate([mp[0], pcb_setback + mp[1], -0.01]) cylinder(d = magnet[0] + 2*magnet_fit + 2, h = magnet[1] + 0.2 + 0.4 - 1.0 + 0.01);
        for (s = [-1, 1]) {   // PCB rails + full-height end stops (tray front rests on these)
          translate([s*(xiao[0]/2 - 0.4) - 0.6, 1.5, -0.01]) cube([1.2, y_pcb1 - 1.0, z_pcb + 0.01]);
          translate([s > 0 ? xiao[0]/2 - 1.5 : -inner_w/2 - 0.5, y_stop0, -0.01]) cube([inner_w/2 - xiao[0]/2 + 2, stop_t, z_ledge + 0.01]);
        }
      }
    }
  }
  usb_funnel();
  if (magnet[0] > 0) for (mp = magnet_pos) translate([mp[0], pcb_setback + mp[1], -floor_t + 0.6]) cylinder(d = magnet[0] + 2*magnet_fit, h = magnet[1] + 0.2);
  for (s = [-1, 1]) {   // snap-finger grooves: one pair per half
    translate([s*inner_w/2 - (s > 0 ? 0 : snap_bump + 0.1), snap_ys[1] - snap_len/2 - 0.3, z_bump_a - 0.7]) cube([snap_bump + 0.1, snap_len + 0.6, 1.4]);
    translate([s*(inner_w/2 - neck) - (s > 0 ? 0 : snap_bump + 0.1), snap_ys[0] - snap_len/2 - 0.3, z_bump_b - 0.7]) cube([snap_bump + 0.1, snap_len + 0.6, 1.4]);
  }
  translate([0, 0, inner_h - 1.0]) linear_extrude(1.0) far_ring2d(0.5, -cov_rib - 0.05);                                           // hood groove, travel (button half)
  translate([0, inner_l, inner_h_b - 1.0]) mirror([0, 1, 0]) linear_extrude(1.0) far_ring2d(0.5 - neck, -neck - cov_rib - 0.05);     // hood groove, parked (palm half)
  if (lanyard_d > 0) translate([0, inner_l - ledge_w - 1, lanyard_z]) rotate([-90, 0, 0]) cylinder(d = lanyard_d, h = r_plan_far + 2);
  translate([-pry_notch[0]/2, inner_l - 0.5, inner_h - pry_notch[1]]) cube([pry_notch[0], wall + 2, 5]);
}

// ---------- switch tray ----------
module tray_pocket(x, y) {
  d = sw_body/2 + pocket_fit;
  for (sy = [-1, 1]) translate([x - po/2, y + (sy > 0 ? d : -d - pocket_wall), tray_t - 0.01]) cube([po, pocket_wall, pocket_wall_h]);
  for (sx = [-1, 1], sy = [-1, 1])
    translate([x + (sx > 0 ? d : -d - pocket_wall), y + (sy > 0 ? d - 1.2 : -d + 0.2), tray_t - 0.01]) cube([pocket_wall, 1.0, pocket_wall_h]);
}
module tray() {
  difference() {
    linear_extrude(tray_t) intersection() { offset(-tray_fit) cavity2d(); translate([-100, y_t0]) square([200, 200]); }
    if (lanyard_d > 0) translate([-2, inner_l - 4, -1]) cube([4, 6, 5]);
  }
  for (s = sws) tray_pocket(s[0], s[1]);
}

// ---------- lids (two pieces, split at step_y) ----------
module lip_ring(front, zb, h, cav_off = 0) translate([0, 0, zb]) linear_extrude(h + 0.01)
  intersection() { difference() { offset(-lid_fit + cav_off) cavity2d(); offset(-lid_fit - lip_t + cav_off) cavity2d(); } half2d(front); }
module finger(s, y, zb, h, xw) {   // xw = half cavity width at this half
  translate([s > 0 ? xw - lid_fit - finger_t : -xw + lid_fit, y - finger_len/2, zb]) cube([finger_t, finger_len, h + 0.01]);
  translate([s > 0 ? xw - lid_fit : -xw + lid_fit - snap_bump, y - snap_len/2, zb + 0.1])
    hull() { translate([s > 0 ? 0 : snap_bump, 0, 0]) cube([0.01, snap_len, 1.2]); translate([s > 0 ? snap_bump - 0.01 : 0, 1, 0.3]) cube([0.01, snap_len - 2, 0.6]); }
}
module relief(front, y, zb, h, xw) for (s = [-1, 1], e = [-1, 1])
  translate([s > 0 ? xw - 3 : -xw, y + e*(finger_len/2 + relief_w/2) - relief_w/2, zb - 1]) cube([3, relief_w, h + 2]);

module lid_front() difference() {   // button half, full height
  union() {
    intersection() { outer3d(); zslab(inner_h, inner_h + lid_t + 1); yslab(true); }
    difference() { lip_ring(true, inner_h - lip_h, lip_h); relief(true, snap_ys[1], inner_h - lip_h, lip_h, inner_w/2); }
    for (s = [-1, 1]) finger(s, snap_ys[1], inner_h - finger_h, finger_h, inner_w/2);
  }
  for (c = caps) translate([c[0], c[1], 0]) {
    translate([0, 0, inner_h - 1]) linear_extrude(lid_t + 2) cap2d(c, fit);
    hull() { translate([0, 0, inner_h + lid_t - win_chamfer]) linear_extrude(0.01) cap2d(c, fit); translate([0, 0, inner_h + lid_t]) linear_extrude(0.01) cap2d(c, fit + win_chamfer); }
  }
  translate([-100, step_y - 100, -1]) cube([200, 100, 50]);   // clean split face
}
module lid_back() difference() {   // palm half, lowered by drop and inset by the neck
  xw = inner_w/2 - neck;
  union() {
    intersection() { outer3d(H_tot - drop, neck); zslab(inner_h_b, inner_h_b + lid_t + 1); yslab(false); }
    difference() { lip_ring(false, inner_h_b - lip_h, lip_h, -neck); relief(false, snap_ys[0], inner_h_b - lip_h, lip_h, xw); }
    for (s = [-1, 1]) finger(s, snap_ys[0], inner_h_b - finger_h_b, finger_h_b, xw);
    // PCB hold-down pillars: two on the bare antenna-end corners, one on the USB shell
    for (s = [-1, 1]) translate([s*(xiao[0]/2 - 1.3) - 1.2, y_pcb1 - pad_free_end, z_pcb_top + 0.15]) cube([2.4, pad_free_end - 0.2, inner_h_b - z_pcb_top - 0.15 + 0.01]);
    translate([-1.5, pcb_setback + 3, z_pcb_top + usb[1] + 0.15]) cube([3, 2, inner_h_b - z_pcb_top - usb[1] - 0.15 + 0.01]);
  }
  translate([reset_pos[0], pcb_setback + reset_pos[1], inner_h_b - 1]) cylinder(d = reset_hole_d, h = lid_t + 2);
  if (led_hole_d > 0) translate([led_pos[0], pcb_setback + led_pos[1], inner_h_b - 1]) cylinder(d = led_hole_d, h = lid_t + 2);
  translate([-100, step_y - 0.2, -1]) cube([200, 100, 50]);   // 0.2 gap to the front lid
}

// ---------- hood: half-length cover with end skirt; z=0 outer face ----------
module hood_region2d(o) intersection() { offset(o) plan2d(); half2d(true); }
module hood_ring2d(o_out, o_in) difference() { hood_region2d(o_out); hood_region2d(o_in); }
module cover() {
  difference() {
    union() {
      hull() {   // plate with a 1 mm 45deg edge on the outer face
        linear_extrude(0.01) hood_region2d(cov_skirt_t + cov_fit - 1.0);
        translate([0, 0, 1.0]) linear_extrude(cov_t - 1.0) hood_region2d(cov_skirt_t + cov_fit);
      }
      translate([0, 0, cov_t - 0.01]) linear_extrude(cov_skirt_h + 0.01) hood_ring2d(cov_skirt_t + cov_fit, cov_fit);   // skirt
      zr = cov_t + cov_groove_z;   // stepped rib
      translate([0, 0, zr - 0.2]) linear_extrude(0.4) hood_ring2d(cov_fit + 0.01, cov_fit - cov_rib);
      translate([0, 0, zr - 0.5]) linear_extrude(0.3) hood_ring2d(cov_fit + 0.01, cov_fit - cov_rib/2);
      translate([0, 0, zr + 0.2]) linear_extrude(0.3) hood_ring2d(cov_fit + 0.01, cov_fit - cov_rib/2);
    }
    translate([-100, -100, -1]) cube([200, 100 + step_y, 20]);                                                      // open end, straight cut at the split
    translate([-cov_notch/2, inner_l + wall - r_plan_far, cov_t]) cube([cov_notch, 50, 20]);                         // USB / lanyard notch
    translate([0, 0, cov_t + cov_skirt_h - 0.6]) linear_extrude(1) hood_ring2d(cov_fit + 0.6, cov_fit - 0.01);        // lead-in
    for (pp = [reset_pos, led_pos]) translate([pp[0], inner_l - pcb_setback - pp[1], -1]) cylinder(d = 2.2, h = 10);   // pinholes when parked
  }
}
module cover_on_top() translate([0, 0, inner_h + lid_t + cov_t]) mirror([0, 0, 1]) cover();                                   // travel
module cover_parked() translate([0, inner_l, inner_h_b + lid_t + cov_t]) mirror([0, 1, 0]) mirror([0, 0, 1]) cover();           // reading: flush on the palm half

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
      hull() { translate([0, 0, flange_t - 0.01]) linear_extrude(cap_h - 0.4) cap2d(c); linear_extrude(zt) cap2d(c, -0.4); }
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
  color("Tan") translate([-xiao[0]/2, y_pcb1 - 3, z_pcb_top]) cube([xiao[0], 3, 1]);
  color("SteelBlue") translate([-batt[0]/2, y_batt0 + batt_fit, 0]) cube([batt[0], batt[1], batt[2]]);
  for (s = sws) {
    color("DimGray") translate([s[0] - sw_body/2, s[1] - sw_body/2, z_shelf]) cube([sw_body, sw_body, sw_h - 1]);
    color("Gray") translate([s[0], s[1], z_shelf + sw_h - 1]) cylinder(d = sw_dome_d, h = 1);
  }
  if (magnet[0] > 0) color("Silver") for (mp = magnet_pos) translate([mp[0], pcb_setback + mp[1], -floor_t + 0.7]) cylinder(d = magnet[0], h = magnet[1]);
}
module plungers(dz = 0) for (c = caps) translate([c[0], c[1], inner_h - flange_t + dz]) plunger(c);
module lids() { color("LightSteelBlue") lid_front(); color("LightSteelBlue") lid_back(); }
module label(t, p, z = 30) color("Black") translate([p[0], p[1], z]) linear_extrude(0.5) text(t, size = 2.2, halign = "center", valign = "center");
module cut(x, c) color(c) mirror([1, 0]) rotate(90) projection(cut = true) rotate([0, 90, 0]) translate([-x, 0, 0]) children();

// ---------- fit coupon: the button end only ----------
y_cpn = yp - max(po/2, 5) - 2;
module coupon() intersection() { children(); translate([-100, y_cpn, -50]) cube([200, 200, 100]); }

// ---------- dispatch ----------
if (part == "base") translate([0, 0, floor_t]) base();
if (part == "lid_front") mirror([0, 0, 1]) translate([0, 0, -inner_h - lid_t]) lid_front();      // printed top-down
if (part == "lid_back") mirror([0, 0, 1]) translate([0, 0, -inner_h_b - lid_t]) lid_back();     // printed top-down
if (part == "tray") tray();
if (part == "cover") translate([0, 0, cov_t + cov_skirt_h]) mirror([0, 0, 1]) cover();          // printed outer face up, skirt on the bed
if (part == "plunger_next") plunger(next_cap);
if (part == "plunger_prev") if (!is_undef(prev_cap)) plunger(prev_cap);
if (part == "coupon_base") translate([0, -y_cpn, floor_t]) coupon() base();
if (part == "coupon_lid") mirror([0, 0, 1]) translate([0, -y_cpn, -inner_h - lid_t]) coupon() lid_front();
if (part == "coupon_tray") translate([0, -y_cpn, 0]) coupon() tray();
if (part == "assembly") { color("Khaki") base(); color("Wheat") translate([0, 0, z_ledge]) tray(); lids(); color("Tomato") plungers(); hw(); }
if (part == "assembly_cover") { color("Khaki") base(); lids(); color("Tomato") plungers(); color("SlateGray") cover_on_top(); }
if (part == "assembly_stored") { color("Khaki") base(); lids(); color("Tomato") plungers(); color("SlateGray") cover_parked(); }
if (part == "exploded") { color("Khaki") base(); hw(); color("Wheat") translate([0, 0, z_ledge + 10]) tray(); translate([0, 0, 24]) lids(); color("Tomato") plungers(36); }
if (part == "section" || part == "section_mag") { x = part == "section" ? next_cap[0] : magnet_pos[1][0];
  cut(x, "SlateGray") cover_parked(); cut(x, "Khaki") base(); cut(x, "Wheat") translate([0, 0, z_ledge]) tray(); cut(x, "LightSteelBlue") lid_front(); cut(x, "LightSteelBlue") lid_back(); cut(x, "Tomato") plungers(); cut(x, "DimGray") hw(); }
if (part == "layout") {
  color("Khaki") base(); hw(); color("Wheat", 0.6) translate([0, 0, z_ledge]) tray(); color("Tomato", 0.5) plungers();
  label("XIAO nRF52840", [0, pcb_setback + 9]); label("USB-C", [0, -4]);
  label("reset", [reset_pos[0], pcb_setback + reset_pos[1] + 2.5]); label("LED", [led_pos[0], pcb_setback + led_pos[1] - 2.5]);
  if (magnet[0] > 0) label("magnets (below PCB)", [0, pcb_setback + magnet_pos[0][1] - 3.5]);
  label("antenna end / keepout", [0, y_pcb1 + 1.5]); label("lid split / hood edge", [0, step_y]); label("battery under tray", [0, inner_l - 3]);
  if (len(caps) > 1) { label("PREV", caps[0]); label("NEXT", caps[1]); }
  else { label("NEXT (far end)", [0, caps[0][1] + 7]); label("PREV (near end)", [0, caps[0][1] - 7]); }
}
