-- Phase 4: window and tab controls (PLAN.md §5).

local bind = require("hypr.omackey.lib.bind")
local tap = require("hypr.omackey.lib.send").tap
local mac, action = bind.mac, bind.action

local function close_window()
  hl.dispatch(hl.dsp.window.close())
end

-- Quit like macOS: close every window of the active window's app (the same
-- window class). Apps with unsaved work still ask before closing.
local function quit_app()
  local active = hl.get_active_window()
  if not active then
    return
  end

  local class = active.class
  if class == "" then
    close_window() -- nothing to match on: just this window
    return
  end

  for _, window in ipairs(hl.get_windows({ mapped = true })) do
    if window.class == class then
      hl.dispatch(hl.dsp.window.close({ window = window }))
    end
  end
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

-- The compositor's close request is what an app's own "close window" shortcut
-- ends in, so one action covers every app (the plan's Ctrl+Shift+W for
-- browsers and VS Code would do the same). Omarchy's Omawrite launcher moved
-- off SUPER+SHIFT+W in Phase 1c.
action({
  id = "close-window",
  category = "Windows",
  mac = "⌘⇧W",
  keys = "SUPER + SHIFT + W",
  desc = "Close window",
  dispatcher = hl.dsp.window.close(),
})

mac({
  id = "quit-app",
  category = "Windows",
  mac = "⌘Q",
  keys = "SUPER + Q",
  desc = "Quit app (close all its windows)",
  actions = {
    default = quit_app, -- terminals too, as Terminal.app does
  },
})
