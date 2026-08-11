# Dialogue Portraits
-- Created with AI/Vibe Coded --

A face beside the words. Talk to someone and their portrait appears next to
the dialogue box.

## Options

| Option | Values | What it does |
|---|---|---|
| `PORTRAIT` | **INSET** / MARGIN / OFF | Where the portrait goes |
| `SIDE` | **LEFT** / RIGHT | Which side of the screen |

Portraits are an overworld feature. A trainer's pre- and post-battle speech
both happen out in the overworld — the battle pushes after the challenge and
pops before the defeat line — so both get a portrait like any other box. Text
drawn during the battle itself never does.

### INSET 

Takes six tiles off the left (or right) of the dialogue box and puts a framed
Game Boy panel there. It is drawn inside the 160x144 canvas, so it gets the
palette and the GBC filter along with everything else — it looks like part of
the game.

The cost is six columns of text: lines wrap at 12 characters instead of 18, so
conversations run to more pages.

A box with no identifiable speaker, or whose speaker has no portrait, is left
completely alone — full width, same wrapping, byte-identical to vanilla.

### MARGIN (currently broken, will fix in next release)

Paints the portrait out in the letterbox beside the play area, so the dialogue
box keeps all 18 columns. It always draws at the same pixel scale as the game
itself — the same size INSET's crop would appear at — rather than shrinking to
fit whatever margin exists.

That means how it looks depends on window size. At a wide enough window
(roughly 1280px+) there's enough letterbox for it to sit fully beside the play
area, and this is MARGIN at its best: full-width text and a clean, dedicated
spot for the portrait. At a narrower window (1024x768 default) the margin
usually isn't wide enough to hold the portrait at full size, so it moves
instead of shrinking — sitting just above the dialogue box, straddling the
play area's edge. It still never covers the text, but it can cover some of the
world behind it.

Because this draws over the finished frame rather than into the Game Boy
canvas, it does not get the palette or the LCD grid either way — it reads as
an overlay sitting next to the game rather than as part of it. Given that,
INSET is the more consistently polished choice at typical window sizes; MARGIN's
real advantage — not losing six text columns — is most worth it once the
window is wide enough for it to sit cleanly in the letterbox.

## Which picture you get

1. **Your own art**, if you supply it (see below) — for anyone, whether or
   not they have a battle portrait.
