# Changelog

## 1.0.3

- gen1recomp's mod sandbox stopped allowing `love.filesystem` (the DIAG debug
  log, off by default, was the only use — `CustomArt/` already went through
  `mod.assets:image`, unaffected). Rewritten onto `mod.storage`, which needs a
  live game to resolve, so the logger now buffers in memory until one exists
  (`gameRef`, already tracked from `game.ready`/`TextBox.new`). No gameplay
  change -- this only affects where the diagnostic log file lives if DIAG is
  ever flipped on.

## 1.0.2

- **Removed `art/trainers_raw/` and `art/pokemon_raw/`** — the verbatim,
  un-cropped ROM extracts those two folders held (shipped since 1.0.0) are a
  straight copy of Nintendo's own art, not a derivative work, unlike the
  cropped/recolored/hand-edited masters and portraits actually built from
  them. On a second look at the licensing question, distributing that raw
  copy isn't something this repo wants to keep doing, even though both
  ultimately trace back to the same ROM. Nothing else in the pipeline reads
  these back out — `art/trainers/README.md` and `art/pokemon_new/README.md`
  document the extractor path and regeneration script for a fork starting
  from scratch, same as the engine's own "bring your own ROM" approach.
  Now gitignored rather than removed-and-forgettable, so they can't drift
  back in by accident.
- **Custom art folder renamed `portraits/` → `CustomArt/`.** No release has
  ever shipped the old name, so there's nothing to migrate. All three code
  paths and every doc reference moved together (including one in
  `art/pokemon/README.md` that was easy to miss).
- **`CustomArt/README.md` added** — full how-to (naming, precedence, a
  caveat about sprite-level overrides reaching into shared trainer battles)
  plus two reference tables sourced straight from this game's own extracted
  data: all 45 battle trainer classes with the overworld sprite each one
  walks around on, and all 53 other humanoid NPC sprites in the game with
  whether they already have a built-in portrait — 22 do, 31 don't yet.
- **Portrait size documented as 30x30** — the size the built-in art ships
  at and the size that lands on a clean 1x scale in INSET's/FRAMED's 32x32
  slot. Other sizes still work (auto-scaled, centred) but 30x30 is the one
  to draw at.

## 1.0.1

Two reported bugs, and the experimental flag comes off.

- **No longer flagged experimental.** `manifest.json` drops
  `"experimental": true`.
- **Fixed: the portrait changed sides after you answered a question.**
  Reported on Viridian's old man, and his script is the clearest case of it:
  `face_player`, `ask` the coffee question, then the boxes that follow the
  answer (`TEXT_VIRIDIANCITY_OLD_MAN`, `data/scripts/story.lua`). Two things
  were wrong. A box carrying `opts.choice` was forced to the left on the
  belief that the YES/NO box comes down over a right-hand portrait — it does
  not, and never did: `Theme.choiceBox` is `{ tx = 14, ty = 7, tw = 6,
  th = 5 }`, rows 7–11, while every portrait this mod draws lives in the
  dialogue box's own rows 12–17. The two stack, they never overlap, and both
  anchor `"bottom"` so DYNAMIC UI layout moves them together. That force is
  gone. And the side is now resolved **once per conversation** instead of
  once per box, so a script that turns somebody around or walks the player a
  step between two boxes can't slide the face across the screen either. It
  is re-asked when the speaker changes, when the conversation ends, or when
  the `SIDE` option is changed.
- **Fixed: the last person you talked to turned up on messages that aren't
  theirs.** The 15-second speaker memory had a clock but no boundaries, and
  the facing-cell lookup had no idea a menu was up. Two of them added:
  - **Walking away ends the conversation** (`world.stepped`, ignored while a
    script is running, since a cutscene walking you into position is part of
    one). This is what put a face on Viridian's step-triggered "This is
    private property!", and on REPEL wearing off.
  - **A menu is not somebody talking.** The BAG, the START menu's save
    prompts, the PC, the party menu, MoveLearn, the trade and evolution
    animations, the slot machine and the Pokédex all push perfectly ordinary
    text boxes, and the speaker lookup answered them the same way it answers
    a talk. `TextBox.new` now checks the stack it is being built on: the
    world guess only runs when the overworld — or another text box and its
    YES/NO box — is what pushed this one. Text that names its own speaker
    (`"OAK: "`) is untouched by this and still resolves anywhere.

