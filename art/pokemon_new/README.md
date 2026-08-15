# Pokémon masters — the editable copy

Hand-made grayscale portraits, **one per species**, named after the ROM's own
front-sprite basename so raw → master → shipped all share a filename:
`pikachu.png`, `nidoranm.png`, `nidoranf.png`, `wigglytuff.png`, ...

This is the mirror of `trainers_new/`, and the same rule applies, for the same
reason:

> **Edit in grayscale here, recolor LAST into `../pokemon/`.**

The recolor buckets each pixel by its red channel (>211 / >127 / >43), which
is only correct on the ROM's four flat grays. It is *not* safely re-runnable
on its own output — BROWNMON's midtone is `(230,165,123)` and R=230 is above
the 211 threshold, so a second pass reads tan as white. **These masters are
the only re-editable copy.** See `../trainers/README.md` for the script and
the palette values; it works unchanged on this folder, just point `$srcDir`
here and drop the crop (see "size" below).

## Size

Target **30x30**, same as the trainer masters. The slot is 32x32, so anything
up to 32x32 lands at a clean 1x with a pixel or two of padding; past 32 the
scale goes fractional and the art comes off the pixel grid. 30x30 keeps a
little breathing room and matches what is already shipping.

Sourced from `red/assets/generated/battle/front/<name>.png` (reproducible
from any Red ROM via the engine's own extractor — not versioned in this repo;
see the root README's "Assets and licensing"), at their original 40x40 /
48x48 / 56x56. Unlike the trainer set's uniform 56x56, Pokémon front art
isn't one size, and the creature fills nearly all of it — there's no body to
crop away the way there is on a trainer. Measured content bounding boxes
against the 32x32 slot:

| | |
|---|---|
| Fit at 1x, no scaling needed | `voltorb` (25x25), `spearow` (32x32), `nidoranf` (31x26) |
| Near miss, 0.8–0.97x | `pidgey`, `nidoranm`, `jigglypuff`, `clefairy`, `meowth`, `cubone`, `psyduck`, `pikachu`, `slowpoke`, `machop`, `doduo`, `kabuto` |
| Half size, 0.57–0.73x | `slowbro`, `lapras`, `snorlax`, `kangaskhan`, `rhydon`, `pidgeot`, `fearow`, `poliwrath`, `machoke`, `chansey`, `seel`, `wigglytuff`, `nidorino` |

Any of those fractional scales lands the pixel grid off whole pixels, which is
what `blitArt` avoids by only flooring a scale of 1 or more — so all but the
three above want a hand pass, not a script.

Worth deciding once, before drawing 27 of them: **a Pokémon's whole silhouette
is what identifies it**, so the trainer set's "crop to a head-and-shoulders
bust" instinct probably does not transfer. A shrunk-but-whole creature is
likely to read better than a cropped head, except for the few big ones
(Lapras, Kangaskhan, Rhydon) where the head alone might be the stronger
picture. Try both on one species before committing to a rule.

## What's wanted

26 species have a talking overworld NPC:

`chansey` `clefairy` `cubone` `doduo` `fearow` `jigglypuff` `kangaskhan`
`lapras` `machoke` `machop` `meowth` `nidoranf` `nidoranm` `nidorino`
`pidgeot` `pidgey` `pikachu` `poliwrath` `psyduck` `seel` `slowbro`
`slowpoke` `snorlax` `spearow` `voltorb` `wigglytuff`

(`snorlax` is the pair blocking Routes 12 and 16 — "A sleeping POKéMON blocks
the way!" is an ordinary text box, not the battle.)

Two more are Bill-only — he is randomly one of four Pokémon per save, and
`clefairy` / `nidoranm` are already in the list above:

`rhydon` `kabuto`

Nothing here is required. The mod loads each file independently and caches the
miss, so a species with no portrait yet simply shows none, exactly like an
NPC with no art — drop them in one at a time and they light up as they land.
