-- Phase 3: core editing (PLAN.md §5).

local mac = require("hypr.omackey.lib.bind").mac
local tap = require("hypr.omackey.lib.send").tap

-- Replaces Omarchy's universal copy, paste and cut. Exact strings from
-- /usr/share/omarchy/default/hypr/bindings/clipboard.lua.
hl.unbind("SUPER + C")
hl.unbind("SUPER + V")
hl.unbind("SUPER + X")

mac({
  id = "copy",
  category = "Editing",
  mac = "⌘C",
  keys = "SUPER + C",
  desc = "Copy",
  actions = {
    default = tap("CTRL", "C"),
    terminal = tap("CTRL", "Insert"), -- Ctrl+C is SIGINT in a terminal
  },
})

mac({
  id = "paste",
  category = "Editing",
  mac = "⌘V",
  keys = "SUPER + V",
  desc = "Paste",
  actions = {
    default = tap("CTRL", "V"),
    terminal = tap("SHIFT", "Insert"), -- Ctrl+V is a literal-next in a terminal
  },
})

mac({
  id = "cut",
  category = "Editing",
  mac = "⌘X",
  keys = "SUPER + X",
  desc = "Cut",
  actions = {
    default = tap("CTRL", "X"),
    terminal = "consume", -- Ctrl+X is a readline prefix; a terminal has nothing to cut
  },
})
