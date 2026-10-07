-- Browsers: the Chromium family, and Firefox where it agrees. Shortcuts from
-- Chrome's keyboard-shortcut page, Mac and Linux columns (docs/FINDINGS.md
-- F11).

local app = require("hypr.omackey.lib.profiles").app
local tap = require("hypr.omackey.lib.send").tap

app({
  name = "browser",
  tags = { "chromium-based-browser", "firefox-based-browser" },
  -- Omarchy's browser tag regex does not cover Brave Origin.
  classes = { "brave-origin" },
  actions = {
    -- Windows and tabs
    ["back"] = tap("ALT", "Left"),
    ["forward"] = tap("ALT", "Right"),
    -- Browser
    ["devtools-console"] = tap("CTRL + SHIFT", "J"),
    ["devtools-inspect"] = tap("CTRL + SHIFT", "C"),
    ["view-source"] = tap("CTRL", "U"),
    ["history"] = tap("CTRL", "H"),
    ["downloads"] = tap("CTRL", "J"),
    ["clear-browsing-data"] = tap("CTRL + SHIFT", "Delete"),
    ["bookmark-manager"] = tap("CTRL + SHIFT", "O"),
  },
})
