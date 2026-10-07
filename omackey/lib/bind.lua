-- Mac shortcuts in three steps: declare, build, bind.
--
-- 1. Declare: mac{}, catchall{} and app{} (lib/profiles.lua) only record
--    specs; nothing reaches Hyprland.
-- 2. build() validates the complete set, decides what is enabled, expands the
--    catch-all against every chord already claimed, and overlays each app's
--    actions on the specs.
-- 3. apply() binds every valid, enabled spec in one loop.
--
-- A spec has either `action` (the same in every app; apps can't change it) or
-- `actions`: what it does in a generic app (`default`), to which the apps add
-- their own entries by key id. The entry for the active window's app is
-- picked at press time. Without `default` the raw key passes through in
-- apps that have no entry.
--
--   mac({
--     id = "line-start",
--     keys = "SUPER + LEFT", desc = "Line start", repeating = true,
--     actions = {
--       default = send.tap("", "Home"),  -- function: run it
--     },
--   })
--
--   -- apps/terminal.lua
--   app({ name = "terminal", …, actions = {
--     ["line-start"] = CONSUME,          -- do nothing
--   } })
--
--   mac({
--     id = "close-window",
--     keys = "SUPER + SHIFT + W", desc = "Close window",
--     action = does("Close the window", hl.dsp.window.close()), -- bound natively
--   })
--
-- An action is a function (it may return { ok = false } to pass the key
-- through), a Hyprland dispatcher, PASS or CONSUME, and carries a text saying
-- what it does (lib/action.lua): send.tap / send.seq make their own, and
-- does("text", fn_or_dispatcher) adds one. build() rejects an action without
-- a text.
--
-- `keys` is written the one way keys.canonical() gives (modifiers SUPER, CTRL,
-- ALT, SHIFT; see lib/keys.lua); build() rejects any other spelling, so users
-- can hl.unbind the string the docs show. The Mac glyph (`mac`, "⇧⌘[") is
-- derived from it; only a key with no glyph (a mouse button, an XF86 key)
-- spells it out: mac = "⌘-click".
--
-- A spec is declared but not bound when `enabled = false`, when
-- `setting = "<option>"` names a false user option (settings.lua), or when
-- `requires = "<command>"` is not on PATH. `plain = true` binds a function
-- without auto_consuming: its key is always consumed.

local action_lib = require("hypr.omackey.lib.action")
local keys = require("hypr.omackey.lib.keys")
local profiles = require("hypr.omackey.lib.profiles")
local relocate = require("hypr.omackey.lib.relocate")
local settings = require("hypr.omackey.settings")
local tap = require("hypr.omackey.lib.send").tap

local PASS, CONSUME = action_lib.PASS, action_lib.CONSUME

local M = {
  PASS = PASS,
  CONSUME = CONSUME,
  does = action_lib.does,
  registry = {}, -- every declared spec, then the catch-all's, in order
  by_id = {},
  bound = {}, -- the specs apply() bound, in bind order
  errors = {}, -- validation errors from build()
}

local catchall_candidates = {}

-- Declare ---------------------------------------------------------------

-- The file a spec was declared in (for the docs), from the caller `level`
-- frames up.
local function source_file(level)
  local info = debug and debug.getinfo and debug.getinfo(level + 1, "S")
  return info and info.source and info.source:match("([^/@]+)$") or nil
end

function M.mac(spec)
  if spec.action == nil and spec.actions == nil then
    spec.actions = {}
  end
  spec.file = spec.file or source_file(2)
  spec.mac = spec.mac or keys.glyph(spec.keys)
  table.insert(M.registry, spec)
  return spec
end

-- group("Text", { mac({…}), mac({…}) }): gives the specs of one section their
-- category.
function M.group(category, specs)
  for _, spec in ipairs(specs) do
    spec.category = category
  end
end

-- The catch-all: for every covered key and modifier variant, a spec that
-- sends Ctrl (or Ctrl+Shift) + the same key, or consumes the chord. build()
-- keeps only the chords nothing else claims (no other spec, no Omarchy bind).
--
--   catchall({
--     category = "Catch-all",
--     covers = { "letter", "punctuation", "return" },  -- key kinds or names (lib/keys.lua)
--     variants = { { keys = "SUPER", sends = "CTRL", glyph = "⌘", text = "Ctrl+" }, … },
--     consumed = { "SUPER + H", … },                     -- nothing is sent
--   })
function M.catchall(decl)
  local file = source_file(2)
  local covers, consumed = {}, {}
  for _, item in ipairs(decl.covers) do
    covers[item] = true
  end
  for _, chord in ipairs(decl.consumed or {}) do
    consumed[keys.normalize(chord)] = true
  end

  for _, variant in ipairs(decl.variants) do
    for _, key in ipairs(keys.list) do
      if covers[key.kind] or covers[key.name] then
        local chord = keys.canonical(variant.keys .. " + " .. key.name)
        local name = variant.glyph .. key.glyph -- in descriptions and ids, as written

        local desc, default = name .. " sent as " .. variant.text .. key.label, tap(variant.sends, key.name)
        if consumed[keys.normalize(chord)] then
          desc, default = name .. " not mapped", CONSUME
        end

        table.insert(catchall_candidates, {
          id = "catchall-" .. variant.glyph .. key.name,
          category = decl.category,
          file = file,
          mac = keys.glyph(chord),
          keys = chord,
          desc = desc,
          actions = { default = default },
        })
      end
    end
  end
end

-- Build -----------------------------------------------------------------

local function kind_of(action)
  local value_type = type(action)
  if value_type == "function" then
    return "function"
  elseif action == PASS or action == CONSUME then
    return action
  elseif value_type == "table" then
    local meta = getmetatable(action)
    return (meta and meta.__call) and "function" or "dispatcher"
  elseif value_type == "userdata" then
    return "dispatcher"
  end
end

-- Why an action can't be used, or nil: not an action at all, or no text.
local function flaw(action)
  if not kind_of(action) then
    return "is invalid: " .. string.format("%q", tostring(action))
  elseif not action_lib.text_of(action) then
    return "has no text (describe it with does(\"…\", …))"
  end
end

-- The first problem with a spec, or nil.
local function problem(spec)
  for _, field in ipairs({ "id", "keys", "desc" }) do
    if spec[field] == nil then
      return "needs '" .. field .. "'"
    end
  end
  if spec.keys ~= keys.canonical(spec.keys) then
    return "should write its keys \"" .. keys.canonical(spec.keys) .. "\" (not \"" .. spec.keys .. "\")"
  end
  if spec.action ~= nil and spec.actions ~= nil then
    return "has both 'action' and 'actions'"
  end
  if spec.action ~= nil and flaw(spec.action) then
    return "has an action that " .. flaw(spec.action)
  end
  if spec.setting ~= nil and type(settings[spec.setting]) ~= "boolean" then
    return "names an unknown on/off setting '" .. tostring(spec.setting) .. "'"
  end
  for profile, action in pairs(spec.actions or {}) do
    if profile ~= "default" and not profiles.by_name[profile] then
      return "has an unknown app '" .. tostring(profile) .. "'"
    end
    if flaw(action) then
      return "has an action for " .. profile .. " that " .. flaw(action)
    end
  end
end

local present = {}
local function enabled(spec)
  if spec.enabled == false or (spec.setting and not settings[spec.setting]) then
    return false
  end
  if spec.requires then
    if present[spec.requires] == nil then
      present[spec.requires] = o.cmd_present(spec.requires)
    end
    return present[spec.requires]
  end
  return true
end

local function chord_of(spec)
  return keys.normalize(spec.keys) .. (spec.release and " (release)" or "")
end

-- Adds each app's actions to the specs it names, and its catch-all rule to
-- every spec the catch-all generated. A faulty entry is reported and left out.
local function overlay(fail_app)
  for _, def in ipairs(profiles.apps) do
    for id, action in pairs(def.actions or {}) do
      local spec = M.by_id[id]
      if not spec then
        fail_app(def, "names an unknown key id '" .. tostring(id) .. "'")
      elseif spec.actions == nil then
        fail_app(def, "can't change '" .. id .. "', which has one action for every app")
      elseif flaw(action) then
        fail_app(def, "has an action for '" .. id .. "' that " .. flaw(action))
      elseif spec.actions[def.name] ~= nil then
        fail_app(def, "sets '" .. id .. "' twice")
      else
        spec.actions[def.name] = action
      end
    end

    if def.catchall ~= nil then
      if flaw(def.catchall) then
        fail_app(def, "has a catchall action that " .. flaw(def.catchall))
      else
        for _, spec in ipairs(M.registry) do
          if spec.catchall then
            if spec.actions[def.name] ~= nil then
              fail_app(def, "sets '" .. spec.id .. "' twice (catchall)")
            else
              spec.actions[def.name] = def.catchall
            end
          end
        end
      end
    end
  end
end

-- Validates every declared spec and app, expands the catch-all, overlays the
-- apps and leaves the specs to bind in M.valid. Returns the errors; a faulty
-- spec or app entry is left out.
function M.build()
  local valid, taken, claimed = {}, {}, {}

  profiles.build(M.errors)

  for _, relocation in ipairs(relocate.relocations) do
    if relocation.to and relocation.to ~= keys.canonical(relocation.to) then
      table.insert(M.errors, "relocation of '" .. relocation.from .. "' should move it to \""
        .. keys.canonical(relocation.to) .. "\" (not \"" .. relocation.to .. "\")")
    end
  end

  local function fail(spec, message)
    table.insert(M.errors, "'" .. tostring(spec.id or spec.keys) .. "' " .. message)
  end

  for _, spec in ipairs(M.registry) do
    local message = problem(spec)
    if not message and M.by_id[spec.id] then
      message = "is a duplicate id"
    end

    if message then
      fail(spec, message)
    else
      M.by_id[spec.id] = spec
      if enabled(spec) then
        local chord = chord_of(spec)
        if taken[chord] then
          message = "has the same keys as '" .. taken[chord].id .. "'"
        elseif relocate.claimed[keys.normalize(spec.keys)] then
          message = "is on keys Omarchy still binds (" .. spec.keys .. ")"
        end

        if message then
          fail(spec, message)
        else
          taken[chord] = spec
          claimed[keys.normalize(spec.keys)] = true
          table.insert(valid, spec)
        end
      end
    end
  end

  for _, spec in ipairs(catchall_candidates) do
    local chord = keys.normalize(spec.keys)
    if not claimed[chord] and not relocate.claimed[chord] then
      spec.catchall = true
      table.insert(M.registry, spec)
      M.by_id[spec.id] = spec
      table.insert(valid, spec)
    end
  end

  overlay(function(def, message)
    table.insert(M.errors, "app '" .. def.name .. "' " .. message)
  end)

  M.valid = valid
  return M.errors
end

-- Bind ------------------------------------------------------------------

local function perform(action)
  if action == PASS then
    return { ok = false }
  elseif action == CONSUME then
    return
  elseif kind_of(action) == "dispatcher" then
    hl.dispatch(action_lib.unwrap(action))
    return
  end
  return action() -- may return { ok = false } to pass the key through
end

local function run(spec)
  for _, profile in ipairs(profiles.chain(hl.get_active_window())) do
    local action = spec.actions[profile]
    if action ~= nil then
      return perform(action)
    end
  end

  -- No action for any app in the chain: behave as if the bind did not exist.
  return { ok = false }
end

local function bind(spec)
  if spec.action ~= nil and kind_of(spec.action) == "dispatcher" then
    hl.bind(spec.keys, action_lib.unwrap(spec.action), {
      description = spec.desc,
      repeating = spec.repeating,
      release = spec.release,
    })
    return
  end

  spec.fired = 0 -- press count, for tests: hyprctl repl 'return omackey.fired("line-start")'
  spec.handler = function()
    spec.fired = spec.fired + 1
    if spec.action ~= nil then
      return perform(spec.action)
    end
    return run(spec)
  end

  -- auto_consuming: a handler returning { ok = false } passes the key through.
  hl.bind(spec.keys, spec.handler, {
    description = spec.desc,
    repeating = spec.repeating,
    release = spec.release,
    auto_consuming = not spec.plain or nil,
  })
end

function M.apply()
  for _, spec in ipairs(M.registry) do
    spec.bound = false
  end
  for _, spec in ipairs(M.valid or {}) do
    bind(spec)
    spec.bound = true
    table.insert(M.bound, spec)
  end
end

return M
