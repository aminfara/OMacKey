-- Phase 6d: Nautilus keys with no generic counterpart (PLAN.md §5). The entries
-- for keys that exist everywhere (⌘↑, ⌘↓, ⌘⌫, ⌘⇧G, ⌘1–⌘4) sit in text.lua,
-- editing.lua and windows.lua next to the generic ones.

local mac = require("hypr.omackey.lib.bind").mac
local tap = require("hypr.omackey.lib.send").tap

-- Show hidden files: ⌘⇧. in Finder, Ctrl+H in Nautilus. Elsewhere the catch-all
-- sends Ctrl+Shift+. (it has no action of its own outside Nautilus).
mac({
  id = "show-hidden-files",
  category = "Files",
  mac = "⌘⇧.",
  keys = "SUPER + SHIFT + period",
  desc = "Show hidden files (Files)",
  actions = {
    nautilus = tap("CTRL", "H"),
  },
})
