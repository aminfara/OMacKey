-- kitty. Shortcuts from kitty's effective keymap, dumped with `kitty +runpy`
-- (docs/FINDINGS.md F10). Everything not listed here falls back to
-- apps/terminal.lua.

local app = require("hypr.omackey.lib.profiles").app
local tap = require("hypr.omackey.lib.send").tap

app({
  name = "kitty",
  family = "terminal",
  classes = { "kitty" },
  actions = {
    -- Text navigation and deletion
    -- ⌘↑ / ⌘↓: scrollback a page; kitty's page-scroll keys carry Ctrl+Shift.
    ["document-start"] = tap("CTRL + SHIFT", "Page_Up"),
    ["document-end"] = tap("CTRL + SHIFT", "Page_Down"),
    -- Editing
    ["find"] = tap("CTRL + SHIFT", "slash"), -- search_scrollback
    -- Windows and tabs
    -- Close the pane (the last pane closes its tab, the last tab the window).
    ["close-tab"] = tap("CTRL + SHIFT", "W"),
    ["new-tab"] = tap("CTRL + SHIFT", "T"),
    -- Font size keys carry Shift.
    ["zoom-in"] = tap("CTRL + SHIFT", "equal"),
    ["zoom-in-plus"] = tap("CTRL + SHIFT", "equal"),
    ["zoom-out"] = tap("CTRL + SHIFT", "minus"),
    ["zoom-reset"] = tap("CTRL + SHIFT", "BackSpace"),
    -- No key for tab N (Ctrl+Shift+1… are pane numbers), so ⌘1–⌘9 stay
    -- consumed.
    ["previous-tab"] = tap("CTRL + SHIFT", "Left"),
    ["next-tab"] = tap("CTRL + SHIFT", "Right"),
    ["previous-tab-arrow"] = tap("CTRL + SHIFT", "Left"),
    ["next-tab-arrow"] = tap("CTRL + SHIFT", "Right"),
    ["preferences"] = tap("CTRL + SHIFT", "F2"), -- edit the config file
  },
})
