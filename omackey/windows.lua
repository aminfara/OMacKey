-- Phase 4: window and tab controls (PLAN.md §5).

local mac = require("hypr.omackey.lib.bind").mac
local tap = require("hypr.omackey.lib.send").tap

local function close_window()
  hl.dispatch(hl.dsp.window.close())
end

-- Omarchy's "Close window" moved to ⌃⌥W in Phase 1a, so ⌘W was free.
mac({
  id = "close-tab",
  category = "Windows",
  mac = "⌘W",
  keys = "SUPER + W",
  desc = "Close tab or window",
  actions = {
    default = tap("CTRL", "W"),
    -- foot, Alacritty and Omarchy's TUIs have no tabs, so close the window.
    -- Ghostty and kitty tabs come in 6a. Ctrl+W is readline's word delete.
    terminal = close_window,
    -- Apps where Ctrl+W doesn't close the window (config.lua).
    ["no-tabs"] = close_window,
  },
})
