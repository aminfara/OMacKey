-- Mac shortcuts in three steps: declare, build, bind.
--
-- 1. Declare: mac{} and catchall{} only record specs; nothing reaches Hyprland.
-- 2. build() validates the complete set, decides what is enabled, and expands
--    the catch-all against every chord already claimed.
-- 3. apply() binds every valid, enabled spec in one loop.
--
-- A spec has either `action` (the same in every app) or `actions` (one per app
-- profile, picked for the active window at press time):
--
--   mac({
--     id = "line-start", category = "Cursor", mac = "⌘←",
--     keys = "SUPER + LEFT", desc = "Line start", repeating = true,
--     actions = {
--       default = send.tap("", "Home"),  -- function: run it
--       terminal = CONSUME,              -- do nothing
--       vscode = PASS,                   -- let the app receive the raw key
--     },
--   })
--
--   mac({
--     id = "close-window", category = "Windows", mac = "⌘⇧W",
--     keys = "SUPER + SHIFT + W", desc = "Close window",
--     action = hl.dsp.window.close(),    -- a dispatcher is bound natively
--   })
--
-- An action is a function (it may return { ok = false } to pass the key
-- through), a callable table, a Hyprland dispatcher, PASS or CONSUME.
-- `enabled = false` or `requires = "<command>"` (not on PATH) declares a spec
-- that is not bound.

local config = require("hypr.omackey.config")
local apps = require("hypr.omackey.lib.apps")
local keys = require("hypr.omackey.lib.keys")
local relocate = require("hypr.omackey.lib.relocate")

local PASS, CONSUME = "pass", "consume"

local M = {
  PASS = PASS,
  CONSUME = CONSUME,
  registry = {}, -- every declared spec, then the catch-all's, in order
  by_id = {},
  bound = {}, -- the specs apply() bound, in bind order
  errors = {}, -- validation errors from build()
}

local catchall_candidates = {}

-- Declare ---------------------------------------------------------------

function M.mac(spec)
  table.insert(M.registry, spec)
  return spec
end

-- The catch-all: specs for chords that apply only where nothing else (no
-- other spec, no Omarchy bind) claims the chord. Expanded by build().
function M.catchall(specs)
  for _, spec in ipairs(specs) do
    table.insert(catchall_candidates, spec)
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

local profile_names = { default = true }
for _, profile in ipairs(config.profiles) do
  profile_names[profile.name] = true
end

-- The first problem with a spec, or nil.
local function problem(spec)
  for _, field in ipairs({ "id", "keys", "desc" }) do
    if spec[field] == nil then
      return "needs '" .. field .. "'"
    end
  end
  if (spec.action == nil) == (spec.actions == nil) then
    return "needs either 'action' or 'actions'"
  end
  if spec.action ~= nil and not kind_of(spec.action) then
    return "has an invalid action " .. string.format("%q", tostring(spec.action))
  end
  for profile, action in pairs(spec.actions or {}) do
    if not profile_names[profile] then
      return "has an unknown app profile '" .. tostring(profile) .. "'"
    end
    if not kind_of(action) then
      return "has an invalid action for " .. profile .. ": " .. string.format("%q", tostring(action))
    end
  end
end

local present = {}
local function enabled(spec)
  if spec.enabled == false then
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

-- Validates every declared spec, expands the catch-all and leaves the specs
-- to bind in M.valid. Returns the errors; a faulty spec is left out.
function M.build()
  local valid, taken, claimed = {}, {}, {}

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
    hl.dispatch(action)
    return
  end
  return action() -- may return { ok = false } to pass the key through
end

local function run(spec)
  for _, profile in ipairs(apps.chain(hl.get_active_window())) do
    local action = spec.actions[profile]
    if action ~= nil then
      return perform(action)
    end
  end

  -- No action for any profile: behave as if the bind did not exist.
  return { ok = false }
end

local function bind(spec)
  if spec.action ~= nil and kind_of(spec.action) == "dispatcher" then
    hl.bind(spec.keys, spec.action, {
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
    auto_consuming = true,
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
