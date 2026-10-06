-- foot. Shortcuts from foot.ini(5) (PLAN.md §9 F10).

local app = require("hypr.omackey.lib.profiles").app

app({
  name = "foot",
  family = "terminal",
  classes = { "foot", "org.codeberg.dnkl.foot" },
  actions = {},
})
