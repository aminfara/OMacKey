-- GUI apps where Ctrl+W doesn't close the window: ⌘W closes it instead. The
-- classes come from the `close_window_classes` setting (settings.lua).

local app = require("hypr.omackey.lib.profiles").app
local settings = require("hypr.omackey.settings")
local windows = require("hypr.omackey.lib.windows")

app({
  name = "no-tabs",
  classes = settings.close_window_classes,
  actions = {
    ["close-tab"] = windows.close,
  },
})
