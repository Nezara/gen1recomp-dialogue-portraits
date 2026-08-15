# Custom art

This folder is how you give a portrait to anyone the mod doesn't already
cover — Mom, a nurse, a gym guide, any story character with no battle art of
their own. Anything dropped here beats the mod's own built-in art, in every
`PORTRAIT` layout (INSET/FRAMED/MARGIN), and is drawn exactly as supplied,
uncropped.

## How it's named

A PNG in this folder is matched by filename against one of three things, in
this order:

1. **The trainer's class**, for anyone the ROM itself sends into a battle —
   `OPP_BROCK.png`, `OPP_MISTY.png`. The class name comes straight off the
   map object (`trainerClass`), so it's exact, never a guess.
2. **The overworld sprite**, for anyone who never battles you — `SPRITE_
   NURSE.png`, `SPRITE_MOM.png`. This is also the fallback for a trainer
   whose specific class you *haven't* named a file for (see the caveat
   below).
3. **A name the dialogue itself uses**, for the handful of characters the
   ROM's own text names outright (`"OAK: "`, `"{RIVAL}: "`) — `BILL.png`,
   `MR.FUJI.png` (plain name, no `SPRITE_`/`OPP_` prefix).

Find both `OPP_*` and `SPRITE_*` names in the two tables below, sourced
straight from this game's own extracted data.

## Size

**30x30 pixels** is the size to draw at — it's what the built-in art ships
at, and it lands on a clean 1x pixel scale inside INSET's and FRAMED's
32x32 slot (a pixel of padding on every side). Other sizes are still
accepted: the image is centred and auto-scaled to fit, snapping to a whole
multiple whenever one fits exactly, so 60x60 or 15x15 both still look
correct. Past 32x32 the scale goes fractional and the art comes off the
pixel grid, which is the one size to actually avoid.

## Caveat: a sprite-named file can reskin a trainer battle too

`customArt(trainerClass)` is checked *before* `customArt(sprite)`. That
means for most trainers a sprite-level override is invisible to them — they
already resolve through their own class. But if you *haven't* dropped a file
for that trainer's specific class, a sprite-level file you dropped for
somebody else who happens to share their walking sprite will be picked up
instead, because nothing more specific beat it to the answer.

This actually happens in vanilla Kanto: `SPRITE_SUPER_NERD` alone is worn by
Brock, Pokémaniac, Burglar, Engineer, Rocker *and* Super Nerd, and four more
sprites are each shared between one gym leader and an unrelated townsperson
(`SPRITE_BRUNETTE_GIRL` is both Misty and Copycat, `SPRITE_GIRL` is both
Sabrina and a random Celadon girl, `SPRITE_MIDDLE_AGED_MAN` is both Blaine
and a Celadon Diner regular, `SPRITE_SILPH_WORKER_F` is both Erika and a
generic Silph employee). Table 2 below flags every one of these with which
trainer(s) they're shared with. If you want art for the townsperson side of
one of these without touching the gym leader's own look, name the gym
leader's file too (`OPP_MISTY.png`, `OPP_SABRINA.png`, `OPP_BLAINE.png`,
`OPP_ERIKA.png`, or whichever of the seven `SPRITE_SUPER_NERD` classes you
care about) so it wins first.

## Table 1 — Battle trainers (already covered, no art needed)

Every one of these 45 classes already has a portrait in the mod itself
(`art/trainers/`). Nothing to draw here — this table is just for finding
which overworld sprite a given trainer walks around on, in case that helps
you plan a `SPRITE_*` override for table 2.

