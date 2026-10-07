-- Moves or drops Omarchy's default binds while Omarchy registers them: hook()
-- wraps hl.bind right before Omarchy's defaults load, unhook() restores it
-- right after. Omarchy's own o.bind calls therefore land on the keys from
-- relocations.lua with their original action, description and conditions, and
-- a dropped bind is never registered at all.

local keys = require("hypr.omackey.lib.keys")
local relocations = require("hypr.omackey.relocations")

local M = {
  relocations = relocations, -- the rows of relocations.lua
  applied = {}, -- { from, to, description } for every bind that was moved
  dropped = {}, -- { from, description } for every bind that was not registered
  claimed = {}, -- normalized key string → true, for every key Omarchy registered
}

local original_bind
local index

function M.hook()
  if original_bind then
    return
  end

  index = {}
  for _, relocation in ipairs(relocations) do
    index[keys.normalize(relocation.from)] = relocation
  end

  original_bind = hl.bind
  hl.bind = function(chord, dispatcher, opts)
    local relocation = index[keys.normalize(chord)]
    local description = opts and opts.description

    if relocation then
      relocation.used = true

      if relocation.drop then
        table.insert(M.dropped, { from = chord, description = description })
        return nil -- no keybind object: Omarchy's o.bind ignores the return value
      end

      table.insert(M.applied, { from = chord, to = relocation.to, description = description })
      chord = relocation.to
    end
    M.claimed[keys.normalize(chord)] = true

    return original_bind(chord, dispatcher, opts)
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
