-- Nautilus keys with no generic counterpart (PLAN.md §5). The entries
-- for keys that exist everywhere (⌘↑, ⌘↓, ⌘⌫, ⌘⇧G, ⌘1–⌘4) sit in text.lua,
-- editing.lua and windows.lua next to the generic ones.

local bind = require("hypr.omackey.lib.bind")
local mac, CONSUME = bind.mac, bind.CONSUME
local tap = require("hypr.omackey.lib.send").tap

-- Show hidden files: ⌘⇧. in Finder, Ctrl+H in Nautilus. Elsewhere it sends
-- Ctrl+Shift+., like the catch-all.
mac({
  id = "show-hidden-files",
  category = "Files",
  mac = "⌘⇧.",
  keys = "SUPER + SHIFT + period",
  desc = "Show hidden files (Files)",
  actions = {
    default = tap("CTRL + SHIFT", "period"),
    nautilus = tap("CTRL", "H"),
  },
})
