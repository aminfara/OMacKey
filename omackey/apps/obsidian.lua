-- Obsidian (class md.obsidian.Obsidian here). Hotkeys read from the installed
-- app.js; "Mod" is Ctrl on Linux, so most Mac keys work as ⌘ → Ctrl (PLAN.md
-- §9 F16).

local app = require("hypr.omackey.lib.profiles").app

app({
  name = "obsidian",
  classes = { "md.obsidian.Obsidian", "obsidian" },
  actions = {},
})
