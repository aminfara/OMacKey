-- Window and tab controls, navigation, browser and terminal keys (PLAN.md §5).
-- Each spec says what the key does in a generic app; apps/*.lua add per-app
-- entries.

local bind = require("hypr.omackey.lib.bind")
local tap = require("hypr.omackey.lib.send").tap
local switcher = require("hypr.omackey.lib.switcher")
local windows = require("hypr.omackey.lib.windows")
local mac, CONSUME = bind.mac, bind.CONSUME

switcher.start()

-- Omarchy's "Close window" is on ⌃⌥W (relocations.lua).
mac({
  id = "close-tab",
  category = "Windows",
  mac = "⌘W",
  keys = "SUPER + W",
  desc = "Close tab or window",
  actions = {
    default = tap("CTRL", "W"),
  },
})

-- The compositor's close request is what an app's own "close window" shortcut
-- ends in, so one action covers every app (Ctrl+Shift+W for
-- browsers and VS Code would do the same). Omarchy's Omawrite launcher is on
-- ⌃⌥⌘W.
mac({
  id = "close-window",
  category = "Windows",
  mac = "⌘⇧W",
  keys = "SUPER + SHIFT + W",
  desc = "Close window",
  action = hl.dsp.window.close(),
})

mac({
  id = "quit-app",
  category = "Windows",
  mac = "⌘Q",
  keys = "SUPER + Q",
  desc = "Quit app (close all its windows)",
  action = windows.quit_app, -- terminals too, as Terminal.app does
})

mac({
  id = "new-window",
  category = "Windows",
  mac = "⌘N",
  keys = "SUPER + N",
  desc = "New window",
  actions = {
    default = tap("CTRL", "N"),
  },
})

-- Private window in browsers, new folder in file managers.
mac({
  id = "new-window-private",
  category = "Windows",
  mac = "⌘⇧N",
  keys = "SUPER + SHIFT + N",
  desc = "New private window or folder",
  actions = {
    default = tap("CTRL + SHIFT", "N"),
  },
})

mac({
  id = "new-tab",
  category = "Windows",
  mac = "⌘T",
  keys = "SUPER + T",
  desc = "New tab",
  actions = {
    default = tap("CTRL", "T"),
  },
})

mac({
  id = "reopen-tab",
  category = "Windows",
  mac = "⌘⇧T",
  keys = "SUPER + SHIFT + T",
  desc = "Reopen closed tab",
  actions = {
    default = tap("CTRL + SHIFT", "T"),
  },
})

-- ⌘O/⌘P/⌘R/⌘L: Omarchy's pop, pseudo and layout binds are on ⌃⌥.
mac({
  id = "open",
  category = "Windows",
  mac = "⌘O",
  keys = "SUPER + O",
  desc = "Open",
  actions = {
    default = tap("CTRL", "O"),
  },
})

mac({
  id = "print",
  category = "Windows",
  mac = "⌘P",
  keys = "SUPER + P",
  desc = "Print or quick open",
  actions = {
    default = tap("CTRL", "P"),
  },
})

mac({
  id = "reload",
  category = "Windows",
  mac = "⌘R",
  keys = "SUPER + R",
  desc = "Reload",
  actions = {
    default = tap("CTRL", "R"),
  },
})

mac({
  id = "location",
  category = "Windows",
  mac = "⌘L",
  keys = "SUPER + L",
  desc = "Focus address bar",
  actions = {
    default = tap("CTRL", "L"),
  },
})

-- Zoom. Omarchy's resize binds for these keys are on ⌃⌥. foot and Ghostty take
-- the same chords for font size. ⌘+ is ⌘⇧= and zooms in like ⌘=.
mac({
  id = "zoom-in",
  category = "Windows",
  mac = "⌘=",
  keys = "SUPER + equal",
  desc = "Zoom in (app)",
  actions = {
    default = tap("CTRL", "equal"),
  },
})

mac({
  id = "zoom-in-plus",
  category = "Windows",
  mac = "⌘+",
  keys = "SUPER + SHIFT + equal",
  desc = "Zoom in (app)",
  actions = {
    default = tap("CTRL", "equal"),
  },
})

mac({
  id = "zoom-out",
  category = "Windows",
  mac = "⌘-",
  keys = "SUPER + minus",
  desc = "Zoom out (app)",
  actions = {
    default = tap("CTRL", "minus"),
  },
})

mac({
  id = "zoom-reset",
  category = "Windows",
  mac = "⌘0",
  keys = "SUPER + 0",
  desc = "Actual size (app zoom)",
  actions = {
    default = tap("CTRL", "0"),
  },
})

-- Outdent and indent in editors (VS Code and Obsidian use Ctrl+[ / Ctrl+]);
-- back and forward in browsers and Nautilus. Omarchy's webcam binds are on ⌃⌥.
mac({
  id = "back",
  category = "Windows",
  mac = "⌘[",
  keys = "SUPER + bracketleft",
  desc = "Back or outdent",
  actions = {
    default = tap("CTRL", "bracketleft"),
  },
})

mac({
  id = "forward",
  category = "Windows",
  mac = "⌘]",
  keys = "SUPER + bracketright",
  desc = "Forward or indent",
  actions = {
    default = tap("CTRL", "bracketright"),
  },
})

-- ⌘1–⌘9: tab N (⌘9 is the last tab in browsers, as on a Mac). Omarchy's
-- workspace binds are on ⌃1–0. One bind per digit, each with its own actions
-- table, so apps can have entries (ids tab-1 … tab-9).

for n = 1, 9 do
  local digit = tostring(n)

  mac({
    id = "tab-" .. digit,
    category = "Windows",
    mac = "⌘" .. digit,
    keys = "SUPER + " .. digit,
    desc = "Go to tab " .. digit,
    actions = {
      default = tap("CTRL", digit),
    },
  })
end

-- Previous and next tab on both Mac chords: Ctrl+Page_Up/Down, which browsers,
-- VS Code and Nautilus take. Omarchy's group moves (⌘⌥←/→) are on ⌃⌥⌘.
mac({
  id = "previous-tab",
  category = "Windows",
  mac = "⌘⇧[",
  keys = "SUPER + SHIFT + bracketleft",
  desc = "Previous tab",
  actions = {
    default = tap("CTRL", "Page_Up"),
  },
})

mac({
  id = "next-tab",
  category = "Windows",
  mac = "⌘⇧]",
  keys = "SUPER + SHIFT + bracketright",
  desc = "Next tab",
  actions = {
    default = tap("CTRL", "Page_Down"),
  },
})

mac({
  id = "previous-tab-arrow",
  category = "Windows",
  mac = "⌘⌥←",
  keys = "SUPER + ALT + LEFT",
  desc = "Previous tab",
  actions = {
    default = tap("CTRL", "Page_Up"),
  },
})

mac({
  id = "next-tab-arrow",
  category = "Windows",
  mac = "⌘⌥→",
  keys = "SUPER + ALT + RIGHT",
  desc = "Next tab",
  actions = {
    default = tap("CTRL", "Page_Down"),
  },
})

-- ⌘Tab flips between the last two apps and, with ⌘ held, steps further along
-- the recency list (lib/switcher.lua). Omarchy's workspace switching on these
-- keys is on ⌃⌥← / ⌃⌥→; ⌥Tab still cycles windows in layout order.
mac({
  id = "switch-app",
  category = "Windows",
  mac = "⌘Tab",
  keys = "SUPER + TAB",
  desc = "Switch app",
  action = function()
    switcher.step(true)
  end,
})

mac({
  id = "switch-app-back",
  category = "Windows",
  mac = "⌘⇧Tab",
  keys = "SUPER + SHIFT + TAB",
  desc = "Switch app backwards",
  action = function()
    switcher.step(false)
  end,
})

-- Fixed-order ring of the active app's windows, across workspaces. With one
-- window nothing happens.
mac({
  id = "next-app-window",
  category = "Windows",
  mac = "⌘`",
  keys = "SUPER + grave",
  desc = "Next window of this app",
  action = function()
    windows.cycle_app_windows(1)
  end,
})

mac({
  id = "previous-app-window",
  category = "Windows",
  mac = "⌘⇧`",
  keys = "SUPER + SHIFT + grave",
  desc = "Previous window of this app",
  action = function()
    windows.cycle_app_windows(-1)
  end,
})

-- Preferences. Omarchy's "dismiss last notification" is on ⌃⌘⇧,. VS Code,
-- Obsidian and Nautilus open their settings on Ctrl+, . The Chromium family has
-- no settings key and turns a chrome:// URL given on the command line into a
-- blank tab, so there ⌘, sends the generic Ctrl+, (some web apps use it) and
-- settings stay unmapped (§7).
mac({
  id = "preferences",
  category = "Windows",
  mac = "⌘,",
  keys = "SUPER + comma",
  desc = "Preferences",
  actions = {
    default = tap("CTRL", "comma"),
  },
})

-- Browser keys. Mac Chrome and Firefox put these on ⌘⌥ or ⌘⇧ + a letter; the
-- Linux builds use Ctrl+Shift or Ctrl with other letters (apps/browser.lua).

-- DevTools. Obsidian toggles its on Ctrl+Shift+I too, so every GUI app gets it.
mac({
  id = "devtools",
  category = "Browser",
  mac = "⌘⌥I",
  keys = "SUPER + ALT + I",
  desc = "Developer tools",
  actions = {
    default = tap("CTRL + SHIFT", "I"),
  },
})

-- Chrome's JavaScript console; Firefox's Browser Console, same key on Linux.
mac({
  id = "devtools-console",
  category = "Browser",
  mac = "⌘⌥J",
  keys = "SUPER + ALT + J",
  desc = "Developer console",
})

mac({
  id = "devtools-inspect",
  category = "Browser",
  mac = "⌘⌥C",
  keys = "SUPER + ALT + C",
  desc = "Inspect element",
})

mac({
  id = "view-source",
  category = "Browser",
  mac = "⌘⌥U",
  keys = "SUPER + ALT + U",
  desc = "View page source",
})

mac({
  id = "history",
  category = "Browser",
  mac = "⌘Y",
  keys = "SUPER + Y",
  desc = "History",
  actions = {
    default = tap("CTRL", "Y"),
  },
})

-- Chrome's downloads page; Firefox follows the same key (user's choice).
mac({
  id = "downloads",
  category = "Browser",
  mac = "⌘⇧J",
  keys = "SUPER + SHIFT + J",
  desc = "Downloads",
  actions = {
    default = tap("CTRL + SHIFT", "J"),
  },
})

-- Omarchy's "Toggle window gaps" is on ⌃⌥⇧⌫.
mac({
  id = "clear-browsing-data",
  category = "Browser",
  mac = "⌘⇧⌫",
  keys = "SUPER + SHIFT + BACKSPACE",
  desc = "Clear browsing data",
})

mac({
  id = "bookmark-manager",
  category = "Browser",
  mac = "⌘⌥B",
  keys = "SUPER + ALT + B",
  desc = "Bookmark manager",
})

-- Show hidden files (⌘⇧. in Finder). Elsewhere it sends Ctrl+Shift+., like the
-- catch-all.
mac({
  id = "show-hidden-files",
  category = "Files",
  mac = "⌘⇧.",
  keys = "SUPER + SHIFT + period",
  desc = "Show hidden files (Files)",
  actions = {
    default = tap("CTRL + SHIFT", "period"),
  },
})

-- Terminal keys. Outside terminals they send Ctrl / Ctrl+Shift + the same key,
-- like the catch-all.

-- Clear screen. Ghostty on the Mac clears the screen and all scrollback; Ctrl+L
-- only clears the visible screen, so the scrollback stays (§7).
mac({
  id = "clear-screen",
  category = "Terminal",
  mac = "⌘K",
  keys = "SUPER + K",
  desc = "Clear terminal screen",
  actions = {
    default = tap("CTRL", "K"),
  },
})

-- Split panes exist only in Ghostty here (kitty's layouts are not a split
-- command, foot has none).
mac({
  id = "split-right",
  category = "Terminal",
  mac = "⌘D",
  keys = "SUPER + D",
  desc = "Split terminal right",
  actions = {
    default = tap("CTRL", "D"),
  },
})

mac({
  id = "split-down",
  category = "Terminal",
  mac = "⌘⇧D",
  keys = "SUPER + SHIFT + D",
  desc = "Split terminal down",
  actions = {
    default = tap("CTRL + SHIFT", "D"),
  },
})
