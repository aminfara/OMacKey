-- Reads `hyprctl binds` (plain text; Hyprland 0.56's -j output for binds is not
-- valid JSON) on stdin and prints one line per bind in the form the snapshot's
-- binds file starts with: chord, " (release)" for release binds, description.
--
-- Usage: hyprctl binds | lua5.5 tests/snapshot/live.lua

local here = arg[0]:match("^(.*)/[^/]*$") or "."
package.path = here .. "/?.lua;" .. package.path
local mock = require("mock")

local MASK = { { 64, "SUPER" }, { 4, "CTRL" }, { 8, "ALT" }, { 1, "SHIFT" } }

local function emit(bind)
  if not bind then
    return
  end
  local key = (bind.key or ""):gsub("^.* %+ ", "")
  if key == "" and bind.keycode and bind.keycode ~= "0" then
    key = "code:" .. bind.keycode
  end
  local parts = {}
  local mask = tonumber(bind.modmask) or 0
  for _, pair in ipairs(MASK) do
    if mask & pair[1] ~= 0 then
      table.insert(parts, pair[2])
    end
  end
  table.insert(parts, key)
  print(string.format("%s%s %q", mock.chord(table.concat(parts, " + ")), bind.release and " (release)" or "",
    bind.description or "nil"))
end

local current
for line in io.lines() do
  local flags = line:match("^bind(%a*)")
  if flags then
    emit(current)
    current = { release = flags:find("r", 1, true) ~= nil }
  elseif current then
    local field, value = line:match("^\t([%a_]+): ?(.*)$")
    if field then
      current[field] = value
    end
  end
end
emit(current)
