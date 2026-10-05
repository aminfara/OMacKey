-- Phase 7g: ⌘ + scroll reaches apps as Ctrl + scroll (browser zoom), PLAN.md §5.
-- Omarchy's own ⌘ + scroll binds moved to ⌃⌥ (relocations.lua). The work is in
-- lib/ctrl_hold.lua; it needs `wtype`, so nothing is bound without it.
--
-- ⌘-click is not translated: apps that act on it already do, and Hyprland can't
-- press a button for us (§9 F19).

local function installed(program)
  for dir in (os.getenv("PATH") or ""):gmatch("[^:]+") do
    local handle = io.open(dir .. "/" .. program, "r")
    if handle then
      handle:close()
      return true
    end
  end
  return false
end

if not installed("wtype") then
  return
end

local mac = require("hypr.omackey.lib.bind").mac
local ctrl_hold = require("hypr.omackey.lib.ctrl_hold")

mac({
  id = "scroll-up",
  category = "Mouse",
  mac = "⌘-scroll up",
  keys = "SUPER + mouse_up",
  desc = "⌘-scroll up sent as Ctrl-scroll",
  actions = { default = ctrl_hold.tick },
})

mac({
  id = "scroll-down",
  category = "Mouse",
  mac = "⌘-scroll down",
  keys = "SUPER + mouse_down",
  desc = "⌘-scroll down sent as Ctrl-scroll",
  actions = { default = ctrl_hold.tick },
})