## 1.0.0

Portraits for the Pokémon standing around in towns and houses, and a decision
about Bill.

- **All 45 trainer portraits are now the hand-edited masters**, not the
  original automated crop — `art/trainers_new/` went from 23/45 to 45/45,
  and `art/trainers/` was regenerated from it the same way.
- **Pokémon portraits flip to face the text.** The masters are drawn facing
  left, correct for the default right-side placement; `main.lua` now tags
  every image loaded from `art/pokemon/` as `directional` and mirrors it
  horizontally — in `blitArt` (INSET/FRAMED) and `drawMarginPanel` (MARGIN)
  — whenever the box actually lands on the left, whether from `SIDE = auto`
  or a player-forced left. Trainer art is a front-on battle pose with no
  facing to get wrong, so it's never flipped.
- **Fixed: INSET/FRAMED could stall a scripted cutscene on an unwanted
  A-press.** Reported as "MARGIN auto-advances Oak's PALLET TOWN 'Hey!
  Wait!' bubble but the other two modes wait for input" — backwards from
  how it reads: MARGIN was the one behaving correctly, and INSET/FRAMED
  were the bug. That box is built with `opts.auto` (a timer that pops it
  once typing finishes, `data/scripts/story2.lua`), and at 18 cols its
  text is 2 lines with no CONT — MARGIN never narrows, so it matches
  vanilla and the timer fires untouched. INSET (14 cols) and FRAMED (12)
  narrow it enough that "OAK: Hey! Wait!" no longer fits on one line,
  wrapping the page to 3+ lines the 0.5.0 narrowing fix (`keepPageWaits`)
  then dutifully protected with a synthetic CONT wait — which blocks
  `TextBox:update` from ever reaching `self.done`, so the box sits there
  until the player presses A, something the un-narrowed original never
  asked for and the auto-timer never expects. `TextBox.new`'s wrapper now
  skips that injection for any `opts.auto` box, except `auto.wait` ones
  (the pet-cry boxes, which fall through to an ordinary A/B-gated box once
  done and still want the protection). Same class of bug likely affects
  other `opts.auto` boxes with borderline-length lines (trade animation,
  Hall of Fame, party menu, ...) wherever they pick up a portrait.

- **Talking Pokémon NPCs now resolve to a species.** 29 map objects across 26
  species — the Fan Club's PIKACHU and SEEL, Mr. Fuji's PSYDUCK and NIDORINO,
  the Fuchsia warden's yard, both PIDGEY houses, Cerulean's SLOWBRO, the two
  route-blocking SNORLAX. **The species is not in the sprite**: five overworld
  sprites cover all of them, and SPRITE_BIRD alone is SPEAROW, PIDGEY,
  PIDGEOT, FEAROW, DODUO and three legendary birds. It *is* in the object's
  own `name` (`CELADONMANSION1F_MEOWTH`, `FUCHSIACITY_LAPRAS`), so the rule is
  "drop the map prefix, ask `game.data.pokemon` whether the rest is a
  species" — a lookup, not a guess, and correct for objects this mod has never
  seen. The file then comes from that species' own `spriteFront`, exactly how
  a trainer's comes from its class's `pic`.
- **It declines correctly with no exclusion list.** Copycat's room has three
  *dolls* on the same three sprites (`COPYCATSHOUSE2F_BIRD`/`_FAIRY`/
  `_MONSTER`, "it's only a doll!") and "BIRD" is not a species, so they get
  nothing. Neither do the Power Plant's `POWERPLANT_VOLTORB1..6`, whose
  trailing digit is deliberately not stripped. Verified by running the rule
  over all 916 map objects: 34 resolve, 0 false positives.
- **Three names the ROM doesn't spell as its own species key** are hand-mapped:
  Pewter's bare `NIDORAN` is **NIDORAN_M**, confirmed from the ported script's
  `play_cry` row rather than guessed, and `NIDORANF`/`NIDORANM` map to
  `NIDORAN_F`/`NIDORAN_M`.
