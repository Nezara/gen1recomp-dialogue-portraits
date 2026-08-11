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
-- INSET narrows the dialogue box. Theme.textBox is read fresh by every
-- TextBox at construction (src/ui/Theme.lua, src/render/TextBox.lua:54), so
-- swapping it for the length of one constructor call and putting it straight
-- back gives a per-box geometry change with nothing left behind -- a box with
-- no speaker is byte-identical to vanilla. Six tiles buys a 6x6 framed panel
-- whose interior is 32x32, and costs the text six columns (18 -> 12).
-- Drawing happens inside the 160x144 UI canvas, so the panel is
-- palette-mapped and GBC-FX'd along with everything else.
--
-- MARGIN uses the `render.hud` hook instead: window space, over the finished
-- composite, so the portrait can live in the letterbox and cost the text
-- nothing. The trade is that it sits outside the Game Boy pipeline -- no
-- palette, no LCD grid -- so it reads as an overlay rather than as part of
-- the game.

local PANEL_TW = 6              -- tiles taken from the dialogue box for the panel
local MEMORY_SECONDS = 15       -- how long a cutscene speaker stays remembered
local ART_DIR = "art/trainers/" -- pre-baked crops, mod-relative (see art/trainers/README)

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

return function(mod)
  local TextBox   = require("src.render.TextBox")
  local Theme     = require("src.ui.Theme")
  local Font      = require("src.render.Font")
  local Collision = require("src.world.Collision")
  local PaletteFX = require("src.render.PaletteFX")

  -- One call, always: mod.options:define REPLACES the option set rather than
  -- adding to it, so a second call would silently wipe the first.
  mod.options:define({
    { key = "style", label = "PORTRAIT", type = "choice", default = "inset",
      choices = { { "INSET", "inset" }, { "MARGIN", "margin" }, { "OFF", "off" } } },
    { key = "side", label = "SIDE", type = "choice", default = "left",
      choices = { { "LEFT", "left" }, { "RIGHT", "right" } } },
    { key = "battle", label = "IN BATTLE", type = "toggle", default = false },
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

  local function speakerFor(game)
    local ok, npc = pcall(scriptNpc, game)
    if ok and npc then return npc end
    ok, npc = pcall(facingNpc, game)
    if ok and npc then return npc end
    if lastNpc and (now() - lastNpcAt) <= MEMORY_SECONDS then return lastNpc end
    return nil
  end

  -- ------- art

  -- id -> art record, or false for "looked, nothing there". Caching the miss
  -- matters: without it every box for a portrait-less NPC retries a failing
  -- image load.
  local customCache, trainerCache = {}, {}

  -- Small custom art gets doubled in MARGIN mode, where there is room and a
  -- 16x16 image at 1x would be a postage stamp. INSET ignores this and fits
  -- to the panel interior instead.
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

  -- record.pic is a full ROM path (".../battle/trainers/brock.png"); the
  -- pre-baked crop sitting in this mod's own art/trainers/ keeps the same
  -- basename, so this is the only translation needed between the two.
  local function basenameOf(path)
    return path and path:match("([^/]+)%.png$")
  end

  -- Loads this mod's own pre-baked crop (see the header comment on why the
  -- crop is baked rather than computed here) through mod.assets:image, same
  -- path a player's own portraits/ override goes through -- just a
  -- different folder, so both land in a plain, uncached-miss-safe art
  -- record with no Quad or engine Assets reach involved.
  local function trainerArt(basename)
    if not basename then return nil end
    local hit = trainerCache[basename]
    if hit ~= nil then return hit or nil end
    local ok, image = pcall(function()
      return mod.assets:image(ART_DIR .. basename .. ".png")
    end)
    if not ok or not image then
      trainerCache[basename] = false
      return nil
    end
    local w, h = image:getDimensions()
    local art = { image = image, w = w, h = h, mag = 1 }
    trainerCache[basename] = art
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

    return customArt(def.trainerClass) or customArt(def.sprite)
           or classArt(game, def, def.sprite)
  end

  -- ------- state queries

  local function battleActive(game)
    local states = game and game.stack and game.stack.states
    if not states then return false end
    for i = #states, 1, -1 do
      if states[i].isBattle then return true end
    end
    return false
  end

  local function allowed(game)
    if opt("battle", false) then return true end
    return not battleActive(game)
  end

  -- Only the top of the stack counts: a `stay` box left sitting under a menu
  -- (the Viridian school blackboard) is not the conversation on screen.
  local function topTextBox(game)
    local states = game and game.stack and game.stack.states
    if not states then return nil end
    for i = #states, math.max(1, #states - 2), -1 do
      if states[i].isTextBox then return states[i] end
    end
    return nil
  end

  -- ------- drawing

  -- Centred, and snapped to a whole scale whenever the art actually fits, so
  -- pixel art stays on the pixel grid. The 30x30 crop against the INSET
  -- panel's 32x32 interior lands on a clean 1x with a pixel of padding each
  -- side; only art bigger than its hole (a custom override, say) goes
  -- fractional.
  local function blitArt(art, x, y, w, h)
    local scale = math.min(w / art.w, h / art.h)
    if scale >= 1 then scale = math.floor(scale) end
    local dx = x + math.floor((w - art.w * scale) / 2)
    local dy = y + math.floor((h - art.h * scale) / 2)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(art.image, dx, dy, 0, scale, scale)
  end

  local function drawInsetPanel(box)
    local tx, ty, th = box.dp_panelTx, box.boxTy, box.boxTh
    -- The dialogue box declares itself edge-anchored under UI LAYOUT =
    -- DYNAMIC (TextBox:draw -> Renderer:setUIAnchor). The panel has to make
    -- the same declaration or it stays behind in the letterbox while the box
    -- it belongs to docks to the window bottom.
    local renderer = box.game and box.game.renderer
    if renderer and renderer.setUIAnchor then
      renderer:setUIAnchor(tx * 8, ty * 8, PANEL_TW * 8, th * 8, "bottom")
    end
    love.graphics.setColor(0, 0, 0, 1)
    Font.drawBox(tx, ty, PANEL_TW, th)
    local px, py = (tx + 1) * 8, (ty + 1) * 8
    local pw, ph = (PANEL_TW - 2) * 8, (th - 2) * 8
    blitArt(box.dp_art, px, py, pw, ph)
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
    -- gets automatically. Only the art gets the exemption; the frame stays
    -- colorized like the rest of the dialogue box.
    PaletteFX.markTrueColor(px, py, pw, ph)
    love.graphics.setColor(1, 1, 1, 1)
  end

  local function drawMarginPanel(vp, art)
    -- GB pixels -> window units. gameWidth is the letterbox, so this tracks
    -- window size and integer scale without reading the renderer.
    local unit = (vp.gameWidth or 0) / 160
    if unit <= 0 then return end
    local w, h = art.w * art.mag * unit, art.h * art.mag * unit
    local pad = 4 * unit
    local x
    if opt("side", "left") == "right" then
      x = vp.gameX + vp.gameWidth + pad
      -- no room out there: tuck it just inside the play area instead
      if x + w + pad > vp.width then x = vp.gameX + vp.gameWidth - w - pad end
    else
      x = vp.gameX - w - pad
      if x < pad then x = vp.gameX + pad end
    end
    local y = vp.gameY + vp.gameHeight - h - pad
    local bx, by, bw, bh = x - 2 * unit, y - 2 * unit, w + 4 * unit, h + 4 * unit
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("fill", bx, by, bw, bh)
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.setLineWidth(math.max(1, unit))
    love.graphics.rectangle("line", bx, by, bw, bh)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(art.image, x, y, 0, art.mag * unit, art.mag * unit)
  end

  -- ------- the seams
  --
  -- TextBox is a plain module table behind package.loaded, so the engine's own
  -- `require` hands back the table these two lines replace fields on -- every
  -- call site picks the wrappers up, including the ones in battle. The guard
  -- keeps a hot reload from stacking a second layer on the first.

  if not TextBox.dp_wrapped then
    TextBox.dp_wrapped = true

    local originalNew = TextBox.new
    TextBox.new = function(game, text, onDone, opts)
      local style = opt("style", "inset")
      local art
      if style ~= "off" and game and allowed(game) then
        local speaker = speakerFor(game)
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

      -- Swap the geometry for exactly the length of the constructor. TextBox
      -- copies tx/ty/tw/th/maxCols onto itself and paginates against them
      -- right there, so putting the table back afterwards leaves the new box
      -- narrow and every other box in the game untouched.
      local saved, panelTx
      if art and style == "inset" then
        local base = Theme.textBox
        if base and (base.tw or 0) > PANEL_TW + 4 then
          saved = base
          local tw = base.tw - PANEL_TW
          local maxCols = base.maxCols - PANEL_TW
          -- A YES/NO box is anchored at Theme.choiceBox.tx = 14 and comes down
          -- over the still-visible text (TextBox opts.choice). On the right
          -- that lands exactly on the portrait, so a box that will ask a
          -- question keeps its panel on the left whatever the option says.
          local side = opt("side", "left")
          if opts and opts.choice then side = "left" end
          if side == "right" then
            panelTx = base.tx + tw
            Theme.textBox = { tx = base.tx, ty = base.ty, tw = tw,
                              th = base.th, maxCols = maxCols }
          else
            panelTx = base.tx
            Theme.textBox = { tx = base.tx + PANEL_TW, ty = base.ty, tw = tw,
                              th = base.th, maxCols = maxCols }
          end
        end
      end

      local ok, box = pcall(originalNew, game, text, onDone, opts)
      if saved then Theme.textBox = saved end
      if not ok then error(box, 0) end

      box.dp_art = art
      box.dp_panelTx = panelTx
      return box
    end

    local originalDraw = TextBox.draw
    TextBox.draw = function(self)
      originalDraw(self)
      if not (self.dp_art and self.dp_panelTx) then return end
      -- A throw here would take the whole frame down, and the box under it is
      -- already drawn correctly. Drop the portrait for this box and carry on.
      if not pcall(drawInsetPanel, self) then
        self.dp_art, self.dp_panelTx = nil, nil
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
    pcall(drawMarginPanel, viewport, box.dp_art)
  end)

  -- Exported so a companion mod (or a test) can ask the same questions this
  -- one asks, rather than re-deriving them from the world.
  mod.exports.speakerFor = speakerFor
  mod.exports.artFor = artFor
  mod.exports.NAMED_PIC = NAMED_PIC
  mod.exports.NAME_ART = NAME_ART
end
