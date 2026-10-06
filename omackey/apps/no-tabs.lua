-- GUI apps where Ctrl+W doesn't close the window: ⌘W closes it instead.
-- Add a window class here (hyprctl clients) when ⌘W does nothing.

local app = require("hypr.omackey.lib.profiles").app
local windows = require("hypr.omackey.lib.windows")

app({
  name = "no-tabs",
  classes = {},
  actions = {
    ["close-tab"] = windows.close,
  },
})
