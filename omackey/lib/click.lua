-- ⌘-click as Ctrl-click (Phase 7g). The real ⌘ + press is consumed and a
-- synthetic press with Ctrl goes to the app instead (lib/send.lua `button`).
--
-- Hyprland never saw the real press as held, so it drops the real release: the
-- synthetic press has to be closed by us, whatever modifiers are held when the
-- button comes up (⌘ may be released first). `pending` remembers the modifiers of
-- the press that is still open; a release without one passes through untouched.

local button = require("hypr.omackey.lib.send").button

local M = {
  pending = nil, -- e.g. "CTRL" while a synthetic press is open
}

-- Bind handler for the press: consumed.
function M.press(mods)
  return function()
    M.pending = mods
    button(mods, "mouse:272", "down")()
  end
end

-- Bind handler for the release, used on every modifier state a release can have.
function M.release()
  local mods = M.pending
  if not mods then
    return { ok = false } -- an ordinary release: let it through
  end

  M.pending = nil
  button(mods, "mouse:272", "up")()
end

return M
