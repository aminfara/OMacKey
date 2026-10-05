-- Mac mode on/off (Phase 7d). The switch is a state file, read once at load:
--
--   ${XDG_STATE_HOME:-~/.local/state}/omackey/off   exists → OMacKey is off
--
-- Off means load.lua skips the relocations and every Mac bind, so Omarchy's own
-- bindings come back untouched, and registers only the toggle key below.
-- scripts/omackey-mode flips the same file from a terminal.

local M = {}

local home = os.getenv("HOME") or ""
local state_home = os.getenv("XDG_STATE_HOME")
if not state_home or state_home == "" then
  state_home = home .. "/.local/state"
end

M.dir = state_home .. "/omackey"
M.file = M.dir .. "/off"
M.key = "CTRL + SUPER + SHIFT + M" -- ⌃⌘⇧M, free in Omarchy

function M.enabled()
  local handle = io.open(M.file, "r")
  if handle then
    handle:close()
    return false
  end
  return true
end

-- Flip the switch and reload. External commands only: bind callbacks must not
-- block, and the reload starts a fresh Lua state that reads the new state file.
function M.toggle()
  local turning_off = M.enabled()
  local command, message
  if turning_off then
    command = "mkdir -p '" .. M.dir .. "' && touch '" .. M.file .. "'"
    message = "OMacKey is off: Omarchy keys"
  else
    command = "rm -f '" .. M.file .. "'"
    message = "OMacKey is on: Mac keys"
  end

  hl.dispatch(hl.dsp.exec_cmd(
    command .. " && notify-send -a OMacKey '" .. message .. "' ; hyprctl reload"
  ))
end

-- The one bind that exists in both modes.
function M.bind()
  hl.bind(M.key, M.toggle, { description = "OMacKey on/off (Mac mode)" })
end

return M
