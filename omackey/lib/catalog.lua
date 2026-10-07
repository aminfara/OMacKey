-- The data model of what OMacKey does, read from the registry the config was
-- built from (lib/bind.lua), the apps (lib/profiles.lua), the relocations
-- (lib/relocate.lua) and the settings (settings.lua). It is the one place the
-- docs generator, omackey.explain() and the snapshot's metadata read, so none
-- of them knows how the registry is laid out.
--
-- It only reads tables: nothing here calls Hyprland, so it loads in the
-- snapshot's fake Hyprland and in Omarchy's help-menu replay too. Call it
-- after the config was built; each function returns fresh tables.
--
--   catalog.keys()         → one row per declared key, in declaration order
--   catalog.apps()         → the apps, in match order
--   catalog.relocations()  → Omarchy keys moved or dropped, in file order
--   catalog.settings()     → the user options
--   catalog.find(id)       → the row of one key, or nil

local action_lib = require("hypr.omackey.lib.action")
local bind = require("hypr.omackey.lib.bind")
local keys = require("hypr.omackey.lib.keys")
local profiles = require("hypr.omackey.lib.profiles")
local relocate = require("hypr.omackey.lib.relocate")
local relocations = require("hypr.omackey.relocations")
local settings = require("hypr.omackey.settings")

local M = {}

local function condition_of(spec)
  if spec.requires then
    return "needs " .. spec.requires .. " on PATH"
  elseif spec.setting then
    return "setting " .. spec.setting
  elseif spec.enabled == false then
    return "disabled"
  end
end

-- One key:
--   id, keys (the exact string Hyprland is given, for hl.unbind), mac (glyph, "⇧⌘["),
--   desc (what the help menu shows), category, file,
--   flags { repeating, release, native (bound as a Hyprland dispatcher) },
--   action     text of the action that is the same in every app, or nil
--   default    text of the generic action, or nil (the raw key passes through)
--   apps       { [app name] = text } for the apps that differ
--   condition  why it may be unbound ("setting emacs_keys", "needs wtype on PATH"), or nil
--   bound      whether it is bound on this machine
--   catchall   whether the catch-all generated it
local function key_row(spec)
  local row = {
    id = spec.id,
    keys = spec.keys,
    mac = spec.mac,
    desc = spec.desc,
    category = spec.category,
    file = spec.file,
    flags = {
      repeating = spec.repeating or false,
      release = spec.release or false,
      native = spec.action ~= nil and spec.handler == nil and spec.bound == true,
    },
    apps = {},
    condition = condition_of(spec),
    bound = spec.bound == true,
    catchall = spec.catchall or false,
  }

  if spec.action ~= nil then
    row.action = action_lib.text_of(spec.action)
  end
  for name, action in pairs(spec.actions or {}) do
    if name == "default" then
      row.default = action_lib.text_of(action)
    else
      row.apps[name] = action_lib.text_of(action)
    end
  end

  return row
end

function M.keys()
  local rows = {}
  for _, spec in ipairs(bind.registry) do
    table.insert(rows, key_row(spec))
  end
  return rows
end

function M.find(id)
  local spec = bind.by_id[id]
  return spec and key_row(spec)
end

-- One app: name, family, classes and tags (what makes a window this app; the
-- first app in match order wins), and catchall (the text of its action on
-- every catch-all key, or nil).
function M.apps()
  local rows = {}
  for _, def in ipairs(profiles.apps) do
    table.insert(rows, {
      name = def.name,
      family = def.family,
      classes = def.classes or {},
      tags = def.tags or {},
      catchall = def.catchall ~= nil and action_lib.text_of(def.catchall) or nil,
    })
  end
  return rows
end

-- One relocation: from (Omarchy's key), to (its new key; nil when dropped),
-- dropped, description (Omarchy's; nil when Omarchy no longer registers the
-- bind), optional (Omarchy only registers it under a condition), used (the
-- bind was found while loading Omarchy's defaults).
function M.relocations()
  local seen = {}
  for _, row in ipairs(relocate.applied) do
    seen[keys.normalize(row.from)] = row.description
  end
  for _, row in ipairs(relocate.dropped) do
    seen[keys.normalize(row.from)] = row.description
  end

  local rows = {}
  for _, row in ipairs(relocations) do
    table.insert(rows, {
      from = row.from,
      to = row.to,
      dropped = row.drop or false,
      description = seen[keys.normalize(row.from)],
      optional = row.optional or false,
      used = row.used or false,
    })
  end
  return rows
end

-- One option: name, default, doc, and its value now (the user's file applied).
function M.settings()
  local rows = {}
  for _, option in ipairs(settings.options) do
    table.insert(rows, {
      name = option.name,
      default = option.default,
      doc = option.doc,
      value = settings[option.name],
    })
  end
  return rows
end

return M