2. **The trainer class's battle pic** — a bust, pre-cropped to a centered
   top-square slice and shipped in this mod's own `art/trainers/` folder
   (see that folder's README for the exact crop). Which class it is, is
   exact, not a guess — the map object itself names its `trainerClass`, and
   that class names its own `pic`.
3. **A named character's battle pic**, same pre-cropped art, for a short
   hand-checked list covering story characters with no `trainerClass` of
   their own (Oak, the rival, the Elite Four, Giovanni, Rocket grunts, and a
   few trainer classes whose overworld sprite is unambiguous).

That's it. **Nobody else gets a portrait.** Roughly 45 of the game's trainer
classes have battle art; everyone outside that set — regular townsfolk,
family, most named side characters — gets none, on purpose. The earlier
alternative (cropping their own overworld sprite's face) was a worse picture
of them, not a better fallback, so it was dropped.

The short list in step 3 is deliberately conservative. The vanilla
sprite-to-class mapping is many-to-one (`SPRITE_SUPER_NERD` alone backs Super
Nerd, Pokemaniac, Burglar, Engineer, Rocker *and* Brock), so anything
ambiguous is left out rather than guessed.

Signs, item balls, and the rest of the scenery never get a portrait.

**On color:** the ROM's battle art has none of its own — there is no
per-character color hiding in the data to recover. (The one place a real
battle *does* tint a trainer's walk-in pic is borrowed from whichever
Pokémon happens to be leading their team that fight, which isn't a color
belonging to the trainer at all, and would look inconsistent used here.)
What's baked in instead is BROWNMON — a real palette from this game's own
data, the one vanilla uses for brown-family species like Diglett and
Dragonite — applied uniformly to all 45: warm off-white paper, tan midtone,
brown shadow, near-black outline, close to a sepia photograph. (An earlier
pass used GRAYMON, the palette vanilla uses for Ditto/Eevee, and it read as
washed out — GRAYMON's whole job is signaling "no real color," so its
midtone sits deliberately pale; BROWNMON keeps almost the same brightness
steps at real saturation instead.) Not a claim about anyone's "true" color,
just one sourced, consistent palette standing in for one. See
`art/trainers/README.md` to change it.

## Portrait art status — work in progress

The 45 baked portraits started life as a mechanical pass: an automated
30x30 crop of each ROM battle sprite, recolored with BROWNMON. That gets a
face in the box for everyone, but a fixed crop can't frame 45 different
poses well, so they're being replaced by hand a few at a time.

**23 of 45 done.** The hand-edited ones so far:

`agatha` `beauty` `biker` `birdkeeper` `blackbelt` `blaine` `brock` `bruno`
`bugcatcher` `burglar` `channeler` `cooltrainerf` `cooltrainerm` `cueball`
`engineer` `erika` `fisher` `gambler` `gentleman` `giovanni` `hiker`
`prof.oak` `rival1`

**22 still on the original automated crop.** These work and are not broken —
they're just not hand-framed yet:

`jr.trainerf` `jr.trainerm` `juggler` `koga` `lance` `lass` `lorelei`
`lt.surge` `misty` `pokemaniac` `psychic` `rival2` `rival3` `rocker`
`rocket` `sabrina` `sailor` `scientist` `supernerd` `swimmer` `tamer`
`youngster`

### How the art pipeline works

`art/trainers_new/` holds the **grayscale masters** — the editable source.
`art/trainers/` holds what the mod actually loads, which is those masters
after the BROWNMON recolor.

**Edit in grayscale, recolor last.** The recolor buckets each pixel by its
red channel (>211 / >127 / >43), which is only correct on the ROM's four flat
grays. It is *not* safely re-runnable on its own output — BROWNMON's own
midtone is `(230,165,123)`, and R=230 is above the 211 threshold, so a second
pass would read those tan pixels as white. The masters are therefore the only
re-editable copy; the recolored files are one-way output.

Current masters are 30x30. The INSET panel's interior is 32x32, so there are
**2px spare in each dimension** — anything up to 32x32 still lands at a clean
1x. Past 32 the scale goes fractional and the pixel art comes off the grid.

The regeneration script and the exact palette values are in
[`art/trainers/README.md`](art/trainers/README.md).

## Custom art

Drop PNGs in a `portraits/` folder inside this mod, named after either the
trainer class or the overworld sprite:

```
portraits/OPP_BROCK.png
portraits/SPRITE_OAK.png
portraits/SPRITE_NURSE.png
```

This is the way to give a portrait to anyone the mod doesn't cover on its own
— Mom, a gym guide, any NPC with no battle art. Any size works — it's centred
and scaled to fit, snapping to a whole scale whenever it fits at one. Trainer
class is checked first, then sprite. Custom art beats everything else, in
both layouts, and is used uncropped exactly as supplied.

## How the speaker is identified

1. **The dialogue's own "NAME: " prefix**, when there is one. Some of the
   ROM's own text literally names its speaker — `"OAK: {PLAYER}!"`,
   `"{RIVAL}: Fwahaha!"` — extracted straight from the game, not added by
   this mod. This is checked first and, when it finds a name, its answer
   wins outright — even down to "show nothing" if that named speaker has no
   art — because it can catch something the NPC-based lookup below
   structurally can't: one running script handing dialogue back and forth
   between two characters (Oak talks, then the rival cuts in, same script),
   which a single tracked NPC has no way to represent box to box. Only OAK,
   the rival, and KOGA have art wired up to this by default (see
   `art/trainers/README.md` and `main.lua`'s `NAME_ART` table) — most named
   speakers in this game are one-off narrative characters (BILL, MR.FUJI,
   a ship's CAPTAIN) with no battle portrait to give them; drop one in
   `portraits/<NAME>.png` (plain name, no `SPRITE_`/`OPP_` prefix) to add
   more.
2. **The running map script's own NPC**, when the text named nobody and a
   script is active. A scripted conversation is handed its NPC by the
   engine itself (`ScriptRunner.ctx.npc`), so this is exact — not a guess —
   for anything a hand-ported script drives.
3. **The player's facing cell**, for plain talk that never touches a script
   (including the counter hop that lets a mart clerk or nurse work across a
   desk tile).
4. **The last NPC the engine announced**, remembered for 15 seconds, for
   anything none of the above catches — a script that auto-triggers with
   no NPC of its own, say.

## Known limits

- **`{RIVAL}: ` only resolves where some object names his stage.** The text
  says "the rival" but not which of his three outfits, so this reads the
  stage off an object that states it outright: the candidate NPC when that's
  a rival battle object, otherwise the current map's own rival object. Only
  Oak's Lab and the S.S. Anne have one of those (both `OPP_RIVAL1`), so his
  other scenes — Cerulean, Pokémon Tower 2F, Silph 7F, Route 22, the
  Champion's room — still show nothing, since their battles are started by
  script and the object names no class to read. Better that than an outfit
  two fights out of date.
- **A script with no NPC in its own trigger** (an auto-fired cutscene rather
  than one reached by talking to someone) skips straight to the 15-second
  memory fallback, which can miss or lag if the encounter takes longer than
  that or hands off between two characters.
- **Portrait is per box, not per page.** A single box that breaks into several
  pages keeps one portrait throughout, even if the writing changes speaker.
- **MARGIN under survey zoom** assumes the UI is 160 wide. Zoomed out, the
  portrait's scale will be slightly off.

## Roadmap

- **Finish the hand-edited portrait pass** — the remaining 22 listed above.
- **Portraits from later generations.** The obvious gap in this mod is that
  roughly 45 trainer classes have art and everyone else — townsfolk, family,
  shopkeepers, most named story characters — gets nothing, because Gen 1
  simply has no picture of them to use. Later games do have that art, and
  dropping it in `portraits/` already works today for anyone who wants to
  do it by hand. The intent is to ship a curated set so the common NPCs
  (Mom, nurses, mart clerks, gym guides) have a face out of the box.
- **Post-battle speaker memory.** `MEMORY_SECONDS` is measured from trainer
  engagement, which has always expired by the time a battle ends — post-battle
  lines currently rely on the running script's own NPC and the facing cell
  instead. Refreshing the timestamp when the battle *ends* would close the
  theoretical gap where neither is available.

## Assets and licensing

The mod's code is free to use and adapt. The portrait art is a different
matter and worth being clear about: it is **derived from the Pokémon Red ROM**
— cropped and recolored battle sprites, with hand editing on top. That art is
Nintendo / Game Freak / Creatures Inc. property, and this project claims no
rights to it and has no affiliation with them.

The engine this mod runs on takes the same approach in reverse: it requires
you to supply your own ROM and extracts its assets on your machine, shipping
none itself. If you would rather this repo did the same, delete
`art/trainers/` and regenerate it from your own extract with the script in
[`art/trainers/README.md`](art/trainers/README.md) — everything needed to
rebuild the mechanical pass is documented there. What that cannot reproduce
is the hand-editing, which is why the masters are versioned here.