- **Bill is one of four Pokémon, rolled per save and kept.** He is a Pokémon
  when you first meet him and the game never says which — his object is the
  generic `SPRITE_MONSTER` that fifteen unrelated objects share, so unlike
  every other portrait here his species is a choice, not a recovery. Rather
  than pick one, he rolls **RHYDON, CLEFAIRY, NIDORAN_M or KABUTO**, reflecting
  what different media have made him. Stored via `Flags` with the value in the
  key (`DP_BILL_FORM_KABUTO`) — `save.modData` did not survive reloads in live
  testing, while `save.flags` is part of the save format proper, which also
  makes the roll automatically per-save-file. Rolled with `love.math.random`,
  never `math.random`, which is the global RNG the engine also rolls battles
  and encounters on. Caveat inherited from the save format: it becomes
  permanent when the player next saves.
- **New art folders**, mirroring the trainer pipeline exactly:
  `art/pokemon_raw/` (verbatim ROM front sprites),
  `art/pokemon_new/` (grayscale masters, the editable copy),
  `art/pokemon/` (BROWNMON-recolored, what the mod loads). Same
  edit-in-grayscale-recolor-last rule, same one-way recolor.
  **The trainer set's batch crop does not transfer** — Pokémon front art is
  40x40, 48x48 or 56x56 rather than a uniform 56, and the creature fills it,
  so only 3 of 28 fit the 32x32 slot at 1x. Per-species measurements are in
  `art/pokemon_raw/README.md`. **All 28 wanted species now have hand-drawn
  masters and are recolored into `art/pokemon/`.**
- **`art/trainers_raw/` and `art/pokemon_raw/` are now versioned, not
  gitignored** — the verbatim ROM extract behind every portrait here,
  included so a fork can start hand-editing a master straight away instead
  of running its own ROM extractor first. See the README's "Assets and
  licensing" section.
- Art loading is cached per full path rather than per basename, so the
  trainer and Pokémon folders can't collide on a name.

## 0.5.0

Three reported bugs, plus the requested auto side. The first and third were
both really the same thing — squeezing the box to 12 columns and then leaving
the engine to cope with text that was never written for 12 columns.

- **INSET no longer draws its own frame; the portrait goes inside the dialogue
  box's.** Through 0.4.3 it took six tiles for a separate 6x6 panel, four of
  which were two frames drawn back to back — the panel's own and the box's.
  Sharing one frame buys the same 32x32 of art for four columns instead of
  six, so the text keeps **14 columns (LEFT) or 13 (RIGHT)** rather than 12.
  The box also stays full width now, and only its `maxCols` and text pen
  change, so it draws its ordinary vanilla frame.
- **The framed panel is still available, as `PORTRAIT = FRAMED`.** Same
  geometry 0.4.3 had — a separate 6x6 window beside the box, 12 columns of
  text — so this is a preference now rather than a replacement. It does not
  have INSET's one asymmetry: its panel sits outside the box the blinking ▼
  is measured against, so both sides get the same 12 columns. It does carry
  the full 88 mid-word breaks that 12 columns implies, against INSET's 25.
  Both layouts get the page-wait fix below.
- **Fixed: punctuation next to a long word broke the line.** At 12 columns the
  engine's wrapper has to hard-cut any word of 13+ characters mid-word
  (`TextBox.paginate`'s `pushLine` falls back to a glyph-boundary cut when no
  space fits), and "a 12-letter word plus its comma" is exactly 13. Running
  the whole ROM's dialogue through the engine's own wrapping rule: **88
  mid-word cuts at 12 columns, 25 at 14** — and the 25 left are
  "Congratulations!", "disappointing..." and a few long ellipsis runs, at
  15–16 characters, which no narrowed box can hold.
