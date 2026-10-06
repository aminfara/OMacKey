-- Terminals: every window with Omarchy's `terminal` tag. Ghostty, kitty and
-- foot add their own entries on top (apps/ghostty.lua …); this covers the rest
-- (Alacritty, wezterm, Omarchy's TUI windows) and whatever those leave out.

local app = require("hypr.omackey.lib.profiles").app

app({
  name = "terminal",
  tags = { "terminal" },
  actions = {},
})