| Class | Portrait file | Overworld sprite(s) it walks around on |
|---|---|---|
| AGATHA | `agatha.png` | `SPRITE_AGATHA` |
| BEAUTY | `beauty.png` | `SPRITE_BEAUTY`, `SPRITE_SWIMMER` |
| BIKER | `biker.png` | `SPRITE_BIKER` |
| BIRD KEEPER | `birdkeeper.png` | `SPRITE_COOLTRAINER_M` |
| BLACKBELT | `blackbelt.png` | `SPRITE_HIKER` |
| BLAINE | `blaine.png` | `SPRITE_MIDDLE_AGED_MAN` |
| BROCK | `brock.png` | `SPRITE_SUPER_NERD` |
| BRUNO | `bruno.png` | `SPRITE_BRUNO` |
| BUG CATCHER | `bugcatcher.png` | `SPRITE_YOUNGSTER` |
| BURGLAR | `burglar.png` | `SPRITE_SUPER_NERD` |
| CHANNELER | `channeler.png` | `SPRITE_CHANNELER` |
| COOLTRAINER♀ | `cooltrainerf.png` | `SPRITE_COOLTRAINER_F` |
| COOLTRAINER♂ | `cooltrainerm.png` | `SPRITE_COOLTRAINER_M` |
| CUE BALL | `cueball.png` | `SPRITE_BIKER`, `SPRITE_SWIMMER` |
| ENGINEER | `engineer.png` | `SPRITE_SUPER_NERD` |
| ERIKA | `erika.png` | `SPRITE_SILPH_WORKER_F` |
| FISHERMAN | `fisher.png` | `SPRITE_FISHER` |
| GAMBLER | `gambler.png` | `SPRITE_GAMBLER` |
| GENTLEMAN | `gentleman.png` | `SPRITE_GENTLEMAN` |
| GIOVANNI | `giovanni.png` | `SPRITE_GIOVANNI` |
| HIKER | `hiker.png` | `SPRITE_HIKER` |
| JR.TRAINER♀ | `jr.trainerf.png` | `SPRITE_COOLTRAINER_F`, `SPRITE_SWIMMER` |
| JR.TRAINER♂ | `jr.trainerm.png` | `SPRITE_COOLTRAINER_M` |
| JUGGLER | `juggler.png` | `SPRITE_ROCKER`, `SPRITE_SUPER_NERD` |
| KOGA | `koga.png` | `SPRITE_KOGA` |
| LANCE | `lance.png` | `SPRITE_LANCE` |
| LASS | `lass.png` | `SPRITE_COOLTRAINER_F` |
| LORELEI | `lorelei.png` | `SPRITE_LORELEI` |
| LT.SURGE | `lt.surge.png` | `SPRITE_ROCKER` |
| MISTY | `misty.png` | `SPRITE_BRUNETTE_GIRL` |
| POKéMANIAC | `pokemaniac.png` | `SPRITE_SUPER_NERD` |
| PROF.OAK | `prof.oak.png` | *(no walking map object — script-triggered battle only)* |
| PSYCHIC | `psychic.png` | `SPRITE_YOUNGSTER` |
| RIVAL1 | `rival1.png` | `SPRITE_BLUE` |
| RIVAL2 | `rival2.png` | *(no walking map object — script-triggered battle only)* |
| RIVAL3 | `rival3.png` | *(no walking map object — script-triggered battle only)* |
| ROCKER | `rocker.png` | `SPRITE_SUPER_NERD` |
| ROCKET | `rocket.png` | `SPRITE_ROCKET`, `SPRITE_COOLTRAINER_M` |
| SABRINA | `sabrina.png` | `SPRITE_GIRL` |
| SAILOR | `sailor.png` | `SPRITE_SAILOR` |
| SCIENTIST | `scientist.png` | `SPRITE_SCIENTIST` |
| SUPER NERD | `supernerd.png` | `SPRITE_SUPER_NERD` |
| SWIMMER | `swimmer.png` | `SPRITE_SWIMMER`, `SPRITE_COOLTRAINER_M` |
| TAMER | `tamer.png` | `SPRITE_ROCKER`, `SPRITE_COOLTRAINER_M` |
| YOUNGSTER | `youngster.png` | `SPRITE_YOUNGSTER` |

