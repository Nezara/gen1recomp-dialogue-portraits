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

Sources are in `../pokemon_raw/` at their original 40x40 / 48x48 / 56x56.
Only three fit the slot at 1x untouched (`voltorb`, `spearow`, `nidoranf`) —
the rest need redrawing rather than scaling. `../pokemon_raw/README.md` has
the per-species measurements and the one composition decision worth making
before you start.

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
