#!/bin/sh
# Render the build-guide images into ../guide/img (needs openscad and python3 with Pillow).
set -e
cd "$(dirname "$0")"
OUT=../guide/img; mkdir -p "$OUT"
PY=${PY:-python3}
shot() {   # name camera(rotx,roty,rotz)
  openscad -q --backend=manifold --render -o "$OUT/$1.raw.png" -D "scene=\"$1\"" --imgsize=2400,1800 --projection=o --viewall --autocenter --camera="0,0,0,$2,0" --colorscheme=Tomorrow guide.scad
  $PY - "$OUT/$1.raw.png" "$OUT/$1.png" <<'PY'
import sys
from PIL import Image
im = Image.open(sys.argv[1]).convert("RGBA"); bg = im.getpixel((0, 0))
px = im.load(); w, h = im.size
for y in range(h):
    for x in range(w):
        if px[x, y][:3] == bg[:3]: px[x, y] = (0, 0, 0, 0)
bb = im.getbbox(); m = 40
im = im.crop((max(0, bb[0]-m), max(0, bb[1]-m), min(w, bb[2]+m), min(h, bb[3]+m)))
im.resize((im.width//2, im.height//2), Image.LANCZOS).save(sys.argv[2], optimize=True)
PY
  rm "$OUT/$1.raw.png"
}
shot plate    55,0,25
shot coupon   55,0,25
shot tray_sw  50,0,30
shot base_pcb 55,0,25
shot knob_in  70,0,250
shot tray_in  55,0,25
shot lid_caps 50,0,30
shot done     55,0,25
shot side     80,0,75
