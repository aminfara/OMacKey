-- Browser shortcuts (PLAN.md §5). Mac Chrome and Firefox put these on
-- ⌘⌥ or ⌘⇧ + a letter; the Linux builds use Ctrl+Shift or Ctrl with other
-- letters. The per-browser entries for keys that exist everywhere (⌘⇧N, ⌘,
-- ⌘[ ⌘]) sit in windows.lua.
--
-- A key here without a `default` does nothing outside browsers: the raw chord
-- reaches the app. ⌘Y and ⌘⇧J send Ctrl+Y / Ctrl+Shift+J elsewhere, like the
-- catch-all.

local bind = require("hypr.omackey.lib.bind")
local mac, CONSUME = bind.mac, bind.CONSUME
local tap = require("hypr.omackey.lib.send").tap

-- DevTools. Obsidian toggles its on Ctrl+Shift+I too, so every GUI app gets it;
-- terminals have nothing to open. VS Code does not: there Ctrl+Shift+I is Format
-- Document whenever the editor has focus, so the key would reformat the file.
mac({
  id = "devtools",
  category = "Browser",
  mac = "⌘⌥I",
  keys = "SUPER + ALT + I",
  desc = "Developer tools",
  actions = {
    default = tap("CTRL + SHIFT", "I"),
    vscode = CONSUME,
  },
})

-- Chrome's JavaScript console; Firefox's Browser Console, same key on Linux.
mac({
  id = "devtools-console",
  category = "Browser",
  mac = "⌘⌥J",
  keys = "SUPER + ALT + J",
  desc = "Developer console",
  actions = {
    browser = tap("CTRL + SHIFT", "J"),
  },
})

mac({
  id = "devtools-inspect",
  category = "Browser",
  mac = "⌘⌥C",
  keys = "SUPER + ALT + C",
  desc = "Inspect element",
  actions = {
    browser = tap("CTRL + SHIFT", "C"),
    vscode = tap("ALT", "C"), -- find widget: match case (see vscode.lua)
  },
})

mac({
  id = "view-source",
  category = "Browser",
  mac = "⌘⌥U",
  keys = "SUPER + ALT + U",
  desc = "View page source",
  actions = {
    browser = tap("CTRL", "U"),
  },
})

mac({
  id = "history",
  category = "Browser",
  mac = "⌘Y",
  keys = "SUPER + Y",
  desc = "History",
  actions = {
    default = tap("CTRL", "Y"),
    browser = tap("CTRL", "H"),
  },
})

-- Chrome's downloads page. Firefox follows the same key (user's choice): its
-- downloads window is Ctrl+Shift+Y on Linux.
mac({
  id = "downloads",
  category = "Browser",
  mac = "⌘⇧J",
  keys = "SUPER + SHIFT + J",
  desc = "Downloads",
  actions = {
    default = tap("CTRL + SHIFT", "J"),
    browser = tap("CTRL", "J"),
    firefox = tap("CTRL + SHIFT", "Y"),
  },
})

-- Omarchy's "Toggle window gaps" is on ⌃⌥⇧⌫.
mac({
  id = "clear-browsing-data",
  category = "Browser",
  mac = "⌘⇧⌫",
  keys = "SUPER + SHIFT + BACKSPACE",
  desc = "Clear browsing data",
  actions = {
    browser = tap("CTRL + SHIFT", "Delete"),
  },
})

mac({
  id = "bookmark-manager",
  category = "Browser",
  mac = "⌘⌥B",
  keys = "SUPER + ALT + B",
  desc = "Bookmark manager",
  actions = {
    browser = tap("CTRL + SHIFT", "O"),
    vscode = tap("CTRL + ALT", "B"), -- toggle the secondary side bar
  },
})
