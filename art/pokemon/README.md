# Pokémon portraits — what the mod actually loads

One PNG per species, named after the ROM's own front-sprite basename
(`pikachu.png`, `nidoranm.png`, ...). Resolved at runtime from the species
record's `spriteFront` field, so the filename is never guessed — exactly how
`../trainers/` is resolved from a trainer class's `pic`.

**This folder is output.** It is `../pokemon_new/` after the BROWNMON recolor,
and the recolor is one-way — it cannot be re-run on its own result. Edit the
masters, never these. The script and the palette values are in
`../trainers/README.md`; it works unchanged here, just point `$srcDir` at
`../pokemon_new` and drop the crop step, since the masters are already at
their final size.

All 28 wanted species (see `../pokemon_new/README.md`) are in. The art was
drawn by hand (see `../pokemon_raw/README.md` for why it can't be batched the
way the 45 trainers were) and then run through the same recolor-only pass.
Each file is still loaded independently with the miss cached, so if more
species masters land later they light up the same way, one at a time.

**These are drawn facing left**, which reads correctly at the default
right-side placement (the speaker faces in, towards the text). `main.lua`
tags every image loaded from this folder `directional = true` and mirrors it
horizontally — `blitArt` for INSET/FRAMED, `drawMarginPanel` for MARGIN —
whenever the box actually lands on the left, whether from `SIDE = auto` or a
player-forced left. Trainer art has no such tag and is never flipped; it's a
front-on battle pose with no facing to get wrong.

## Which NPC gets which file

The species is taken from the map object's own `name` — `CELADONMANSION1F_MEOWTH`,
`FUCHSIACITY_LAPRAS` — not from its overworld sprite, because only five
Pokémon sprites cover all 27 objects. Strip the map prefix, look the tail up
in `game.data.pokemon`, and the ROM has answered. Three names the ROM doesn't
spell as a species key are hand-mapped in `main.lua`'s `MON_NAME_FIX`.

A player who wants to override one of these, or add a portrait for a species
with no NPC at all, can still drop `portraits/<SPECIES>.png` in the mod root —
that path wins over everything, including this folder.
