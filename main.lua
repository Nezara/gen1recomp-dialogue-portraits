-- Dialogue Portraits
--
-- A face beside the words, the way Stardew does it. Gen 1 never had one,
-- and the engine has no idea who is speaking -- TextBox.new takes
-- (game, text, onDone, opts) and nothing else -- so the whole mod is really
-- three questions:
--
--   WHO   is talking, given only "a text box just appeared"
--   WHICH picture is theirs
--   WHERE does it go on a 160x144 screen
--
-- ------- who
--
-- Two independent answers, and the text's own is asked first.
--
-- Some of the ROM's own dialogue literally names its speaker -- "OAK:
-- {PLAYER}!", "{RIVAL}: Fwahaha!" -- extracted verbatim into
-- red/data/generated/text.lua, not something a mod adds. See NAME_ART's
-- comment for why this beats even the script-aware npc lookup below it: a
-- single running script hands ONE npc to its whole run, but the actual
-- dialogue inside that run can hand off between two characters box by box
-- (Oak's Lab: Oak talks, then the rival cuts in, same script) -- something
-- ctx.npc structurally cannot represent. A name in the text overrides
-- whatever the npc lookup would have guessed for that one box, all the way
-- down to "show nothing" when the named speaker has no art.
--
-- When the text names nobody, OverworldState:interact() resolves the NPC
-- from the player's facing cell and hands it to talkTo, which pushes the
-- box -- so at the instant a box is constructed the answer is still sitting
-- in the world, with one added wrinkle: talkTo's own "hand-ported scripts
-- always win" branch forwards that same npc into
-- `self.runner:run(script, { npc = npc, ... })` (src/script/ScriptRunner.lua
-- :run/:makeContext stores it as `self.ctx.npc`), so a script actively
-- running names its npc directly rather than needing it re-derived from
-- position -- which matters because a cutscene script (a rival walking up, a
-- gym leader's pre-battle speech) moves its npc around while text keeps
-- showing, so the player's facing cell at each new box may no longer point
-- at them. Checked first, with the facing-cell lookup (plus the counter hop
-- that lets you talk to a mart clerk across the desk) as the fallback for
-- plain talk that never touches a script at all.
--
-- Neither covers every case -- a script that auto-triggers with no npc in
-- its own extra table, or that hands dialogue to a different object than the
-- one just battled -- so `world.interacted` and `world.trainer_engaged`
-- (real engine events, not internals) are a last-resort memory: the most
-- recent NPC either announced, remembered for MEMORY_SECONDS.
--
-- ------- which picture
--
-- Only the ROM's own battle art counts as a portrait, cropped to a square
-- top-center slice -- the "top middle section" -- so it reads as a bust
-- rather than a full body squeezed into a small box. 45 classes have one;
-- the ~28 humanoid overworld sprites that don't carry a trainerClass of
-- their own (Oak standing in his lab, a mart clerk) get one through a short
-- hand-checked sprite -> class table. Everyone else gets no portrait, on
-- purpose: the alternative was cropping their own overworld sprite's face,
-- which is a worse picture of them, not a better fallback. A player who
-- wants one drawn can drop it in portraits/ (see README) and it wins over
-- everything else -- for a sprite with no battle art at all as much as for
-- overriding one that has it.
--
-- The crop is pre-baked into art/trainers/ at build time (a straight PNG
-- crop, see art/trainers/README) rather than computed at runtime with a
-- Quad: every one of the 45 source PNGs is 56x56, and a 30x30 square
-- starting 4px down from the top (tighter than the first pass's 42x42
-- from the very top, which read as too much shoulder and not enough
-- face) puts the face inside the box every time across a dozen poses
-- checked (upright, leaning, raised-arm, seated), so there was nothing
-- left for a live crop to decide -- baking it once means one file to
-- re-crop by hand if a future addition doesn't fit the fraction, instead of
-- a runtime rule trying to cover every pose at once.
--
-- Colour: the ROM's battle art carries none of its own -- in a real battle a
-- trainer's walk-in pic is colorized by whatever the OPPONENT'S LEAD
-- POKEMON's own SGB palette happens to be (BattleState:sgbBattlePals -- same
-- zone the front sprite uses), not by anything tied to the trainer's
-- identity, so there was never an "Oak's true color" sitting in the data to
-- recover (0.2.0/0.2.1 shipped it exactly as extracted, flat gray, on that
-- reasoning). What's baked into art/trainers/ now instead is a real SGB
-- palette from this game's own data (red/data/generated/palettes.lua's
-- BROWNMON) applied uniformly to every portrait: warm off-white paper, tan
-- midtone, brown shadow, near-black outline -- close to a sepia photograph.
-- GRAYMON (the palette the vanilla game uses for Ditto/Eevee) shipped first
-- and came back reading as washed out: its own job is signaling "this has no
-- real color", so its midtone sits deliberately pale and low-saturation,
-- barely darker than the paper -- exactly wrong for a portrait that wants to
-- look colored. BROWNMON keeps almost the same brightness ramp (both run
-- roughly 245 -> 180 -> 128 -> 19 in luminance) but at real saturation, which
-- is what actually reads as "colorized" rather than "faded." Still not a
-- claim about any character's real color -- there isn't one -- just a
-- second, better-suited sourced palette standing in for one.
--
-- ------- where
--
-- Two of the three layouts draw inside the 160x144 UI canvas, so their art is
-- palette-mapped and GBC-FX'd along with everything else. Both work the same
-- way: Theme.textBox is read fresh by every TextBox at construction
-- (src/ui/Theme.lua, src/render/TextBox.lua:61), so swapping it for the
-- length of one constructor call and putting it straight back gives a per-box
-- geometry change with nothing left behind -- a box with no speaker is
-- byte-identical to vanilla. They differ only in what they buy with it.
--
-- FRAMED takes six tiles off the end of the dialogue box and stands a
-- separate 6x6 Game Boy panel in them, its own border and all. The interior
-- that leaves for art is 32x32, and the text drops to 12 columns.
--
-- INSET buys the SAME 32x32 for four columns instead of six, by noticing that
-- four of FRAMED's six are frame: the panel's own border and the dialogue
-- box's, drawn back to back between the art and the text. Dropping the second
-- one and letting the portrait share the box's own leaves the text 14 columns
-- (LEFT) or 13 (RIGHT). That matters more than it sounds -- at 12 columns the
-- engine's wrapper has to hard-cut any word of 13 characters or more mid-word
-- (src/render/TextBox.lua pushLine falls back to a glyph-boundary cut when no
-- space fits), and "a 12-letter word plus its comma" is exactly 13. Across
-- the ROM's own dialogue that is 88 broken words at 12 columns against 25 at
-- 14.
--
-- INSET's RIGHT stops one column short of where its LEFT does because
-- TextBox:draw puts the blinking page arrow at (tx + tw - 2) and the portrait
-- is painted over the finished box: art in that column would swallow the one
-- cue that says "press A". FRAMED has no such problem -- its panel is outside
-- the box the arrow is measured against -- which is part of why it is still
-- here as a choice rather than as history.
--
-- MARGIN uses the `render.hud` hook instead: window space, over the finished
-- composite, so the portrait can live in the letterbox and cost the text
-- nothing. The trade is that it sits outside the Game Boy pipeline -- no
-- palette, no LCD grid -- so it reads as an overlay rather than as part of
-- the game.