- **Fixed: extra lines scrolled past without waiting for A.** The box shows
  two lines and `TextBox:update` advances between lines on a page with no
  pause at all unless `pages.contBefore` marks one — the ROM's `<CONT>`.
  Vanilla text is written two lines to a page, so a third line without a
  `<CONT>` never happens and the engine has no reason to guard against one.
  Narrowing manufactures exactly that, on **2644 pages** of the game's
  dialogue at 14 columns: line three scrolled line one away on the
  typewriter's own clock, unread and unprompted. Each box is now also
  paginated at the box's *original* width, and where a page grew, every line
  past the second is marked as a cont — arrow, A press, one-line scroll,
  through the engine's own field rather than a re-implemented wait.
- **Fixed: the first sign read after talking to someone wore their face.**
  `OverworldState:interact` shows the text and only *then* emits
  `world.interacted`, so the listener that clears the remembered speaker on a
  sign ran one box too late — which is why the second read came out right and
  the first never did. Same shape for bookshelves, hidden objects, PCs and an
  A press that resolves to nothing. `interact` is now wrapped so the mod knows
  an interaction is in flight: if one is, the facing cell has already been
  asked and answered, and a miss there is a real "nobody is speaking" instead
  of a gap for the 15-second memory to fill. Nothing else reads that flag —
  a trainer spotting you across a room and a cutscene starting on a step both
  arrive with no interaction running, and still get the memory.
- **New: `SIDE = AUTO`, now the default.** Face left to talk to someone and
  the portrait appears on the left; face right and it appears on the right.
  Facing up or down carries no left/right information at all, so that case
  compares the speaker's tile to the player's and falls back to the left on a
  tie. A YES/NO box still forces the left, since the YES/NO prompt itself
  comes down over the right of the screen. The resolved side is stored on the
  box, so MARGIN's per-frame draw uses the same answer rather than re-deciding
  every frame.
- Removed the temporary MARGIN diagnostics from 0.4.3. They had settled the
  question they were added for and were writing to
  `<savedir>/dialogue_portraits.log` every two seconds indefinitely. `DIAG`
  and `dlog` remain, off, for the two places a failure is otherwise silent.

## 0.4.3

Fixed MARGIN drawing nothing, reported after 0.4.2. Two real bugs, both
tracing to the same root cause.

- **Root cause: `state.isTextBox` and `state.isBattle` do not exist in this
  engine build.** Confirmed by unzipping the shipped `gen1recomp.exe` (a
  fused LÖVE archive) and grepping its actual `src/` -- both flags are absent
  from the 2026-08-04 build this project runs on; `isTextBox` only exists on
  GitHub `main`, added after that build. `isOverworld` IS real (declared in
  `OverworldController.lua`), which is why that one worked and masked the
  other two being dead.
- **MARGIN drawing nothing**: `topTextBox()` scanned the stack for
  `state.isTextBox`, which never matched, so it always returned nil and bailed
  before drawing -- silently, since the whole hook is one big early-return.
  INSET never hit this because it draws from `self` inside the wrapped
  `TextBox.draw`, with no need to find the box on the stack.
- **Battle suppression never worked**: `battleActive()` had the identical bug
  against `state.isBattle`, always returning false. The `IN BATTLE` option
  removed in 0.4.2 was already inert before that release -- toggling it never
  did anything on this build.
- **Fix**: identify states by CLASS instead of by marker flag. Both `TextBox`
  and `BattleState` are plain `setmetatable({}, Klass)` classes, so
  `getmetatable(state) == Klass` is exact and needs no cooperation from the
  engine. The marker flag is still checked first, so this keeps working
  unchanged on a newer build that does define one.
- **Also fixed, found once MARGIN could actually draw**: it was placing the
  portrait by shrinking to fit whatever margin existed, landing at 2x (60px)
  against INSET's 150px at the default 1024x768 window -- correct geometry,
  wrong tradeoff. It now always draws at the game's own pixel scale (matching
  INSET's size exactly) and, only when the margin is too narrow to hold that,
  moves the portrait above the dialogue box instead of shrinking it. See the
  README's MARGIN section for the sizing tradeoff this implies.
- Diagnostic logging added while chasing this (`dialogue_portraits.log`,
  behind a `DIAG` flag near the top of `main.lua`) is left in for now.

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
