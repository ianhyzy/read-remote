// Visual concepts for travel protection on a simplified solid pebble (no internals). Proportions only.
include <page_turner.scad>
part = "none";   // must come after the include to override its default
concept = "pebble";   // pebble | pencap | hood | channel
state   = "closed";   // closed (travel) | open (reading)
L  = inner_l + wall;  // far end (y)
CL = 31;              // cover length
Zt = inner_h + lid_t; // top face

module yrange(y0, y1) translate([-50, y0, -20]) cube([100, y1 - y0, 60]);
module caps_cut(dz = 0) for (c = caps) translate([c[0], c[1], Zt - dz - cap_recess - cap_h]) linear_extrude(10) cap2d(c, fit);
module caps_mock(dz = 0) color("Tomato") for (c = caps) translate([c[0], c[1], Zt - dz - cap_recess - cap_h]) linear_extrude(cap_h) cap2d(c);
module pinholes(dz = 0) color("Black") for (pp = [reset_pos, led_pos]) translate([pp[0], pcb_setback + pp[1], Zt - dz - 0.3]) cylinder(d = 2, h = 1);
module at_back() translate([0, inner_l, 0]) mirror([0, 1, 0]) children();   // mirror a far-end feature to the USB end

// ---- 1: pure pebble ----
module c_pebble() { color("LightSteelBlue") difference() { outer3d(); caps_cut(); } caps_mock(); pinholes(); }

// ---- 2: pen cap: closed cup slides over the button end; the body has a shallow band at both ends so it sits flush ----
band = 1.35;
module c_pencap() {
  module band_cut(y0, y1) difference() { yrange(y0, y1); outer3d(H_tot - band, band); }   // material outside the reduced profile
  color("LightSteelBlue") render() difference() { outer3d(); band_cut(L - CL, L + 1); band_cut(-wall - 1, CL - wall); caps_cut(band); }
  if (state == "open") caps_mock(band);
  pinholes(band);
  module cap() render() intersection() { difference() { outer3d(); outer3d(H_tot - band - 0.15, band + 0.15); } yrange(L - CL, L + 1); }
  color("SlateGray") if (state == "closed") cap(); else at_back() cap();
}

// ---- 3: sliding hood: U-channel riding on the body, inward lips in a groove along each side; slides back to front ----
hood_t = 2.0; skirt = 1.2; skirt_d = 6;
module c_hood() {
  color("LightSteelBlue") difference() {
    outer3d(); caps_cut();
    for (s = [-1, 1]) translate([s*(inner_w/2 + wall) - 0.6, 2, Zt - skirt_d + 1.5]) cube([1.2, L - 4, 1.2]);   // side groove, full length
  }
  caps_mock(); pinholes();
  module hood() intersection() {
    difference() { outer3d(H_tot + hood_t, -skirt); outer3d(H_tot + 0.2, 0.15); translate([0, 0, -skirt_d - hood_t]) outer3d(H_tot, 1); }
    translate([0, 0, Zt - skirt_d]) linear_extrude(hood_t + skirt_d + 1) offset(skirt) plan2d();
    yrange(L - CL, L + 2);
  }
  color("SlateGray") if (state == "closed") hood(); else at_back() hood();
}

// ---- 4: channel slider: side walls rise past the lid with an inward hook; the hood plate slides flush inside them ----
ch_h = 2.2; ch_w = 1.6; hook = 0.8; plate_t = 1.8;
module c_channel() {
  color("LightSteelBlue") difference() {
    outer3d(H_tot + ch_h);                                                            // body with taller walls
    translate([0, 0, Zt]) linear_extrude(10) offset(-ch_w) plan2d();                  // channel between the walls
    caps_cut();
  }
  color("LightSteelBlue") for (s = [-1, 1]) intersection() {                           // inward hooks
    translate([0, 0, Zt + ch_h - 0.8]) linear_extrude(0.8) difference() { offset(-ch_w + hook) plan2d(); offset(-ch_w - 1) plan2d(); }
    translate([s > 0 ? 0 : -50, -50, 0]) cube([50, 200, 50]);
  }
  caps_mock(); pinholes();
  module plate() translate([0, 0, Zt + 0.2]) linear_extrude(plate_t) intersection() { offset(-ch_w - 0.15) plan2d(); translate([-50, L - CL]) square([100, CL]); }
  color("SlateGray") if (state == "closed") plate(); else at_back() plate();
}

if (concept == "pebble") c_pebble();
if (concept == "pencap") c_pencap();
if (concept == "hood") c_hood();
if (concept == "channel") c_channel();

