# Changelog

## 0.4.2

Removed the `IN BATTLE` option. It was never meant to exist — portraits are
an overworld feature.

- Nothing changes about trainers. Their pre- and post-battle speech both
  happen in the overworld (the battle state pushes after the challenge and
  pops before the defeat line), so both still get a portrait exactly as
  before. Only text drawn while a battle is actually on the stack is affected,
  and that was already off by default.
- Turning it on was never really viable anyway, which is the reason it's gone
  rather than just re-defaulted: speaker resolution has no battle-aware path,
  so it tagged every move, faint and item message with whichever trainer the
  overworld last knew about, and INSET cut battle text to 12 columns on top of
  that.
- `allowed()` is now just `not battleActive(game)`.

## 0.4.1

Fixed the rival showing no portrait during Oak's Lab, reported after 0.4.0.

- **Root cause**: 0.4.0's `{RIVAL}: ` handling only resolved his stage from
  the candidate NPC, and required that NPC to be a rival battle object. In
  the lab the script's `ctx.npc` is OAK for the script's entire run, so every
  `{RIVAL}: ` box arrived with Oak as the only candidate — no match, so the
  branch correctly cleared Oak's portrait (the text said someone else is
  talking) but had nothing to put up in its place. His later challenges
  worked because there the candidate genuinely *is* the rival battle object.
- **Fix**: when the candidate isn't him, fall back to the current map's own
  rival object, read from `game.data.maps`. `OAKSLAB_RIVAL` carries
  `trainerClass = "OPP_RIVAL1"` right on the object, so this is read, not
  inferred — the "no guessing" rule that motivated showing nothing is intact.
- Across the whole ROM exactly two maps have a rival object with a
  `trainerClass` (`OAKS_LAB` and `SS_ANNE_2F`, both `OPP_RIVAL1`), so the new
  path can only fire where the map is explicit, and by construction it picks
  the same portrait that map's own battle shows. His script-driven scenes
  (Cerulean, Pokémon Tower 2F, Silph 7F, Route 22, Champion's room) name no
  class on the object and still show nothing, unchanged.
- Also in this window: 23 of the 45 baked portraits were replaced with
  hand-edited art (recolored with the same BROWNMON pass, applied last so the
  4-level bucket thresholds still read correctly). Art only, no code change.
  The remaining 22 are still on the original automated crop — see the README's
  status section for the list.
- Published to GitHub, and `manifest.json` now declares `github`, which turns
  on the launcher's built-in update check (it compares release tags against
  the installed version and offers a one-click install). Release zips need to
  be named `dialogue_portraits-<version>.zip` for it to pick the right asset.
- `art/trainers_new/` (the grayscale masters) is now versioned alongside the
  recolored output, since the recolor is one-way and the masters are the only
  re-editable copy.

## 0.4.0

Added a second, higher-priority way to identify the speaker, on request:
reading the dialogue text's own "NAME: " prefix.

- Some of the ROM's own text literally names its speaker —
  `"OAK: {PLAYER}!"`, `"{RIVAL}: Fwahaha!"` — extracted verbatim into
  `red/data/generated/text.lua`. `{RIVAL}` is caught as the literal
  unsubstituted token (`TextBox.substitute` expands it to the player's
  chosen name *inside* `TextBox.new`, after this mod's wrapper already has
  the raw text), so it matches regardless of what the rival was named.
- **Checked before the NPC-based lookup, and its answer wins outright** —
  including down to "show nothing" when the named speaker has no art. This
  catches something the NPC lookup structurally can't: a single running
  script hands dialogue back and forth between two characters (Oak talks,
  then the rival cuts in, same script) while `ctx.npc` stays one object for
  the script's whole run.
