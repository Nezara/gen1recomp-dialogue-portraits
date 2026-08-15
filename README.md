# Dialogue Portraits
-- Created with AI/Vibe Coded --

A face beside the words. Talk to someone and their portrait appears next to
the dialogue box.

Idea originally proposed by **Grxpe Ape #TEAMKRIS** (Boi's Club Games Discord)
— implementation and everything above is this repo's own.

## Options

| Option | Values | What it does |
|---|---|---|
| `PORTRAIT` | **INSET** / FRAMED / MARGIN / OFF | Where the portrait goes |
| `SIDE` | **AUTO** / LEFT / RIGHT | Which side of the box the face sits on |

`SIDE = AUTO` follows the player. You turn left to talk to someone standing to
your left, so that is the side of the screen they are on and the side their
face goes. Facing up or down says nothing either way — they're straight ahead —
so that case puts them on whichever side of you their tile actually is, and
falls back to the left when even that is a tie. It is decided once per
conversation, not once per box, so a script that turns somebody around or
walks you a step while it talks can't slide the face across the screen
mid-sentence.

Portraits are an overworld feature. A trainer's pre- and post-battle speech
both happen out in the overworld — the battle pushes after the challenge and
pops before the defeat line — so both get a portrait like any other box. Text
drawn during the battle itself never does.

### INSET 

Puts the portrait inside the dialogue box, in its own four columns, and leaves
the box itself full width. It is drawn inside the 160x144 canvas, so it gets
the palette and the GBC filter along with everything else — it looks like part
of the game.

The cost is four columns of text: lines wrap at 14 characters instead of 18
(13 when the portrait is on the right, where the last column belongs to the
blinking ▼), so conversations run to more pages.

### FRAMED

The same idea with a border of its own: a separate 6x6 Game Boy panel standing
beside the dialogue box, rather than art sharing the box's frame. Same 32x32
picture, same in-canvas palette and filter.

It costs two more columns than INSET — **12 characters a line** — because four
of its six tiles are frame: the panel's own border plus the dialogue box's,
drawn back to back between the art and the text. That is a real cost and not
just a number. At 12 columns the engine has to break any word of 13 characters
or longer partway through, which happens in 88 places across the game's
dialogue, against 25 at INSET's 14.

Pick it if you prefer the portrait to read as its own window. Pick INSET if
you'd rather have the text room.

*Both* leave a box with no identifiable speaker, or whose speaker has no
portrait, completely alone — full width, same wrapping, byte-identical to
vanilla. And in both, pages that get longer because of the narrower wrap wait
for A before scrolling, the same as the ROM's own multi-page text does, rather
than sliding a line away on the typewriter's clock before you've read it.

### MARGIN

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
INSET and FRAMED are the more consistently polished choices at typical window
sizes; MARGIN's real advantage — not losing any text columns at all — is most
worth it once the window is wide enough for it to sit cleanly in the
letterbox.

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
4. **A talking Pokémon's own front sprite**, from `art/pokemon/`. 29 map
   objects across 26 species are a Pokémon standing around with a line of
   dialogue — the Fan Club's Pikachu and Seel, Mr. Fuji's Psyduck and
   Nidorino, the Fuchsia warden's yard, both Pidgey houses, the two Snorlax
   blocking routes. Also exact rather than guessed, but from a different
   field: only five overworld sprites cover all of them, so the species comes
   from the object's own name (`FUCHSIACITY_LAPRAS`) and the file from that
   species' `spriteFront`. Copycat's three *dolls* sit on the same sprites and
   correctly get nothing, since "BIRD" is not a species.

### Bill is a special case

He's a Pokémon when you first meet him — *"Hiya! I'm a POKéMON… …No I'm not!
Call me BILL!"* — and the game never says which. His object uses the generic
monster sprite that fifteen unrelated objects share, so there's genuinely
nothing in the data to recover. Different media have made him different
Pokémon, so the mod picks **one of Rhydon, Clefairy, Nidoran♂ or Kabuto at
random**, then remembers it: your Bill is the same Bill for that whole
playthrough and every future visit. Rolled once per **save file**, so two
saves can have different Bills. It's written into the save the next time you
save, like any other event flag.

