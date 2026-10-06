-- Firefox: where it differs from the Chromium family (apps/browser.lua).
-- Shortcuts from Firefox's DevTools shortcut docs (PLAN.md §9 F11).

local app = require("hypr.omackey.lib.profiles").app

app({
  name = "firefox",
  family = "browser",
  tags = { "firefox-based-browser" },
  actions = {},
})
