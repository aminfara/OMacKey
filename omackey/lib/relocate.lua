-- Moves Omarchy's default binds to new keys while Omarchy registers them
-- (PLAN.md §4.3, approach A): hook() wraps hl.bind right before Omarchy's
-- defaults load, unhook() restores it right after. Omarchy's own o.bind calls
-- therefore land on the keys from relocations.lua with their original action,
-- description and conditions.

local relocations = require("hypr.omackey.relocations")

local M = {
  applied = {}, -- { from, to, description } for every bind that was moved
}

local MODIFIER_ORDER = { SUPER = 1, CTRL = 2, ALT = 3, SHIFT = 4 }
local MODIFIER_ALIASES = { CONTROL = "CTRL" }

-- "SUPER + ALT + SHIFT + F" and "super + shift + alt + f" → "SUPER + ALT + SHIFT + f"
function M.normalize(keys)
  local modifiers, key = {}, ""

  for part in tostring(keys):gmatch("[^+]+") do
    local trimmed = part:match("^%s*(.-)%s*$")
    local upper = trimmed:upper()
    upper = MODIFIER_ALIASES[upper] or upper

    if MODIFIER_ORDER[upper] then
      table.insert(modifiers, upper)
    else
      key = trimmed:lower()
    end
  end

  table.sort(modifiers, function(a, b)
    return MODIFIER_ORDER[a] < MODIFIER_ORDER[b]
  end)
  table.insert(modifiers, key)

  return table.concat(modifiers, " + ")
end

local original_bind
local index

function M.hook()
  if original_bind then
    return
  end

  index = {}
  for _, relocation in ipairs(relocations) do
    index[M.normalize(relocation.from)] = relocation
  end

  original_bind = hl.bind
  hl.bind = function(keys, dispatcher, opts)
    local relocation = index[M.normalize(keys)]
    if relocation then
      relocation.used = true
      table.insert(M.applied, {
        from = keys,
        to = relocation.to,
        description = opts and opts.description,
      })
      keys = relocation.to
    end

    return original_bind(keys, dispatcher, opts)
  end
end

function M.unhook()
  if original_bind then
    hl.bind = original_bind
    original_bind = nil
  end
end

-- Relocations whose Omarchy key was never registered: Omarchy changed or
-- dropped that bind, so the table needs updating. Rows marked `optional` are
-- skipped: Omarchy only registers those binds under a condition (e.g.
-- preinstalled apps enabled).
function M.unused()
  local unused = {}
  for _, relocation in ipairs(relocations) do
    if not relocation.used and not relocation.optional then
      table.insert(unused, relocation.from)
    end
  end

  return unused
end

return M