- New `NAME_ART` table (`main.lua`): `OAK` and `KOGA` ship wired up by
  default — deliberately short, since most named speakers in this game's
  text are one-off narrative characters (BILL, MR.FUJI, a ship's CAPTAIN)
  with no battle portrait to give them. `portraits/<NAME>.png` (plain name,
  no `SPRITE_`/`OPP_` prefix) adds more.
- `{RIVAL}: ` only resolves when a rival battle NPC is also the best
  available fallback candidate, since the text names "the rival" but not
  which of his three outfits — no such candidate means no portrait rather
  than a guessed, possibly outdated one.

## 0.3.2

Two more rounds of feedback on the baked portraits.

- **Recolored with BROWNMON instead of GRAYMON.** 0.3.1's GRAYMON tint read
  as washed out — GRAYMON's job in the vanilla game is signaling "this has
  no real color" (Ditto, Eevee), so its midtone sits deliberately pale,
  barely darker than the paper. BROWNMON keeps almost the same brightness
  ramp but at real saturation: warm off-white paper, tan midtone, brown
  shadow, near-black outline, closer to a sepia photograph than a faded one.
  (A 2x-upscale/downscale smoothing pass was also tried and dropped in this
  window — read as blurry, not worth it; never made it into a release.)
- **Tighter, lower crop.** 30x30 starting 4px down instead of 42x42 from the
  very top — the original crop read as too much shoulder and not enough
  face. Also lands the art at a clean 1x inside the INSET panel's 32x32
  interior instead of the old fractional ~0.76x scale.

## 0.3.1

Colored the portraits, on request, with an SGB-style treatment.

- All 45 `art/trainers/` PNGs recolored with **GRAYMON** — a real palette
  pulled from `red/data/generated/palettes.lua`, the one the vanilla game
  itself uses for gray-family species like Ditto and Eevee — instead of the
  flat grayscale shipped in 0.2.x/0.3.0. Applied with the same shade-bucket
  thresholds the engine's own colorization shader uses, so it's the same
  recolor the game would do at runtime if these were an ordinary SGB zone,
  just baked in once with a deliberately chosen palette. Regeneration script
  and reasoning in `art/trainers/README.md`.
- `PaletteFX.markTrueColor` (added in 0.2.1) still applies and for the same
  reason: without it, the baked GRAYMON pixels would get swept up and
  recolored a second time by whatever SGB/GBC palette the map underneath
  happens to be using.

## 0.3.0

Two issues reported on 0.2.1: the rival never got a portrait, and the request
to move art sourcing into the mod's own folder instead of cropping the ROM's
files live.

- **Fixed the missing rival** (and any other scripted encounter). Root cause:
  the rival's Oak's Lab introduction runs through a hand-ported map script,
  not a plain walk-up-and-talk, and while the script is moving him around,
  the player's facing cell at each new text box no longer points at him — so
  the old facing-cell lookup came up empty and the 15-second memory fallback
  had usually already expired by the time later lines showed. Speaker
  resolution now checks the running script's own NPC first
  (`ScriptRunner.ctx.npc`, set by `talkTo` whenever a hand-ported script is
  what's actually driving the box) — authoritative, not a guess, for any
  cutscene a script drives, with the facing-cell lookup as the fallback for
  plain talk.
- **Battle art moved into the mod's own `art/trainers/` folder**, pre-cropped
  at build time instead of computed live with a Quad. Same 42x42 top-center
  slice as before (see `art/trainers/README.md` for the exact crop and how
  to regenerate it) — the picture is unchanged, but a bad crop on some future
  addition is now a one-file fix instead of a rule that has to cover every
  pose at once.
- **On the "still grayscale" report**: checked, and it isn't a cropping or
  sourcing artifact — the ROM's battle art carries no color at all in any
  form, the shipped grayscale is not a bug. Documented in `main.lua`'s header
  and both READMEs rather than left unexplained.

## 0.2.1

Fixed a color bug reported on 0.2.0: the INSET portrait came out tinted (blue,
in the report) and visibly banded/noisy at the edges.

Cause: battle-art PNGs are baked as flat DMG grays for the game's own
shade-remap shader to colorize per screen zone at render time -- correct when
the engine draws them in an actual battle, wrong here, since the panel draws
straight into the dialogue box's UI canvas and gets swept up by whatever
SGB/GBC palette the overworld map underneath is using instead of staying
grayscale. Fixed with `PaletteFX.markTrueColor`, the engine's own per-rect
opt-out from that shader (the same mechanism a `trueColor` sprite/tileset
record gets automatically) -- only the art is exempted, the frame around it
stays colorized like the rest of the box. MARGIN was never affected: it draws
after the frame composites, past the shader entirely.

## 0.2.0

Confirmed working on 0.1.1's diagnostic build, then changed on feedback:
portraits should look like a face, not a full body, and a character with no
battle art should get no portrait rather than a worse one.

- **Battle art is now cropped** to a centered top-square slice (42x42 of the
  56x56 source) instead of shown full-body. Checked against a dozen poses —
  upright, leaning, raised-arm, seated — before landing on the fraction.
- **Removed the overworld-sprite-face fallback.** Only the ROM's own battle
  portraits count as a "real" picture now; an NPC outside that ~45-class set
  gets no automatic portrait at all. Custom art is unaffected — it still
  covers anyone, battle art or not, and always wins.
- Removed the now-unused `ART` option (auto/face/trainer) along with it —
  there is only one non-custom source left, so the choice no longer exists.
- Removed the 0.1.1 diagnostic logging; the load-order and hook-wiring
  questions it was checking are settled.

## 0.1.1

Diagnostic build. No behaviour change — 0.1.0 loaded, enabled and drew
nothing, without throwing, so this wrote one line per decision to
`<savedir>/dialogue_portraits.log` to find out where it gave up.

## 0.1.0

First cut, for testing.

- Speaker resolution: the player's facing cell at the moment a text box is
  constructed (with the counter hop, so mart clerks and nurses work), falling
  back to the last `world.interacted` / `world.trainer_engaged` NPC for
  cutscenes.
- INSET layout: six tiles of the dialogue box traded for a framed 6x6 panel,
  drawn inside the Game Boy canvas. Text wraps at 12 columns while a portrait
  is up; boxes with no speaker keep all 18.
- MARGIN layout: full-size art in the letterbox via the `render.hud` hook,
  dialogue box untouched.
- Art: trainer class `pic` when the speaker has a class, a hand-checked named
  list for story characters, otherwise frame 0 of the NPC's overworld sheet
  at 2x. `portraits/<OPP_*|SPRITE_*>.png` overrides all of it.
- Options: PORTRAIT (inset/margin/off), ART (auto/face/trainer), SIDE
  (left/right), IN BATTLE (off by default).
