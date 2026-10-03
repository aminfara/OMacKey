-- Phase 6a: keys that only mean something in a terminal (PLAN.md §5). The
-- per-terminal entries for keys that exist everywhere (⌘W, ⌘T, ⌘F…) sit in
-- windows.lua, editing.lua and text.lua next to the generic ones.
--
-- Outside terminals these have no action, so the raw ⌘ chord reaches the app as
-- it did before; Phase 7a decides what the catch-all sends there.

local mac = require("hypr.omackey.lib.bind").mac
local tap = require("hypr.omackey.lib.send").tap

-- Clear screen. Ghostty on the Mac clears the screen and all scrollback; Ctrl+L
-- only clears the visible screen, so the scrollback stays (§7).
mac({
  id = "clear-screen",
  category = "Terminal",
  mac = "⌘K",
  keys = "SUPER + K",
  desc = "Clear terminal screen",
  actions = {
    terminal = tap("CTRL", "L"),
  },
})

-- Split panes exist only in Ghostty here (kitty's layouts are not a split
-- command, foot has none): Ctrl+Shift+O splits to the right, Ctrl+Shift+E down.
mac({
  id = "split-right",
  category = "Terminal",
  mac = "⌘D",
  keys = "SUPER + D",
  desc = "Split terminal right",
  actions = {
    terminal = "consume",
    ghostty = tap("CTRL + SHIFT", "O"),
  },
})

mac({
  id = "split-down",
  category = "Terminal",
  mac = "⌘⇧D",
  keys = "SUPER + SHIFT + D",
  desc = "Split terminal down",
  actions = {
    terminal = "consume",
    ghostty = tap("CTRL + SHIFT", "E"),
  },
})
