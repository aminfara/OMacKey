-- Phase 6e: Obsidian keys with no generic counterpart (PLAN.md §5). Obsidian's
-- own hotkeys use "Mod" (Ctrl on Linux), so ⌘ → Ctrl covers almost everything.
-- The entries for the few that differ (⌘⌥ arrows, fold, replace) sit in
-- windows.lua and vscode.lua next to the generic ones. Chords read from the
-- installed app.js (§9 F16).

local mac = require("hypr.omackey.lib.bind").mac
local tap = require("hypr.omackey.lib.send").tap

-- Redo selection (CodeMirror): Cmd+Shift+U on the Mac, Alt+U on Linux. Elsewhere
-- the catch-all consumes ⌘⇧U (Unicode input in GTK and fcitx5).
mac({
  id = "redo-selection",
  category = "Obsidian",
  mac = "⌘⇧U",
  keys = "SUPER + SHIFT + U",
  desc = "Redo selection (Obsidian)",
  actions = {
    obsidian = tap("ALT", "U"),
  },
})