That's it. **Nobody else gets a portrait.** Roughly 45 of the game's trainer
classes have battle art; everyone outside that set — regular townsfolk,
family, most named side characters — gets none, on purpose. The earlier
alternative (cropping their own overworld sprite's face) was a worse picture
of them, not a better fallback, so it was dropped.

> **All 28 wanted species have art in `art/pokemon/`** — the 26 with a
> talking overworld NPC plus Bill's two extra forms (Rhydon, Kabuto). Drawn
> facing left, correct for the default right-side placement; the mod mirrors
> the art horizontally when a box lands on the left instead (`SIDE = auto` or
> a forced left), so the same file works on either side. See
> `art/pokemon_new/README.md` for the full list.

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

## Portrait art status

The 45 trainer portraits started life as a mechanical pass: an automated
30x30 crop of each ROM battle sprite, recolored with BROWNMON. That got a
face in the box for everyone, but a fixed crop couldn't frame 45 different
poses well, so they were replaced by hand — **all 45 of 45 are now
hand-edited masters.**

The 28 Pokémon portraits (26 species with a talking overworld NPC, plus
Bill's two extra forms) are hand-drawn from the start — the trainer set's
batch crop doesn't transfer to creature art, see `art/pokemon_new/README.md`
for why — and **all 28 are in.**

### How the art pipeline works

`art/trainers_new/` holds the **grayscale masters** — the editable source.
`art/trainers/` holds what the mod actually loads, which is those masters
after the BROWNMON recolor. `art/pokemon_new/` and `art/pokemon/` are the
same pair for creature art (see `art/pokemon_new/README.md`) — the recolor
script is identical, just without the crop step since these masters are
already at their final size.

**Edit in grayscale, recolor last.** The recolor buckets each pixel by its
red channel (>211 / >127 / >43), which is only correct on the ROM's four flat
grays. It is *not* safely re-runnable on its own output — BROWNMON's own
midtone is `(230,165,123)`, and R=230 is above the 211 threshold, so a second
pass would read those tan pixels as white. The masters are therefore the only
re-editable copy; the recolored files are one-way output.

Current masters are 30x30. Both INSET's slot inside the dialogue box and
FRAMED's panel interior are 32x32, so there are **2px spare in each
dimension** — anything up to 32x32 still lands at a clean 1x. Past 32 the
scale goes fractional and the pixel art comes off the grid, and there is
nowhere for a wider slot to come from: the height is fixed by the dialogue
box, and every extra column of width is a column taken off the text.

The regeneration script and the exact palette values are in
[`art/trainers/README.md`](art/trainers/README.md).

## Custom art

Drop PNGs in the `CustomArt/` folder inside this mod, named after either the
trainer class or the overworld sprite:

```
CustomArt/OPP_BROCK.png
CustomArt/SPRITE_OAK.png
CustomArt/SPRITE_NURSE.png
```

This is the way to give a portrait to anyone the mod doesn't cover on its own
— Mom, a gym guide, any NPC with no battle art. **Portraits should be 30x30
pixels** — that's the size the built-in art ships at, and it's what lands on
a clean 1x scale inside INSET's/FRAMED's 32x32 slot with a pixel of padding
either side. Other sizes are still accepted and auto-scaled to fit, centred
and snapped to a whole multiple whenever one fits, but past 32x32 the scale
goes fractional and pixel art comes off the grid. Trainer class is checked
first, then sprite. Custom art beats everything else, in every layout, and is
used uncropped exactly as supplied.

**`CustomArt/README.md`** has the full how-to plus two reference tables: every
trainer class and the overworld sprite it walks around on, and every
non-battle NPC sprite in the game with whether it already has a portrait —
so it's easy to see at a glance what's already covered and what's worth
drawing next.

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
   `CustomArt/<NAME>.png` (plain name, no `SPRITE_`/`OPP_` prefix) to add
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

Steps 2–4 answer for the world, so they only get asked about the world's own
dialogue. Reading a sign, walking away, or opening a menu each end the
conversation, and a text box the BAG, the PC, the party menu or a trade
animation put up is not somebody talking to you — none of those inherit the
face of whoever you spoke to last. Step 1 is unaffected: text that names its
own speaker is trusted wherever it appears.

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
- **A narrowed box still has to break a word longer than its line.** Counting
  across the whole game's dialogue: 25 words get cut mid-way at INSET's 14
  columns, 40 at its 13 (portrait on the right), 88 at FRAMED's 12. The ones
  that survive INSET are "Congratulations!", "disappointing..." and a couple
  of long ellipsis runs, at 15–16 characters — they do not fit any narrowed
  box. MARGIN has none of this, since it never narrows anything.
- **MARGIN under survey zoom** assumes the UI is 160 wide. Zoomed out, the
  portrait's scale will be slightly off.

## Roadmap

- **Portraits from later generations.** The obvious gap in this mod is that
  roughly 45 trainer classes have art and everyone else — townsfolk, family,
  shopkeepers, most named story characters — gets nothing, because Gen 1
  simply has no picture of them to use. Later games do have that art, and
  dropping it in `CustomArt/` already works today for anyone who wants to
  do it by hand — see `CustomArt/README.md` for exactly which sprites still
  need one. The intent is to ship a curated set so the common NPCs (Mom,
  nurses, mart clerks, gym guides) have a face out of the box.
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

The engine this mod runs on takes the same approach: it requires you to
supply your own ROM and extracts its assets on your machine, shipping none
itself. This repo follows that lead too — only the derivative work (the
hand-edited, recolored masters and the portraits built from them) is
versioned here. The verbatim, un-cropped ROM extract those masters started
from is **not** shipped; `art/trainers/README.md` and `art/pokemon_new/
README.md` document the extractor path and the regeneration script for
anyone starting a fork from scratch.

(Versions 1.0.0 and 1.0.1 briefly shipped that raw extract too, for a fork's
convenience. Reconsidered on a second look at the licensing question — a
straight, un-cropped copy of Nintendo's own art is a meaningfully different
thing to distribute than a cropped, recolored, hand-edited derivative, even
though both ultimately trace back to the same ROM. Removed in 1.0.3.)
