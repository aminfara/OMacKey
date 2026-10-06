-- Browsers: the Chromium family, and Firefox where it agrees. Shortcuts from
-- Chrome's keyboard-shortcut page, Mac and Linux columns (PLAN.md §9 F11).

local app = require("hypr.omackey.lib.profiles").app

app({
  name = "browser",
  tags = { "chromium-based-browser", "firefox-based-browser" },
  -- Omarchy's browser tag regex does not cover Brave Origin.
  classes = { "brave-origin" },
  actions = {},
})
