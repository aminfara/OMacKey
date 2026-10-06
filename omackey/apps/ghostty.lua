-- Ghostty. Shortcuts from `ghostty +list-keybinds --default` (Linux) and the
-- macOS defaults in Ghostty's src/config/Config.zig (PLAN.md §9 F10).

local app = require("hypr.omackey.lib.profiles").app

app({
  name = "ghostty",
  family = "terminal",
  classes = { "com.mitchellh.ghostty" },
  actions = {},
})