local ART_TW = 4                -- INSET: interior columns of the dialogue box given to the art
local ARROW_TW = 1              -- INSET: the blinking page arrow owns the last interior column
local PANEL_TW = 6              -- FRAMED: tiles taken from the dialogue box for its own panel
local MIN_COLS = 10             -- refuse to narrow a box past this many text columns
local MEMORY_SECONDS = 15       -- how long a cutscene speaker stays remembered
local ART_DIR = "art/trainers/" -- pre-baked crops, mod-relative (see art/trainers/README)
local MON_DIR = "art/pokemon/"  -- the same, for talking POKEMON (see art/pokemon/README)

-- Overworld sprite -> battle front art, for speakers with no trainerClass of
-- their own (OAK standing in his lab is not a trainer record). Only entries
-- that are unambiguous are listed. The vanilla mapping is genuinely
-- many-to-one -- SPRITE_SUPER_NERD alone backs Super Nerd, Pokemaniac,
-- Burglar, Engineer, Rocker and Brock -- so anything ambiguous is left out
-- and gets no portrait rather than a guessed one.
local NAMED_PIC = {
  SPRITE_OAK = "prof.oak",
  SPRITE_BLUE = "rival1",
  SPRITE_AGATHA = "agatha",
  SPRITE_BRUNO = "bruno",
  SPRITE_KOGA = "koga",
  SPRITE_LANCE = "lance",
  SPRITE_LORELEI = "lorelei",
  SPRITE_GIOVANNI = "giovanni",
  SPRITE_ROCKET = "rocket",
  SPRITE_CHANNELER = "channeler",
  SPRITE_SCIENTIST = "scientist",
  SPRITE_UNUSED_SCIENTIST = "scientist",
  SPRITE_GENTLEMAN = "gentleman",
  SPRITE_BEAUTY = "beauty",
  SPRITE_BIKER = "biker",
  SPRITE_HIKER = "hiker",
  SPRITE_SAILOR = "sailor",
  SPRITE_FISHER = "fisher",
  SPRITE_GAMBLER = "gambler",
  SPRITE_SWIMMER = "swimmer",
  SPRITE_YOUNGSTER = "youngster",
  SPRITE_COOLTRAINER_M = "cooltrainerm",
  SPRITE_COOLTRAINER_F = "cooltrainerf",
}

