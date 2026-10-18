#!/bin/sh
# Export STLs (one per printable part) and PNG previews.
set -e
cd "$(dirname "$0")"
S=page_turner.scad
for p in base lid plunger_next plunger_prev; do
  openscad -q --backend=manifold -o "stl/$p.stl" -D "part=\"$p\"" $S
done
png() { openscad -q -o "renders/$1.png" -D "part=\"$2\"" --imgsize=1400,1000 --projection=o --viewall --autocenter --camera="0,0,0,$3,0" --colorscheme=Tomorrow $S; }
png top        assembly   0,0,0
png layout     layout     0,0,0
png iso        assembly   55,0,25
png bottom     base       180,0,0
png base_inside base      0,0,0
png lid_inside lid        180,0,0
png exploded   exploded   60,0,30
png section    section    0,0,0
png lid_print  lid        55,0,25
png switch_zoom base      55,0,25
png plungers   plunger_prev 55,0,25
