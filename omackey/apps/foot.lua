-- foot. Shortcuts from foot.ini(5) (docs/FINDINGS.md F10). foot has no tabs or
-- splits; everything not listed here falls back to apps/terminal.lua.

local app = require("hypr.omackey.lib.profiles").app
local tap = require("hypr.omackey.lib.send").tap

app({
  name = "foot",
  family = "terminal",
  classes = { "foot", "org.codeberg.dnkl.foot" },
  actions = {
    -- Editing
    ["find"] = tap("CTRL + SHIFT", "R"), -- search; inside it Ctrl+R / Ctrl+S step between matches
  },
})