-- A second, independent way to answer "who": some of the ROM's own text
-- literally names its speaker -- "OAK: {PLAYER}!", "{RIVAL}: Fwahaha!" --
-- extracted verbatim in red/data/generated/text.lua, not something a mod
-- adds. `{RIVAL}` is a token, not a name: TextBox.substitute expands it
-- to the player's chosen rival name INSIDE TextBox.new, so the raw text
-- this mod's wrapper sees (before that substitution runs) still carries
-- the literal token, matchable without caring what the player named him.
--
-- This matters beyond just "another way to find the same answer": a single
-- running script's ctx.npc is ONE object for its whole run, but a scripted
-- exchange can hand dialogue back and forth between two people inside that
-- one script (Oak's Lab: Oak talks, then the rival cuts in, same script).
-- ctx.npc can't move mid-script; the text can, box to box -- so a name found
-- in the text overrides whatever ctx.npc/facing-cell says for that one box,
-- and a NAME this mod doesn't recognize (or one whose art fails to load)
-- still overrides it, down to "show nothing" -- the text told us who's
-- talking, so a stale npc guess is worse than no portrait, not better.
--
-- Deliberately short: most speaker-naming in this game's text belongs to
-- narrative-only characters with no trainer battle art at all (BILL,
-- MR.FUJI, the PA system, a ship's CAPTAIN, ...) -- worth a custom
-- portraits/<NAME>.png for anyone who wants one (see README), but nothing
-- this mod can source and ship a default for.
local NAME_ART = {
  OAK = "prof.oak",
  KOGA = "koga",
}

-- ------- talking POKEMON
--
-- 27 map objects in Red are a POKEMON standing around with a line of
-- dialogue -- the Fan Club's PIKACHU and SEEL, Mr. Fuji's PSYDUCK and
-- NIDORINO, the Fuchsia warden's yard, the two PIDGEY houses, Cerulean's
-- SLOWBRO. **Their species is not in their sprite.** Only five overworld
-- sprites cover all of them (SPRITE_BIRD, SPRITE_FAIRY, SPRITE_MONSTER,
-- SPRITE_SEEL, SPRITE_SNORLAX), so SPRITE_BIRD alone is SPEAROW, PIDGEY,
-- PIDGEOT, FEAROW, DODUO and three legendary birds -- exactly the
-- many-to-one trap NAMED_PIC exists to avoid guessing through.
--
-- The species IS in the object's own `name`, which the ROM writes out in
-- full: CELADONMANSION1F_MEOWTH, FUCHSIACITY_LAPRAS, SSANNE1FROOMS_
-- WIGGLYTUFF. So the rule is "drop the map prefix and ask game.data.pokemon
-- whether what's left is a species", which is a lookup rather than a guess,
-- and stays right for map objects this mod has never seen.
--
-- It also declines correctly, with no list to maintain. Copycat's room has
-- three DOLLS on the same three sprites -- COPYCATSHOUSE2F_BIRD, _FAIRY and
-- _MONSTER, all saying "it's only a doll!" -- and "BIRD" is not a species,
-- so they get nothing. Neither do the Power Plant's six POWERPLANT_VOLTORB1
-- ..6, whose trailing digit is not stripped on purpose.
--
-- Three names the ROM does not spell the way its own species table does:
local MON_NAME_FIX = {
  -- Pewter's is NIDORAN_M, per the ported script's own `play_cry` row
  -- (data/scripts/flavor/pewter_nidoran_house.lua) -- the object name says
  -- only "NIDORAN", which is not a species key either way.
  NIDORAN = "NIDORAN_M",
  NIDORANF = "NIDORAN_F",
  NIDORANM = "NIDORAN_M",
}

-- Bill is a POKEMON when you first meet him -- "Hiya! I'm a POKEMON... ...No
-- I'm not! Call me BILL!" -- and the game never says which one. His object
-- (BILLSHOUSE_BILL_POKEMON) uses SPRITE_MONSTER, the generic silhouette
-- fifteen unrelated objects share, so there is nothing in the data to
-- recover: unlike every other portrait here, his species is a choice.
--
-- Different media have made it a different Pokemon, so rather than pick one,
-- roll one of the four and keep it. Rolled once per SAVE FILE and remembered
-- forever after, so a given playthrough's Bill is always the same Bill.
local BILL_OBJECT = "BILL_POKEMON"
local BILL_FORMS = { "RHYDON", "CLEFAIRY", "NIDORAN_M", "KABUTO" }
local BILL_FLAG = "DP_BILL_FORM_"

return function(mod)
  local TextBox   = require("src.render.TextBox")
  local Theme     = require("src.ui.Theme")
  local Font      = require("src.render.Font") -- FRAMED's panel border
  local Collision = require("src.world.Collision")
  local PaletteFX = require("src.render.PaletteFX")

  -- One call, always: mod.options:define REPLACES the option set rather than
  -- adding to it, so a second call would silently wipe the first.
  mod.options:define({
    { key = "style", label = "PORTRAIT", type = "choice", default = "inset",
      choices = { { "INSET", "inset" }, { "FRAMED", "framed" },
                  { "MARGIN", "margin" }, { "OFF", "off" } } },
    -- AUTO reads the player's own facing: you turn LEFT to talk to somebody
    -- standing to your left, so that is the side of the screen they are on
    -- and the side their face belongs on. Facing UP or DOWN says nothing
    -- either way -- the speaker is straight ahead -- so that case compares
    -- cells when the speaker is known and otherwise keeps the traditional
    -- left.
    { key = "side", label = "SIDE", type = "choice", default = "auto",
      choices = { { "AUTO", "auto" }, { "LEFT", "left" }, { "RIGHT", "right" } } },
  })

  local function opt(key, fallback)
    local ok, value = pcall(function() return mod.options:get(key) end)
    if ok and value ~= nil then return value end
    return fallback
  end

  -- ------- speaker resolution

  local lastNpc, lastNpcAt = nil, -math.huge

  local function now()
    return (love and love.timer and love.timer.getTime and love.timer.getTime()) or 0
  end

  mod.events:on("world.interacted", function(ev)
    -- kind is "npc" | "sign" | ... ; a sign is not a speaker, and landing here
    -- for one is how a portrait gets cleared when you walk off and read a
    -- bookshelf instead.
    if ev and ev.kind == "npc" and ev.target then
      lastNpc, lastNpcAt = ev.target, now()
    else
      lastNpc, lastNpcAt = nil, -math.huge
    end
  end)

  mod.events:on("world.trainer_engaged", function(ev)
    if ev and ev.npc then lastNpc, lastNpcAt = ev.npc, now() end
  end)

  local function overworldOf(game)
    local states = game and game.stack and game.stack.states
    if states then
      for i = #states, 1, -1 do
        if states[i].isOverworld then return states[i] end
      end
    end
    local ow = game and game.overworld
    if ow and ow.isOverworld and ow.map then return ow end
    return nil
  end

  -- The same lookup OverworldState:interact() does, run again a few lines
  -- later in the frame. Counter cells are included because talking to a mart
  -- clerk or a nurse puts a desk tile between you and them.
  local function facingNpc(game)
    local ow = overworldOf(game)
    local player = ow and ow.player
    if not (player and ow.npcAtCell and player.facingCell) then return nil end
    local fx, fy = player:facingCell()
    local npc = ow:npcAtCell(fx, fy)
    if not npc and ow.map and ow.map.isCounterCell and ow.map:isCounterCell(fx, fy) then
      local fx2, fy2 = Collision.target(fx, fy, player.facing)
      npc = ow:npcAtCell(fx2, fy2)
    end
    return npc
  end

  -- Whatever npc talkTo(npc) handed to the currently-running script, straight
  -- from the ScriptRunner instance the overworld already owns (self.runner,
  -- the same object WorldAPI:overworld().runner is -- no private-field reach
  -- needed beyond overworldOf() above). isRunning() gates it against reading
  -- a stale ctx left over from a script that already finished; a fresh
  -- ctx.npc that happens to be nil (an auto-triggered script with no NPC of
  -- its own) is a real "don't know", not a miss to fall through past.
  local function scriptNpc(game)
    local ow = overworldOf(game)
    local runner = ow and ow.runner
    if not (runner and runner.isRunning and runner:isRunning()) then return nil end
    local ctx = runner.ctx
    return ctx and ctx.npc or nil
  end

  -- Is an A-press interaction resolving right now?
  --
  -- The `world.interacted` listener above is meant to clear the memory the
  -- moment you read a sign instead of talking to somebody, and it does --
  -- one box too late. OverworldState:interact (src/world/OverworldController
  -- .lua) SHOWS the text and only then announces what the press landed on:
  --
  --     if sign then
  --       self:showMapText(sign.text, nil)     -- TextBox.new runs in here
  --       interacted(self, fx, fy, "sign", sign)
  --
  -- so the first sign read after talking to somebody with a portrait was
  -- built while lastNpc still held them, wore their face, and only then
  -- cleared -- which is why the SECOND read came out right and the first
  -- never did. The bookshelf, hidden-object and PC branches below it are
  -- shaped the same way, and so is any A press that resolves to nothing.
  --
  -- Knowing an interaction is in flight is enough to fix all of them at once:
  -- if one is, the facing cell has already been asked and answered, so a
  -- miss there is a real "nobody is speaking" rather than a gap for the
  -- memory to fill. Nothing else is inferred from this flag -- the trainer
  -- who spots you across a room and the cutscene that starts on a step both
  -- arrive with no interaction running at all, and still get the memory.
  --
  -- OverworldState is pushed onto the stack as ITSELF (Game.lua:86,
  -- `self.overworld = OverworldState`; Console.lua pushes the required module
  -- directly), not as an instance of a class -- so this is a plain function
  -- swap on one table, and `self` inside it is that same table.
  local interactDepth = 0

  local function wrapInteract()
    local ok, OverworldState = pcall(require, "src.world.OverworldController")
    if not ok or type(OverworldState) ~= "table" then return false end
    if OverworldState.dp_interactWrapped then return true end
    if type(OverworldState.interact) ~= "function" then return false end
    OverworldState.dp_interactWrapped = true
    local originalInteract = OverworldState.interact
    OverworldState.interact = function(self, ...)
      interactDepth = interactDepth + 1
      local okRun, err = pcall(originalInteract, self, ...)
      interactDepth = math.max(0, interactDepth - 1)
      if not okRun then error(err, 0) end
    end
    return true
  end

  -- The engine requires this module during Game:load, so the immediate
  -- attempt normally wins; game.ready is the retry for a load order that
  -- puts mods first, and costs nothing when the wrap already took.
  if not wrapInteract() then
    mod.events:on("game.ready", function() pcall(wrapInteract) end)
  end

  local function speakerFor(game)
    local ok, npc = pcall(scriptNpc, game)
    if ok and npc then return npc end
    ok, npc = pcall(facingNpc, game)
    if ok and npc then return npc end
    if interactDepth > 0 then
      -- An A press that landed on a sign, a bookshelf, a hidden item, a PC
      -- or bare ground. Drop the memory too, so nothing downstream in the
      -- same conversation can inherit it either.
      lastNpc, lastNpcAt = nil, -math.huge
      return nil
    end
    if lastNpc and (now() - lastNpcAt) <= MEMORY_SECONDS then return lastNpc end
    return nil
  end

  -- Which side of the box the portrait belongs on, resolved per box.
  local function sideFor(game, npc)
    local side = opt("side", "auto")
    if side ~= "auto" then return side end
    local ow = overworldOf(game)
    local player = ow and ow.player
    local facing = player and player.facing -- lowercase live movement casing
    if facing == "left" then return "left" end
    if facing == "right" then return "right" end
    -- Facing up or down: the speaker is straight ahead, so facing carries no
    -- left/right information at all. Their cell does, when we have them.
    if player and player.cellX and npc and npc.cellX then
      if npc.cellX < player.cellX then return "left" end
      if npc.cellX > player.cellX then return "right" end
    end
    return "left"
  end

  -- ------- art

  -- id -> art record, or false for "looked, nothing there". Caching the miss
  -- matters: without it every box for a portrait-less NPC retries a failing
  -- image load.
  local customCache, trainerCache = {}, {}

  -- Small custom art gets doubled in MARGIN mode, where there is room and a
  -- 16x16 image at 1x would be a postage stamp. INSET ignores this and fits
  -- to its slot inside the box instead.
  local function magFor(w, h)
    if w <= 32 and h <= 32 then return 2 end
    return 1
  end

  local function customArt(id)
    if not id then return nil end
    local hit = customCache[id]
    if hit ~= nil then return hit or nil end
    local ok, image = pcall(function()
      return mod.assets:image("portraits/" .. id .. ".png")
    end)
    if not ok or not image then
      customCache[id] = false
      return nil
    end
    local w, h = image:getDimensions()
    local art = { image = image, w = w, h = h, mag = magFor(w, h) }
    customCache[id] = art
    return art
  end

  -- A trainer class's `pic` and a species' `spriteFront` are both full ROM
  -- paths (".../battle/trainers/brock.png", ".../battle/front/nidoranm.png");
  -- the pre-baked crops sitting in this mod's own art/ folders keep the same
  -- basename, so this is the only translation needed between the two.
  local function basenameOf(path)
    return path and path:match("([^/]+)%.png$")
  end

  -- Loads this mod's own pre-baked crop (see the header comment on why the
  -- crop is baked rather than computed here) through mod.assets:image, same
  -- path a player's own portraits/ override goes through -- just a
  -- different folder, so both land in a plain, uncached-miss-safe art
  -- record with no Quad or engine Assets reach involved.
  --
  -- `dir` selects trainers or pokemon. The cache is keyed by the full
  -- relative path rather than by basename: the two sets are independent
  -- folders and could legitimately collide on a name.
  local function trainerArt(basename, dir)
    if not basename then return nil end
    dir = dir or ART_DIR
    local path = dir .. basename .. ".png"
    local hit = trainerCache[path]
    if hit ~= nil then return hit or nil end
    local ok, image = pcall(function()
      return mod.assets:image(path)
    end)
    if not ok or not image then
      trainerCache[path] = false
      return nil
    end
    local w, h = image:getDimensions()
    -- Pokemon portraits are drawn facing left (correct for the default
    -- RIGHT-side placement, where the speaker faces in towards the text).
    -- Trainer art is a front-on battle pose with no facing to get wrong, so
    -- only MON_DIR art is tagged for the flip blitArt/drawMarginPanel apply
    -- when the box lands on the left instead.
    local art = { image = image, w = w, h = h, mag = 1, directional = (dir == MON_DIR) }
    trainerCache[path] = art
    return art
  end

  -- The class's own `pic` when the speaker is a trainer object (authoritative
  -- -- the map object carries trainerClass, so there is nothing to infer),
  -- otherwise the hand-checked sprite table above.
  local function classArt(game, def, spriteId)
    local cls = def.trainerClass
    local record = cls and game.data and game.data.trainers and game.data.trainers[cls]
    if record and record.pic then
      local art = trainerArt(basenameOf(record.pic))
      if art then return art end
    end
    return trainerArt(spriteId and NAMED_PIC[spriteId])
  end

  -- ------- which POKEMON
  --
  -- Bill's form, rolled once per save file and kept.
  --
  -- Persisted through Flags rather than modData: game.save.modData did not
  -- reliably survive a reload in live testing, while save.flags is a real,
  -- core part of the save FORMAT. Flags only ever stores `true`, but the
  -- NAME is an arbitrary string and save.flags is a plain table -- so the
  -- payload rides in the key ("DP_BILL_FORM_KABUTO") and comes back out by
  -- scanning for the prefix. Being inside the save file, it is also
  -- automatically per-save: two playthroughs can roll differently and
  -- neither can see the other's answer.
  --
  -- The one caveat is inherited from the save format: it becomes permanent
  -- when the player next SAVES. Meet Bill and reload without saving and he
  -- rerolls, exactly like any other event flag set in that window.
  local Flags
  do
    local ok, mod_ = pcall(require, "src.script.Flags")
    if ok then Flags = mod_ end
  end

  local function billForm(game)
    local save = game and game.save
    local flags = save and save.flags
    if type(flags) ~= "table" then return nil end
    for name in pairs(flags) do
      if type(name) == "string" then
        local species = name:match("^" .. BILL_FLAG .. "(.+)$")
        if species then return species end
      end
    end
    -- love.math.random, never math.random: math.random is the GLOBAL Lua
    -- RNG this engine also rolls battles and encounters on, and reseeding
    -- or drawing from it perturbs them. LOVE seeds its own generator from
    -- system entropy at startup, independently.
    local index = 1
    if love and love.math and love.math.random then
      index = love.math.random(#BILL_FORMS)
    end
    local pick = BILL_FORMS[index] or BILL_FORMS[1]
    if Flags and Flags.set then pcall(Flags.set, save, BILL_FLAG .. pick) end
    return pick
  end

  -- The species a map object IS, or nil for "not a POKEMON" -- which is the
  -- answer for every human NPC, for Copycat's three dolls, and for the Power
  -- Plant's numbered VOLTORBs. Everything after the FIRST underscore is the
  -- object's own half of the name; the map prefix carries digits of its own
  -- (SSANNE1FROOMS, COPYCATSHOUSE2F) so it can't be matched by shape.
  local function speciesOf(game, def)
    local name = def and def.name
    if type(name) ~= "string" then return nil end
    local tail = name:match("^[^_]+_(.+)$")
    if not tail then return nil end
    if tail == BILL_OBJECT then return billForm(game) end
    tail = MON_NAME_FIX[tail] or tail
    local dex = game and game.data and game.data.pokemon
    if dex and dex[tail] then return tail end
    return nil
  end

  -- Same shape as classArt below: the species record names its own art file
  -- (`spriteFront` = "assets/generated/battle/front/nidoranm.png"), and this
  -- mod's own crop keeps that basename, so nothing is guessed here either.
  local function monArt(game, species)
    local dex = game and game.data and game.data.pokemon
    local record = species and dex and dex[species]
    return trainerArt(basenameOf(record and record.spriteFront), MON_DIR)
  end

  -- Which of the rival's three outfits, when the text says "{RIVAL}:" but the
  -- npc we have in hand is somebody ELSE. That is the normal case in his
  -- introduction rather than an edge case: a script's ctx.npc is one object
  -- for the script's whole run, so through Oak's Lab it stays OAK while the
  -- dialogue hands back and forth -- the "{RIVAL}:" boxes arrive with Oak as
  -- the only candidate, and the rival standing three tiles away is never
  -- consulted.
  --
  -- He is in the map data though, and carrying his own answer: OAKSLAB_RIVAL
  -- has trainerClass = "OPP_RIVAL1" written on the object, exactly like the
  -- battle objects that already work. So this reads the stage off the map
  -- rather than inferring it from story progress -- still no guessing, which
  -- is what the "show nothing rather than a possibly-outdated outfit" rule
  -- was protecting. Across the whole ROM only two maps have a rival object
  -- with a trainerClass at all (OAKS_LAB and SS_ANNE_2F, both OPP_RIVAL1),
  -- so this can only ever resolve where the map itself is explicit, and the
  -- portrait it picks is by construction the same one that map's own battle
  -- would show. The other rival scenes (Cerulean, Pokemon Tower 2F, Silph
  -- 7F, Route 22, Champion's Room) name no class on the object -- their
  -- battles are started by script -- so they still get nothing, as before.
  --
  -- Memoized per map: map data is static, and a miss is worth caching too so
  -- a rival-less map doesn't rescan its object list on every box.
  local rivalDefCache = {}

  local function currentMapId(game)
    local ok, cur = pcall(function() return mod.world:current() end)
    if ok and cur and cur.mapId then return cur.mapId end
    local ow = overworldOf(game)
    return ow and ow.map and ow.map.id or nil
  end

  local function rivalDefOnMap(game)
    local mapId = currentMapId(game)
    if not mapId then return nil end
    local hit = rivalDefCache[mapId]
    if hit ~= nil then return hit or nil end
    local record = game and game.data and game.data.maps and game.data.maps[mapId]
    local objects = record and record.objects
    if objects then
      for _, def in ipairs(objects) do
        local cls = def.trainerClass
        if type(cls) == "string" and cls:match("^OPP_RIVAL%d+$") then
          rivalDefCache[mapId] = def
          return def
        end
      end
    end
    rivalDefCache[mapId] = false
    return nil
  end

  -- "{RIVAL}" (a literal token match, before substitution) or an all-caps
  -- word ("OAK", "KOGA", "MR.FUJI") immediately followed by ": " at the very
  -- start of the box's text.
  local function nameToken(text)
    if type(text) ~= "string" then return nil end
    local token = text:match("^(%b{})%s*:%s")
    if token then return token end
    return text:match("^([A-Z][A-Z%.]*):%s")
  end

  -- Returns (art, handled). handled=true means the text itself answered
  -- "who", even when that answer is "nobody we have art for" -- the caller
  -- should trust it and stop looking, not fall back to guessing from the
  -- world. handled=false means there was no name to read, so the normal
  -- npc-based pipeline still gets to decide.
  local function nameArt(game, text, candidateNpc)
    local token = nameToken(text)
    if not token then return nil, false end
    if token == "{RIVAL}" then
      -- which rival portrait (1/2/3) isn't in the text, only in the story's
      -- progress -- so this only resolves off an object that names its own
      -- stage. First choice is the candidate npc we already have, when that
      -- IS a rival battle object (a walk-up challenge). Otherwise ask the
      -- map, which covers the case the candidate structurally can't: a
      -- script whose ctx.npc is the OTHER speaker for its whole run (see
      -- rivalDefOnMap). Neither one explicit: still nothing, rather than an
      -- outfit that might be two fights out of date.
      local def = candidateNpc and candidateNpc.def
      if def and def.trainerClass and def.trainerClass:match("^OPP_RIVAL%d+$") then
        return classArt(game, def, def.sprite), true
      end
      local mapDef = rivalDefOnMap(game)
      if mapDef then return classArt(game, mapDef, mapDef.sprite), true end
      return nil, true
    end
    return customArt(token) or trainerArt(NAME_ART[token]), true
  end

  local function artFor(game, npc)
    local def = npc and npc.def
    if not def then return nil end
    -- an item ball is an object_event with a payload, not somebody talking
    if def.item and def.item ~= "0" and def.item ~= 0 then return nil end

    -- A talking POKEMON answers first and most specifically -- its species is
    -- written on the object, while its SPRITE is one of five shared by
    -- everything from SPEAROW to MOLTRES. Still falls through if nobody has
    -- drawn that species yet, so a sprite-level portraits/ override keeps
    -- working the way it always did.
    local species = speciesOf(game, def)
    local monPortrait = species and (customArt(species) or monArt(game, species))

    return monPortrait
           or customArt(def.trainerClass) or customArt(def.sprite)
           or classArt(game, def, def.sprite)
  end

  -- ------- state queries
  --
  -- Identify a state by its CLASS, not by a marker flag on it.
  --
  -- `isOverworld` is real -- OverworldController.lua declares
  -- `{ isOpaque = true, isOverworld = true }` and WorldAPI scans the stack
  -- for it -- which is why overworldOf() above can use it. But there is no
  -- equivalent for text boxes or battles: `isTextBox` and `isBattle` do not
  -- exist in this engine build at all, so testing them silently matched
  -- nothing, forever.
  --
  -- That is precisely why MARGIN drew nothing while INSET was fine. INSET
  -- draws from `self` inside the TextBox.draw wrapper and never has to find
  -- the box on the stack; MARGIN runs from a render hook and has to look it
  -- up, so it hit the dead flag every frame. The same dead-flag bug made
  -- battleActive() always return false, meaning the battle suppression this
  -- mod has always claimed was never actually doing anything.
  --
  -- Every state here is a plain metatable-backed class -- `setmetatable({},
  -- Klass)` with `Klass.__index = Klass` -- so comparing an instance's
  -- metatable against the class table is exact and needs no cooperation from
  -- the engine. The marker flag is still checked first, so this keeps working
  -- unchanged on newer builds that do define one (upstream has since added
  -- `isTextBox`).
  local function isA(state, klass, flag)
    if type(state) ~= "table" then return false end
    if flag and state[flag] then return true end
    return klass ~= nil and getmetatable(state) == klass
  end

  -- Resolved once, lazily and defensively: a build that moves or renames this
  -- module should degrade to "never in battle" rather than throw on load.
  local BattleClass
  do
    local ok, klass = pcall(require, "src.battle.BattleState")
    if ok then BattleClass = klass end
  end

  local function battleActive(game)
    local states = game and game.stack and game.stack.states
    if not states then return false end
    for i = #states, 1, -1 do
      if isA(states[i], BattleClass, "isBattle") then return true end
    end
    return false
  end

  -- Portraits are an OVERWORLD feature, full stop. A trainer's pre- and
  -- post-battle speech both happen out here -- the battle state pushes after
  -- the challenge and pops before the defeat line -- so those are ordinary
  -- overworld boxes and get a portrait like any other. Text drawn while a
  -- battle is actually on the stack does not, and there is no option to turn
  -- that on: the speaker lookup has no battle-aware path, so it would tag
  -- every move and faint message with whichever trainer the overworld last
  -- knew about, and INSET would cut battle text to 12 columns on top of that.
  local function allowed(game)
    return not battleActive(game)
  end

  -- Only the top of the stack counts: a `stay` box left sitting under a menu
  -- (the Viridian school blackboard) is not the conversation on screen. Three
  -- deep, so a YES/NO ChoiceBox pushed on top of its own text box still finds
  -- the box underneath it.
  local function topTextBox(game)
    local states = game and game.stack and game.stack.states
    if not states then return nil end
    for i = #states, math.max(1, #states - 2), -1 do
      if isA(states[i], TextBox, "isTextBox") then return states[i] end
    end
    return nil
  end

  -- ------- drawing

  -- Centred, and snapped to a whole scale whenever the art actually fits, so
  -- pixel art stays on the pixel grid. The 30x30 crop against INSET's 32x32
  -- slot (ART_TW columns wide by the box's own interior height) lands on a
  -- clean 1x with a pixel of padding each side; only art bigger than its
  -- hole (a custom override, say) goes fractional.
  -- `flip` mirrors directional (POKEMON) art horizontally -- the masters
  -- face left, which is correct for the default right-side placement, so a
  -- box that lands on the left instead needs the art turned to face back
  -- in towards the text. Negative sx flips around the draw origin, so the
  -- origin is walked to the mirrored art's own right edge first.
  local function blitArt(art, x, y, w, h, flip)
    local scale = math.min(w / art.w, h / art.h)
    if scale >= 1 then scale = math.floor(scale) end
    local dx = x + math.floor((w - art.w * scale) / 2)
    local dy = y + math.floor((h - art.h * scale) / 2)
    love.graphics.setColor(1, 1, 1, 1)
    if flip then
      love.graphics.draw(art.image, dx + art.w * scale, dy, 0, -scale, scale)
    else
      love.graphics.draw(art.image, dx, dy, 0, scale, scale)
    end
  end

  -- ------- diagnostics
  --
  -- Off by default. The frame-by-frame gate trace that lived here through
  -- 0.4.3 did its job -- MARGIN drawing nothing was a dead `state.isTextBox`
  -- marker, fixed there -- and has been removed rather than left writing a
  -- line every two seconds forever. What is left is the two places a failure
  -- is otherwise completely silent (a throw inside a pcall'd draw, and the
  -- load line that says the entry chunk got this far). Flip DIAG to true and
  -- the log lands in <savedir>/dialogue_portraits.log.
  local DIAG = false

  local function dlog(fmt, ...)
    if not DIAG then return end
    local ok, line = pcall(string.format, fmt, ...)
    if not ok then line = tostring(fmt) end
    pcall(function()
      love.filesystem.append("dialogue_portraits.log",
        os.date("!%H:%M:%S ") .. line .. "\n")
    end)
  end

  -- Where the art goes and what the text keeps, for whichever of the two
  -- in-canvas layouts is chosen. Both derive everything from the geometry
  -- Theme.textBox is actually carrying rather than from the vanilla
  -- 0/12/20/6 literals, so a re-themed box still lands correctly, and both
  -- return nil when the box is too small to give anything up.
  --
  -- `theme` is what Theme.textBox becomes for the length of the constructor.
  -- INSET changes only maxCols -- the box keeps its full width and draws its
  -- ordinary frame, and the text is pushed clear of the art afterwards by
  -- overriding textX. FRAMED moves and shrinks the box itself, so its text
  -- pen follows from boxTx on its own and needs no override.
  local function insetLayout(base, side)
    local tx, tw, maxCols = base.tx, base.tw, base.maxCols
    if not (tx and tw and maxCols) then return nil end
    local reserved = ART_TW + (side == "right" and ARROW_TW or 0)
    if maxCols - reserved < MIN_COLS then return nil end
    local artCol, textX
    if side == "right" then
      artCol, textX = tx + tw - 1 - ARROW_TW - ART_TW, (tx + 1) * 8
    else
      artCol, textX = tx + 1, (tx + 1 + ART_TW) * 8
    end
    return {
      artCol = artCol, artW = ART_TW * 8, textX = textX,
      theme = { tx = tx, ty = base.ty, tw = tw, th = base.th,
                maxCols = maxCols - reserved },
    }
  end

  local function framedLayout(base, side)
    local tx, tw, maxCols = base.tx, base.tw, base.maxCols
    if not (tx and tw and maxCols) then return nil end
    if maxCols - PANEL_TW < MIN_COLS then return nil end
    local boxTw = tw - PANEL_TW
    -- The panel takes the end of the box's own run of tiles, and the box
    -- slides over to make room -- so on the right the panel is past the
    -- shortened box, and on the left the box starts PANEL_TW in.
    local panelTx = (side == "right") and (tx + boxTw) or tx
    local boxTx = (side == "right") and tx or (tx + PANEL_TW)
    return {
      panelTx = panelTx,
      artCol = panelTx + 1, artW = (PANEL_TW - 2) * 8,
      theme = { tx = boxTx, ty = base.ty, tw = boxTw, th = base.th,
                maxCols = maxCols - PANEL_TW },
    }
  end

  local function drawPortrait(box)
    local x, y = box.dp_artX, box.dp_artY
    local w, h = box.dp_artW, box.dp_artH
    if box.dp_panelTx then
      -- FRAMED only. The panel is a window of its own beside the dialogue
      -- box, so it has to make the same edge-anchor declaration the box makes
      -- under UI LAYOUT = DYNAMIC (TextBox:draw -> Renderer:setUIAnchor) or
      -- it stays behind in the letterbox while the box it belongs to docks to
      -- the window bottom. INSET needs none of this: its art is inside the
      -- box's own rect, which TextBox:draw has already anchored.
      local renderer = box.game and box.game.renderer
      if renderer and renderer.setUIAnchor then
        renderer:setUIAnchor(box.dp_panelTx * 8, box.boxTy * 8,
                             PANEL_TW * 8, box.boxTh * 8, "bottom")
      end
      love.graphics.setColor(0, 0, 0, 1)
      Font.drawBox(box.dp_panelTx, box.boxTy, PANEL_TW, box.boxTh)
    end
    blitArt(box.dp_art, x, y, w, h, box.dp_art.directional and box.dp_side == "left")
    -- art/trainers/ ships its color already baked in (see the header
    -- comment), which matters here for the same reason it would if these
    -- were still flat DMG grays: drawn raw into the dialogue box with no
    -- exemption, the shade-remap shader would still try to recolor it,
    -- reading the baked BROWNMON pixels through whatever SGB/GBC palette the
    -- MAP zone underneath happens to be using -- swapping one already-chosen
    -- palette for a wrong one, banding at the edges where the crop's scale
    -- isn't a whole number. PaletteFX.markTrueColor is the engine's own
    -- opt-out -- Renderer:endFrame re-blits this rect unshaded on top of the
    -- colorized pass, the same mechanism a trueColor sprite/tileset record
    -- gets automatically. Only the art gets the exemption; the frame and text
    -- around it stay colorized like the rest of the screen.
    PaletteFX.markTrueColor(x, y, w, h)
    love.graphics.setColor(1, 1, 1, 1)
  end

  -- The dialogue box is the bottom 6 of the 18 tile rows (BOX_TY = 12), so
  -- its top edge sits 12/18 of the way down the play area. Needed to place a
  -- tucked-in portrait ABOVE the text rather than across it.
  local BOX_TOP_FRAC = 12 / 18

  -- `side` comes from the box rather than from the option directly: under
  -- SIDE = AUTO it was resolved once, against the facing the player had when
  -- the box was built, and this hook runs every frame afterwards.
  local function drawMarginPanel(vp, art, side)
    -- GB pixels -> window units. gameWidth is the letterbox, so this tracks
    -- window size and integer scale without reading the renderer.
    local unit = (vp.gameWidth or 0) / 160
    if unit <= 0 then return end

    side = side or "left"
    local pad   = 2 * unit   -- breathing room around the panel
    local frame = 1 * unit   -- the drawn border

    -- How much room actually exists outside the play area on that side. The
    -- old code never asked: it drew at art.mag * unit unconditionally and,
    -- when that overflowed, jumped straight to tucking the panel inside the
    -- play area at the BOTTOM -- i.e. directly over the dialogue box, which
    -- is the one thing this layout exists to avoid. At 1024x768 the play area
    -- is 800 wide, leaving a 112px margin, while a 30px portrait at unit=5
    -- wanted 150px, so that fallback fired every time.
    local marginW = (side == "right")
      and (vp.width - (vp.gameX + vp.gameWidth))
      or  vp.gameX

    -- Draw at the GAME's own pixel scale, always. Anything smaller reads as
    -- a shrunken thumbnail sitting next to full-size art rather than as a
    -- portrait: INSET puts its 30x30 crop at 1x inside the GB canvas and the
    -- renderer blows it up with everything else, so it lands at 30*unit on
    -- screen (150px at unit=5). MARGIN has to match that number or the two
    -- layouts disagree about how big the same picture is.
    --
    -- Fitting the art to the margin instead was the previous attempt, and it
    -- is why this looked tiny: at 1024x768 the play area is 800 wide, so the
    -- margin is only 112px and the best WHOLE fit is 2x -- against a game
    -- drawing at 5x. The margin's width is a fact about the window, not a
    -- budget the portrait should shrink into.
    local scale = math.max(1, math.floor(art.mag * unit))
    local w, h  = art.w * scale, art.h * scale
    local need  = w + 2 * frame + 2 * pad

    local x, y
    if marginW >= need then
      -- Genuinely fits beside the play area (widescreen). Centre it in the
      -- margin, bottom-aligned with the play area like the box beside it.
      local centre = (side == "right")
        and (vp.gameX + vp.gameWidth + marginW / 2)
        or  (marginW / 2)
      x = centre - w / 2
      y = vp.gameY + vp.gameHeight - h - pad
    else
      -- Margin too narrow at full size. Keep the scale and MOVE instead of
      -- shrinking: sit above the dialogue box, straddling the play area's
      -- edge so it soaks up whatever margin does exist and covers as little
      -- of the world as possible. Overlapping the world is a fair trade;
      -- overlapping the text is the one thing this layout exists to prevent.
      if side == "right" then
        x = math.min(vp.width - w - frame - pad, vp.gameX + vp.gameWidth - w / 2)
      else
        x = math.max(frame + pad, vp.gameX - w / 2)
      end
      y = vp.gameY + vp.gameHeight * BOX_TOP_FRAC - h - pad
      if y < vp.gameY + pad then y = vp.gameY + pad end
    end

    -- Whole pixels, so the art lands on the device grid.
    x, y = math.floor(x + 0.5), math.floor(y + 0.5)
    local bx, by, bw, bh = x - frame, y - frame, w + 2 * frame, h + 2 * frame
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", bx, by, bw, bh)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.setLineWidth(math.max(1, frame))
    love.graphics.rectangle("line", bx, by, bw, bh)
    love.graphics.setColor(1, 1, 1, 1)
    if art.directional and side == "left" then
      love.graphics.draw(art.image, x + w, y, 0, -scale, scale)
    else
      love.graphics.draw(art.image, x, y, 0, scale, scale)
    end
  end

  -- ------- the seams
  --
  -- TextBox is a plain module table behind package.loaded, so the engine's own
  -- `require` hands back the table these two lines replace fields on -- every
  -- call site picks the wrappers up, including the ones in battle, which is
  -- why `allowed()` filters those out rather than the wrapper being scoped to
  -- the overworld. The guard keeps a hot reload from stacking a second layer
  -- on the first.

  -- Re-wrapping narrower makes pages longer, and a longer page scrolls
  -- itself.
  --
  -- The box holds two lines. TextBox:update advances to the next line on the
  -- page with no pause at all unless pages.contBefore says that line was
  -- preceded by a `\v` -- the ROM's own <CONT>, which prints the blinking
  -- arrow and waits for A. Vanilla text is authored to two lines per page, so
  -- a third line without a <CONT> simply never happens and the engine has no
  -- reason to guard against one. Narrowing the box manufactures exactly that:
  -- a page the ROM wrote as two lines wraps to three, and line three scrolls
  -- line one away on the typewriter's own clock, unread and unprompted.
  --
  -- Font.split/spansFitting are the same measurements TextBox.paginate uses,
  -- so paginating the same text at the box's ORIGINAL width says precisely
  -- how many lines each page was meant to have. Where ours grew, every line
  -- past the second is marked as a cont -- arrow, A press, one-line scroll,
  -- the ROM's own <CONT> behaviour, reached through the engine's own field
  -- rather than by re-implementing the wait.
  --
  -- Pages themselves can't move: `\f` splits them before any wrapping
  -- happens, so the two paginations always agree page for page, and only the
  -- line counts inside them differ.
  local function keepPageWaits(game, box, rawText, vanillaMaxCols)
    local conts = box.pages and box.pages.contBefore
    if type(conts) ~= "table" then return end
    local vanilla
    local ok, substituted = pcall(TextBox.substitute, game, rawText)
    if ok then
      local ok2, paged = pcall(TextBox.paginate, substituted, vanillaMaxCols)
      if ok2 then vanilla = paged end
    end
    for page, lines in ipairs(conts) do
      -- No vanilla answer (substitution threw): assume the two lines the box
      -- can physically show, which is the vanilla shape for all but the
      -- handful of <CONT> pages -- and those already carry their own waits.
      local was = vanilla and vanilla[page] and #vanilla[page] or 2
      if #lines > was then
        for i = 3, #lines do lines[i] = true end
      end
    end
  end

  if not TextBox.dp_wrapped then
    TextBox.dp_wrapped = true

    local originalNew = TextBox.new
    TextBox.new = function(game, text, onDone, opts)
      local style = opt("style", "inset")
      local art, speaker
      if style ~= "off" and game and allowed(game) then
        speaker = speakerFor(game)
        -- The text's own "NAME: " wins when it's there, even down to
        -- deciding "no portrait" -- see nameArt's comment on why a stale
        -- npc guess is worse than trusting that. Only when the text names
        -- nobody does the npc-based guess get to answer at all.
        local ok, resolved, handled = pcall(nameArt, game, text, speaker)
        if ok and handled then
          art = resolved
        elseif speaker then
          local okArt, resolvedArt = pcall(artFor, game, speaker)
          if okArt then art = resolvedArt end
        end
      end

      local side
      if art then
        local okSide, resolved = pcall(sideFor, game, speaker)
        side = (okSide and resolved) or "left"
        -- A YES/NO box is anchored at Theme.choiceBox.tx = 14 and comes down
        -- over the still-visible text (TextBox opts.choice). On the right
        -- that lands exactly on the portrait, so a box that will ask a
        -- question keeps its art on the left whatever the option says.
        if opts and opts.choice then side = "left" end
      end

      -- Swap the geometry for exactly the length of the constructor. TextBox
      -- copies tx/ty/tw/th/maxCols onto itself and paginates against them
      -- right there, so putting the table back afterwards leaves the new box
      -- narrow and every other box in the game untouched.
      local saved, layout
      if art and (style == "inset" or style == "framed") then
        local base = Theme.textBox
        if base then
          layout = (style == "framed") and framedLayout(base, side)
                   or insetLayout(base, side)
        end
        if layout then
          saved = base
          Theme.textBox = layout.theme
        end
      end

      local ok, box = pcall(originalNew, game, text, onDone, opts)
      if saved then Theme.textBox = saved end
      if not ok then error(box, 0) end

      if layout then
        -- textX is the pen the box starts each line at. FRAMED moved boxTx,
        -- so TextBox.new already derived the right one; INSET didn't, and
        -- applies the indent here rather than smuggling it through the theme.
        if layout.textX then box.textX = layout.textX end
        box.dp_panelTx = layout.panelTx
        box.dp_artX = layout.artCol * 8
        box.dp_artY = (box.boxTy + 1) * 8
        box.dp_artW = layout.artW
        box.dp_artH = (box.boxTh - 2) * 8
        -- opts.auto boxes without .wait (Oak's "Hey! Wait!" bubble in
        -- data/scripts/story2.lua, the trade/Hall of Fame/party-menu
        -- timers, ...) dismiss themselves on a frame count once
        -- self.done fires -- TextBox:update never even looks at self.auto
        -- until every line has finished typing. A synthetic CONT wait
        -- injected here stalls that timer on a manual A-press the
        -- vanilla, un-narrowed box at 18 cols never needed: narrowing for
        -- the portrait can push a 2-line auto message to 3, and without
        -- this guard that synthetic line silently turns a hands-off
        -- cutscene beat into one MARGIN plays on schedule (it never
        -- narrows) but INSET/FRAMED stall on, waiting for a press that
        -- was never supposed to be required. auto.wait boxes (the pet-cry
        -- ones, home/window.asm AutoTextBoxDrawingCommon) fall through to
        -- a plain A/B box once done, same as any other dialogue, so they
        -- keep the protection.
        if not (opts and opts.auto and not opts.auto.wait) then
          pcall(keepPageWaits, game, box, text, saved.maxCols)
        end
      end

      box.dp_art = art
      box.dp_side = side
      return box
    end

    local originalDraw = TextBox.draw
    TextBox.draw = function(self)
      originalDraw(self)
      if not (self.dp_art and self.dp_artX) then return end
      -- A throw here would take the whole frame down, and the box under it is
      -- already drawn correctly. Drop the portrait for this box and carry on.
      if not pcall(drawPortrait, self) then
        self.dp_art, self.dp_artX, self.dp_panelTx = nil, nil, nil
      end
    end
  end

  -- MARGIN draws after the frame composites, so it reads the live top-of-stack
  -- box rather than being called by it.
  mod.hooks:wrap("render.hud", function(next_, game, viewport)
    next_(game, viewport)
    if opt("style", "inset") ~= "margin" then return end
    if not viewport then return end
    local box = topTextBox(game)
    if not (box and box.dp_art) then return end
    local ok, err = pcall(drawMarginPanel, viewport, box.dp_art, box.dp_side)
    if not ok then dlog("drawMarginPanel THREW: %s", tostring(err)) end
  end)

  dlog("=== dialogue_portraits loaded (style=%q) ===", tostring(opt("style", "inset")))

  -- Exported so a companion mod (or a test) can ask the same questions this
  -- one asks, rather than re-deriving them from the world.
  mod.exports.speakerFor = speakerFor
  mod.exports.artFor = artFor
  mod.exports.NAMED_PIC = NAMED_PIC
  mod.exports.NAME_ART = NAME_ART
end
