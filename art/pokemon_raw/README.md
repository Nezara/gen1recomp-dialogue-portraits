# Raw source — do not edit

Verbatim copies of `red/assets/generated/battle/front/<name>.png` for the
species this mod wants a portrait for. Reproducible from any Red ROM via the
engine's own extractor, and a straight copy of Nintendo's art rather than a
derivative work — versioned anyway (since 1.0.0), so a fork doesn't need its
own ROM and extractor run just to start hand-editing a master. See
[`../trainers_raw/README.md`](../trainers_raw/README.md) for the trainer set's
equivalent, and the root [`README.md`](../../README.md)'s "Assets and
licensing" section for what that means for this repo.

28 files: the 26 species that have a talking overworld NPC, plus RHYDON and
KABUTO, which only appear as two of Bill's four possible forms.

Not included, though the lookup resolves them and they would light up if you
ever drew them: MEWTWO, ZAPDOS, ARTICUNO and MOLTRES. Each shows a cry and a
line of text before its battle starts, so they are portrait-capable — they
were just not part of the "talking NPC" ask.

## Why these can't be batch-cropped like the trainers were

The trainer set was mechanical: every source file is 56x56, so one crop
fraction produced all 45 portraits at a clean 1x. Pokémon front art is not
uniform — it is **40x40, 48x48 or 56x56** depending on species — and the
creature fills nearly all of it, because unlike a trainer there is no body to
crop away. Measured content bounding boxes against the 32x32 slot:

| | |
|---|---|
| Fit at 1x, no scaling needed | `voltorb` (25x25), `spearow` (32x32), `nidoranf` (31x26) |
| Near miss, 0.8–0.97x | `pidgey`, `nidoranm`, `jigglypuff`, `clefairy`, `meowth`, `cubone`, `psyduck`, `pikachu`, `slowpoke`, `machop`, `doduo`, `kabuto` |
| Half size, 0.57–0.73x | `slowbro`, `lapras`, `snorlax`, `kangaskhan`, `rhydon`, `pidgeot`, `fearow`, `poliwrath`, `machoke`, `chansey`, `seel`, `wigglytuff`, `nidorino` |

Any of those fractional scales lands the pixel grid off whole pixels, which is
what `blitArt` avoids by only flooring a scale of 1 or more. So these want a
hand pass, not a script — which is what `pokemon_new/` is for.

Worth deciding once, before drawing 27 of them: **a Pokémon's whole silhouette
is what identifies it**, so the trainer set's "crop to a head-and-shoulders
bust" instinct probably does not transfer. A shrunk-but-whole creature is
likely to read better than a cropped head, except for the few big ones
(Lapras, Kangaskhan, Rhydon) where the head alone might be the stronger
picture. Try both on one species before committing to a rule.
