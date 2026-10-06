-- GUI apps where Ctrl+W doesn't close the window: ⌘W closes it instead.
-- Add a window class here (hyprctl clients) when ⌘W does nothing.

local app = require("hypr.omackey.lib.profiles").app

app({
  name = "no-tabs",
  classes = {},
  actions = {},
})
