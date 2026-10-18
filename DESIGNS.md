# Button layout research and options

## What the market and reviews say

Sources: Kobo Remote reviews (Good e-Reader, The Gadgeteer, Digital Reviews, Chatelaine, TechRadar), Datafy / SK Syukuyu / Sycelu / Oresoc clip-on RF clickers (Amazon listings, TabletSage, MomAdvice, CNN Underscored), ADZERD and Datafy ring remotes, Kindle Oasis and Kobo Libra reviews (Tom's Guide, Android Central, T3, Teleread), Apple TV Siri Remote coverage, Sony remote accessibility notes.

**Forms that exist**
- **Big + small stacked buttons** (Kobo Remote, Logitech presenters): large round forward button on top with a thumb dimple, small round back button under it. Reviewers: "thumb indentation naturally centres the thumb over the forward button", clicks "satisfying" but loud enough that coworkers noticed.
- **Single big pad clicker** (Datafy, Syukuyu, Sycelu, Oresoc, 5k–13k Amazon ratings each): one oval pad in a thumb dip, silent silicone buttons, wrist strap. Most common complaint after reliability: **forward only, no back**. Praised: "unbelievably light", works through blankets, finger-agnostic.
- **Rings** (Datafy ring, ADZERD): no grip needed, good for side-sleepers under covers, but "reliability more variable", stress marks, fit issues.
- **Side bars on the reader** (Kindle Oasis, Kobo Libra): two bars where the thumb rests, "near-millimetre thumb movement turns the page", a "small lip beside the buttons helps the thumb rest". Which bar is forward is a setting; nobody complains about telling them apart because position does it.

**Lessons that apply here**
1. **Orientation by feel is the whole game.** The original Apple TV Siri Remote was symmetric and people picked it up backwards "50 percent of the time"; the fix was an asymmetric layout you can feel. Our case is a plain rectangle, so the buttons (and ideally the case) must break symmetry.
2. **Forward gets the prime spot and the bigger target.** Every two-button product makes forward bigger and puts it where the thumb rests. Back is rare, so it can be smaller and need a deliberate reach.
3. **Silent matters.** The one hardware complaint about the Kobo Remote is click noise. Our silent domes already fix this.
4. **Lanyard / wrist strap is universally liked.** Added a 2.2 mm lanyard hole in the far end wall of every variant.
5. **Tactile markers:** industry practice (Sony, patents) is a single dot or pip on one button, or concave vs convex halves, not bars. A raised dot on F/J keys is the most familiar version.
6. **A thumb dish beats a flat pad**: the Kobo and clip-on clickers all dish the forward button so the thumb self-centres.

## The seven options

All share the same pebble base (XIAO + battery + wiring), the same 3 mm lid with recessed caps, and the same silent switch pockets. The trigger variant flattens the far end to r6 so its end button has a flat wall. PREV always sits nearer the USB end (the battery dictates where the first switch can go); NEXT sits at the far end where the thumb rests. Render with `./render.sh <variant>`.

| # | `variant` | NEXT | PREV | Tells them apart | Case L×W | Notes |
|---|---|---|---|---|---|---|
| 1 | `kobo` (default) | 16.6 × 17, follows the rounded end, **dished** | 10 mm **round dome** | size, shape, concave vs convex | 61 × 25 | Closest to the Kobo Remote. Strongest "which is which" cue. |
| 2 | `rocker` | far half of one 28 mm seesaw cap, dished | near end of same cap, raised dot | position + dot | 61 × 25 | One moving part, feels like a rocker. Small cross-talk risk: pressing one end loads the other dome ~10 %; test before committing. |
| 3 | `dishdome` | 16.6 × 13 **dished** | 16.6 × 13 **domed** (peaks 0.3 mm above lid) | concave vs convex | 60 × 25 | Equal-size targets, no bar. Dome is findable under a blanket. |
| 4 | `bars` | 16.6 × 19 flat | 16.6 × 9 flat | length | 64 × 25 | Oasis-style. Simplest to print. Weakest cue in the dark. |
| 5 | `sidebyside` | right bar, dished | left bar, domed | left/right + concave/convex | 56 × 33 | Wider, shorter, more "remote"-like; handedness fixed at print time. |
| 6 | `trigger` | one 16.6 × 18 dished pad on top | 8 × 5 button in the **far end wall**, index finger | different finger, different face | 57 × 25 | Impossible to confuse. Back needs a deliberate squeeze. Most parts. |
| 7 | `dot` | 16.6 × 13 flat | 16.6 × 13 with a **centre dot** | one dot | 60 × 25 | Keyboard F/J approach. Minimal, both faces smooth except the dot. |

Mix and match: every cap style (`flat`, `dish`, `dome`, `dot`) works with every layout; edit the `caps` table in `page_turner.scad`.