RIVAL2/RIVAL3/PROF.OAK have art but never appear as a `trainerClass` on a
walking map object — their fights are all started by script, so there's no
`SPRITE_*` to override for them specifically (a name in the dialogue itself,
`"{RIVAL}: "`/`"OAK: "`, is what finds their art instead — see the main
README's "How the speaker is identified").

## Table 2 — Everyone else (which sprites already have a face, and which don't)

These are every other humanoid overworld sprite in the game — the ones that
show up standing behind a counter, sitting in a house, or walking a fixed
patrol with no battle of their own. 22 already resolve through the mod's
own hand-checked table; the other 31 currently show no portrait at all
unless you add one here.

| Sprite | Status | Seen on (a couple of examples) |
|---|---|---|
| `SPRITE_AGATHA` | ✅ `agatha.png` | AGATHASROOM_AGATHA |
| `SPRITE_BALDING_GUY` | — needs `CustomArt/SPRITE_BALDING_GUY.png` | GAMECORNERPRIZEROOM_BALDING_GUY, LAVENDERMART_BALDING_GUY (+2 more) |
| `SPRITE_BEAUTY` | ✅ `beauty.png` | CELADONGYM_BEAUTY1, CELADONGYM_BEAUTY2 (+14 more) |
| `SPRITE_BIKE_SHOP_CLERK` | — needs `CustomArt/SPRITE_BIKE_SHOP_CLERK.png` | BIKESHOP_CLERK, CELADONMANSION3F_PROGRAMMER |
| `SPRITE_BIKER` | ✅ `biker.png` | ROUTE13_BIKER, ROUTE14_BIKER1 (+21 more) |
| `SPRITE_BLUE` | ✅ `rival1.png` | CERULEANCITY_RIVAL, CHAMPIONSROOM_RIVAL (+6 more) |
| `SPRITE_BRUNETTE_GIRL` | — needs `CustomArt/SPRITE_BRUNETTE_GIRL.png` | CERULEANGYM_MISTY, COPYCATSHOUSE2F_COPYCAT (+7 more) — shared with OPP_MISTY, whose own fight already has a portrait (see caveat above) |
| `SPRITE_BRUNO` | ✅ `bruno.png` | BRUNOSROOM_BRUNO |
| `SPRITE_CAPTAIN` | — needs `CustomArt/SPRITE_CAPTAIN.png` | SSANNECAPTAINSROOM_CAPTAIN |
| `SPRITE_CHANNELER` | ✅ `channeler.png` | POKEMONTOWER1F_CHANNELER, POKEMONTOWER2F_CHANNELER (+17 more) |
| `SPRITE_CLERK` | — needs `CustomArt/SPRITE_CLERK.png` | CELADONMANSION3F_GRAPHIC_ARTIST, CELADONMART2F_CLERK1 (+16 more) |
| `SPRITE_COOK` | — needs `CustomArt/SPRITE_COOK.png` | CELADONDINER_COOK, SSANNEKITCHEN_COOK1 (+6 more) |
| `SPRITE_COOLTRAINER_F` | ✅ `cooltrainerf.png` | CELADONGYM_COOLTRAINER_F1, CELADONGYM_COOLTRAINER_F2 (+53 more) |
| `SPRITE_COOLTRAINER_M` | ✅ `cooltrainerm.png` | CERULEANCITY_COOLTRAINER_M, CERULEANMART_COOLTRAINER_M (+42 more) |
| `SPRITE_DAISY` | — needs `CustomArt/SPRITE_DAISY.png` | BLUESHOUSE_DAISY1, BLUESHOUSE_DAISY2 |
| `SPRITE_FISHER` | ✅ `fisher.png` | CELADONCITY_FISHER, CELADONDINER_FISHER (+16 more) |
| `SPRITE_FISHING_GURU` | — needs `CustomArt/SPRITE_FISHING_GURU.png` | CERULEANTRASHEDHOUSE_FISHING_GURU, CINNABARLAB_FISHING_GURU (+8 more) |
| `SPRITE_GAMBLER` | ✅ `gambler.png` | CERULEANTRADEHOUSE_GAMBLER, CINNABARISLAND_GAMBLER (+18 more) |
| `SPRITE_GAMBLER_ASLEEP` | — needs `CustomArt/SPRITE_GAMBLER_ASLEEP.png` | VIRIDIANCITY_OLD_MAN_SLEEPY |
| `SPRITE_GAMEBOY_KID` | — needs `CustomArt/SPRITE_GAMEBOY_KID.png` | CELADONMART3F_GAMEBOY_KID1, CELADONMART3F_GAMEBOY_KID2 (+2 more) |
| `SPRITE_GENTLEMAN` | ✅ `gentleman.png` | CELADONMART5F_GENTLEMAN, CELADONPOKECENTER_GENTLEMAN (+22 more) |
| `SPRITE_GIOVANNI` | ✅ `giovanni.png` | ROCKETHIDEOUTB4F_GIOVANNI, SILPHCO11F_GIOVANNI (+1 more) |
| `SPRITE_GIRL` | — needs `CustomArt/SPRITE_GIRL.png` | CELADONCITY_GIRL, CELADONMART2F_GIRL (+14 more) — shared with OPP_SABRINA, whose own fight already has a portrait (see caveat above) |
| `SPRITE_GRAMPS` | — needs `CustomArt/SPRITE_GRAMPS.png` | CELADONCHIEFHOUSE_CHIEF, CELADONCITY_GRAMPS1 (+6 more) |
| `SPRITE_GRANNY` | — needs `CustomArt/SPRITE_GRANNY.png` | CELADONHOTEL_GRANNY, CELADONMANSION1F_GRANNY (+1 more) |
| `SPRITE_GUARD` | — needs `CustomArt/SPRITE_GUARD.png` | CERULEANCITY_GUARD1, CERULEANCITY_GUARD2 (+15 more) |
| `SPRITE_GYM_GUIDE` | — needs `CustomArt/SPRITE_GYM_GUIDE.png` | CELADONDINER_GYM_GUIDE, CERULEANGYM_GYM_GUIDE (+8 more) |
| `SPRITE_HIKER` | ✅ `hiker.png` | CELADONMANSION_ROOF_HOUSE_HIKER, FIGHTINGDOJO_KARATE_MASTER (+24 more) |
| `SPRITE_KOGA` | ✅ `koga.png` | FUCHSIAGYM_KOGA |
| `SPRITE_LANCE` | ✅ `lance.png` | LANCESROOM_LANCE |
| `SPRITE_LINK_RECEPTIONIST` | — needs `CustomArt/SPRITE_LINK_RECEPTIONIST.png` | CELADONMART1F_RECEPTIONIST, CELADONPOKECENTER_LINK_RECEPTIONIST (+14 more) |
| `SPRITE_LITTLE_BOY` | — needs `CustomArt/SPRITE_LITTLE_BOY.png` | CELADONMART3F_LITTLE_BOY, PEWTERNIDORANHOUSE_LITTLE_BOY (+2 more) |
| `SPRITE_LITTLE_GIRL` | — needs `CustomArt/SPRITE_LITTLE_GIRL.png` | CELADONCITY_LITTLE_GIRL, CELADONMARTROOF_LITTLE_GIRL (+9 more) |
| `SPRITE_LORELEI` | ✅ `lorelei.png` | LORELEISROOM_LORELEI |
| `SPRITE_MIDDLE_AGED_MAN` | — needs `CustomArt/SPRITE_MIDDLE_AGED_MAN.png` | CELADONDINER_MIDDLE_AGED_MAN, CELADONMART2F_MIDDLE_AGED_MAN (+9 more) — shared with OPP_BLAINE, whose own fight already has a portrait (see caveat above) |
| `SPRITE_MIDDLE_AGED_WOMAN` | — needs `CustomArt/SPRITE_MIDDLE_AGED_WOMAN.png` | BIKESHOP_MIDDLE_AGED_WOMAN, CELADONDINER_MIDDLE_AGED_WOMAN (+4 more) |
| `SPRITE_MOM` | — needs `CustomArt/SPRITE_MOM.png` | REDSHOUSE1F_MOM |
| `SPRITE_MR_FUJI` | — needs `CustomArt/SPRITE_MR_FUJI.png` (or `MR.FUJI.png`, since his dialogue names him too) | MRFUJISHOUSE_MR_FUJI, POKEMONTOWER7F_MR_FUJI |
| `SPRITE_NURSE` | — needs `CustomArt/SPRITE_NURSE.png` | CELADONPOKECENTER_NURSE, CERULEANPOKECENTER_NURSE (+11 more) |
| `SPRITE_OAK` | ✅ `prof.oak.png` | CHAMPIONSROOM_OAK, HALLOFFAME_OAK (+3 more) |
| `SPRITE_ROCKER` | — needs `CustomArt/SPRITE_ROCKER.png` | FUCHSIAGYM_ROCKER1, FUCHSIAGYM_ROCKER2 (+11 more) — shared with OPP_JUGGLER/OPP_TAMER/OPP_LT_SURGE, whose own fight already has a portrait (see caveat above) |
| `SPRITE_ROCKET` | ✅ `rocket.png` | CELADONCHIEFHOUSE_ROCKET, CELADONCITY_ROCKET1 (+49 more) |
| `SPRITE_SAFARI_ZONE_WORKER` | — needs `CustomArt/SPRITE_SAFARI_ZONE_WORKER.png` | FUCHSIAMEETINGROOM_SAFARI_ZONE_WORKER1, FUCHSIAMEETINGROOM_SAFARI_ZONE_WORKER2 (+4 more) |
| `SPRITE_SAILOR` | ✅ `sailor.png` | CELADONCHIEFHOUSE_SAILOR, CELADONMART5F_SAILOR (+14 more) |
| `SPRITE_SCIENTIST` | ✅ `scientist.png` | CINNABARLABFOSSILROOM_SCIENTIST1, CINNABARLABFOSSILROOM_SCIENTIST2 (+31 more) |
| `SPRITE_SILPH_PRESIDENT` | — needs `CustomArt/SPRITE_SILPH_PRESIDENT.png` | NAMERATERSHOUSE_NAME_RATER, SILPHCO11F_SILPH_PRESIDENT |
| `SPRITE_SILPH_WORKER_F` | — needs `CustomArt/SPRITE_SILPH_WORKER_F.png` | CELADONGYM_ERIKA, CINNABARMART_SILPH_WORKER_F (+7 more) — shared with OPP_ERIKA, whose own fight already has a portrait (see caveat above) |
| `SPRITE_SILPH_WORKER_M` | — needs `CustomArt/SPRITE_SILPH_WORKER_M.png` | CELADONMANSION3F_GAME_DESIGNER, SAFARIZONEEASTRESTHOUSE_SILPH_WORKER_M (+11 more) |
| `SPRITE_SUPER_NERD` | — needs `CustomArt/SPRITE_SUPER_NERD.png` | BILLSHOUSE_BILL1, BILLSHOUSE_BILL2 (+48 more) — shared with OPP_SUPER_NERD/OPP_BURGLAR/OPP_BROCK/OPP_POKEMANIAC/OPP_ENGINEER/OPP_ROCKER/OPP_JUGGLER, whose own fights already have a portrait (see caveat above) |
| `SPRITE_SWIMMER` | ✅ `swimmer.png` | CERULEANGYM_SWIMMER, ROUTE19_SWIMMER1 (+23 more) |
| `SPRITE_WAITER` | — needs `CustomArt/SPRITE_WAITER.png` | SSANNE1F_WAITER, SSANNE2F_WAITER |
| `SPRITE_WARDEN` | — needs `CustomArt/SPRITE_WARDEN.png` | WARDENSHOUSE_WARDEN |
| `SPRITE_YOUNGSTER` | ✅ `youngster.png` | BIKESHOP_YOUNGSTER, CELADONMART4F_YOUNGSTER (+49 more) |

`BILLSHOUSE_BILL1`/`BILL2` under `SPRITE_SUPER_NERD` is Bill's fixed human
form (before you learn he's also been a Pokémon) — see the main README for
why he's handled separately.

Note: `SPRITE_RED`/`SPRITE_RED_BIKE` (the player, never a talking NPC) and
the five creature sprites (`SPRITE_BIRD`, `SPRITE_FAIRY`, `SPRITE_MONSTER`,
`SPRITE_SEEL`, `SPRITE_SNORLAX` — talking Pokémon share these, keyed to
species instead) aren't listed here; see the main README for how those
resolve. `SPRITE_UNUSED_SCIENTIST` is also left out — it's wired up in the
mod but never actually placed on any map in this game.
