// Scenes for the build guide (../guide/). ./guide.sh renders them.
include <page_turner.scad>
part  = "none";
scene = "done";   // plate | coupon | tray_sw | base_pcb | knob_in | tray_in | lid_caps | done | side
$fn = 64;

C_case = "#d3ccc0"; C_tray = "#e8e1d4"; C_cap = "#d9662e"; C_knob = "#d9662e";
C_pcb = "#2f6b4f"; C_metal = "#b9bec4"; C_batt = "#8c98a6"; C_sw = "#2b2b2b"; C_dome = "#8a8a8a";

module m_pcb() { color(C_pcb) translate([-xiao[0]/2, pcb_setback, z_pcb]) cube([xiao[0], xiao[1], xiao[2]]);
                 color(C_metal) translate([-usb[0]/2, pcb_setback - usb_overhang, z_pcb_top]) cube([usb[0], usb_len, usb[1]]); }
module m_batt() color(C_batt) translate([-batt[0]/2, y_batt0 + batt_fit, 0]) cube([batt[0], batt[1], batt[2]]);
module m_tact(dz = 0) for (s = sws) translate([0, 0, dz]) {
  color(C_sw) translate([s[0] - sw_body/2, s[1] - sw_body/2, z_shelf]) cube([sw_body, sw_body, sw_h - 1]);
  color(C_dome) translate([s[0], s[1], z_shelf + sw_h - 1]) cylinder(d = sw_dome_d, h = 1); }
module m_psw(on = true) mirror([psw_side < 0 ? 1 : 0, 0, 0]) {   // SS12D00: metal shell, black handle
  color(C_metal) translate([psw_xi, psw_y - psw[0]/2, psw_z0]) cube([psw[1], psw[0], psw[2]]);
  color(C_sw) translate([psw_xo - 0.01, psw_y + (on ? 1 : -1)*psw_travel/2 - psw_handle[0]/2, psw_zc - psw_handle[1]/2]) cube([psw_handle[2] + 0.01, psw_handle[0], psw_handle[1]]); }
module flip() mirror([0, 0, 1]) translate([0, 0, -inner_h - lid_t]) children();

if (scene == "plate") {
  color(C_case) translate([0, 0, floor_t]) base();
  color(C_case) translate([32, 0, 0]) flip() lid();
  color(C_tray) translate([64, -20, 0]) tray();
  color(C_cap) translate([70, 52, 0]) plunger(next_cap);
  color(C_cap) translate([86, 40, 0]) plunger(prev_cap);
  for (i = [0:2]) color(C_knob) translate([60 + i*12, 66, 0]) knob();
}
if (scene == "coupon") {
  color(C_case) translate([0, -y_cpn, floor_t]) coupon() base();
  color(C_case) translate([32, -y_cpn, 0]) flip() coupon() lid();
  color(C_tray) translate([64, -y_cpn, 0]) coupon() tray();
  color(C_cap) translate([92, 14, 0]) plunger(next_cap);
  color(C_cap) translate([92, -2, 0]) plunger(prev_cap);
  color(C_case) translate([-2, -62, floor_t]) coupon_usb() base();
  color(C_case) translate([30, -62, 0]) flip() coupon_usb() lid();
  color(C_knob) translate([60, -50, 0]) knob();
}
if (scene == "tray_sw") { color(C_tray) translate([0, 0, z_ledge]) tray(); m_tact(); }
if (scene == "base_pcb") { color(C_case) base(); m_pcb(); m_batt(); }
if (scene == "knob_in") {   // cut-away from inside: the knob through the window, the switch seated on its handle
  color(C_case) intersection() { base(); translate([0, psw_y - 14, -10]) cube([30, 28, 40]); }
  m_pcb(); color(C_knob) knob_placed(false); m_psw(false);
}
if (scene == "tray_in") { color(C_case) base(); m_pcb(); m_batt(); m_psw(); color(C_knob) knob_placed(); color(C_tray) translate([0, 0, z_ledge]) tray(); m_tact(); }
if (scene == "lid_caps") { color(C_case) flip() lid(); color(C_cap) flip() plungers(); }
if (scene == "done" || scene == "side") { m_pcb(); color(C_case) base(); color(C_case) lid(); color(C_cap) plungers(); color(C_knob) knob_placed(); }
