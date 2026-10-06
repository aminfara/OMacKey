-- Nautilus (Files): keys that differ from Finder's (PLAN.md §9 F5).

local app = require("hypr.omackey.lib.profiles").app

app({
  name = "nautilus",
  classes = { "org.gnome.Nautilus" },
  actions = {},
})
