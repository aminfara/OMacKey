-- Firefox: where it differs from the Chromium family (apps/browser.lua).
-- Shortcuts from Firefox's DevTools shortcut docs (docs/FINDINGS.md F11).
-- Keys not listed here use the browser family's entries, then the generic
-- ones.

local app = require("hypr.omackey.lib.profiles").app
local does = require("hypr.omackey.lib.action").does
local tap = require("hypr.omackey.lib.send").tap

app({
  name = "firefox",
  family = "browser",
  tags = { "firefox-based-browser" },
  actions = {
    -- Windows and tabs
    ["new-window-private"] = tap("CTRL + SHIFT", "P"), -- private window
    -- Firefox opens its settings when run with this URL (the Chromium family
    -- turns such URLs into a blank tab, F11).
    ["preferences"] = does("Open about:preferences in Firefox", function()
      hl.dispatch(hl.dsp.exec_cmd("firefox about:preferences"))
    end),
    -- Browser
    -- ⇧⌘J as in Chrome (user's choice); Firefox's downloads window.
    ["downloads"] = tap("CTRL + SHIFT", "Y"),
  },
})
