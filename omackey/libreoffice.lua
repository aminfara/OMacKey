-- Phase 6f: LibreOffice keys with no generic counterpart (PLAN.md §5). The entries
-- for keys that exist everywhere (⌘G, ⌘⇧G, ⌘⇧V, ⌘,) sit in editing.lua and
-- windows.lua next to the generic ones. Chords read from the installed
-- registry (§9 F17).

local mac = require("hypr.omackey.lib.bind").mac
local tap = require("hypr.omackey.lib.send").tap

-- Paste Special. ⌘⇧V pastes unformatted text everywhere (Ctrl+Alt+Shift+V in
-- LibreOffice), so this is the way to the dialog. Elsewhere ⌘⌥V reaches the app
-- as before.
mac({
  id = "paste-special",
  category = "LibreOffice",
  mac = "⌘⌥V",
  keys = "SUPER + ALT + V",
  desc = "Paste special (LibreOffice)",
  actions = {
    libreoffice = tap("CTRL + SHIFT", "V"),
  },
})
