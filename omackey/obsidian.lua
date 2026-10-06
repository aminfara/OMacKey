-- Obsidian keys with no generic counterpart (PLAN.md §5). Obsidian's
-- own hotkeys use "Mod" (Ctrl on Linux), so ⌘ → Ctrl covers almost everything.
-- The entries for the few that differ (⌘⌥ arrows, fold, replace) sit in
-- windows.lua and vscode.lua next to the generic ones. Chords read from the
-- installed app.js (§9 F16).

local bind = require("hypr.omackey.lib.bind")
local mac, CONSUME = bind.mac, bind.CONSUME
local tap = require("hypr.omackey.lib.send").tap

-- Redo selection (CodeMirror): Cmd+Shift+U on the Mac, Alt+U on Linux. Elsewhere
-- ⌘⇧U is consumed, as in the catch-all (Ctrl+Shift+U starts Unicode input in GTK
-- and fcitx5).
mac({
  id = "redo-selection",
  category = "Obsidian",
  mac = "⌘⇧U",
  keys = "SUPER + SHIFT + U",
  desc = "Redo selection (Obsidian)",
  actions = {
    default = CONSUME,
    obsidian = tap("ALT", "U"),
  },
})
