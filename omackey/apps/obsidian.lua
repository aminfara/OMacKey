-- Obsidian (class md.obsidian.Obsidian here). Its hotkeys use "Mod" (Ctrl on
-- Linux, ⌘ on the Mac), so most Mac keys work through the generic entries.
-- These are the few that differ. Read from the installed app.js (PLAN.md §9
-- F16).

local app = require("hypr.omackey.lib.profiles").app
local tap = require("hypr.omackey.lib.send").tap

app({
  name = "obsidian",
  classes = { "md.obsidian.Obsidian", "obsidian" },
  actions = {
    -- Windows and tabs
    -- ⌘⌥← / ⌘⌥→ navigate back / forward, as on the Mac (Mod+Alt+Left/Right on
    -- both platforms; within one tab's history).
    ["previous-tab-arrow"] = tap("CTRL + ALT", "Left"),
    ["next-tab-arrow"] = tap("CTRL + ALT", "Right"),
    -- Code editing
    -- Mod+Alt+Up / Down add a cursor: the same chord on both platforms.
    ["add-cursor-above"] = tap("CTRL + ALT", "Up"),
    ["add-cursor-below"] = tap("CTRL + ALT", "Down"),
    ["replace"] = tap("CTRL", "H"),
    -- Redo selection (CodeMirror): Cmd+Shift+U on the Mac, Alt+U on Linux.
    ["redo-selection"] = tap("ALT", "U"),
  },
})
