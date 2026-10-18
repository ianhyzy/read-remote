#!/bin/sh
# Export STLs and PNG previews for one variant: ./render.sh [variant]   (default: dishdome)
set -e
cd "$(dirname "$0")"
V=${1:-dishdome}; S=page_turner.scad
mkdir -p "stl/$V" "renders/$V"
for p in base lid plunger_next plunger_prev; do
  openscad -q --backend=manifold -o "stl/$V/$p.stl" -D "variant=\"$V\"" -D "part=\"$p\"" $S || rm -f "stl/$V/$p.stl"   # a variant may have no plunger_prev
done
png() { openscad -q -o "renders/$V/$1.png" -D "variant=\"$V\"" -D "part=\"$2\"" --imgsize=1400,1000 --projection=o --viewall --autocenter --camera="0,0,0,$3,0" --colorscheme=Tomorrow $S; }
png top      assembly 0,0,0
png layout   layout   0,0,0
png iso      assembly 55,0,25
png exploded exploded 60,0,30
png section  section  0,0,0
png caps     plunger_next 55,0,25
png base_iso base     55,0,25
