-- kitty. Shortcuts from kitty's effective keymap, dumped with `kitty +runpy`
-- (PLAN.md §9 F10).

local app = require("hypr.omackey.lib.profiles").app

app({
  name = "kitty",
  family = "terminal",
  classes = { "kitty" },
  actions = {},
})
