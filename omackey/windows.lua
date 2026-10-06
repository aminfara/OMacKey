-- Window and tab controls (PLAN.md §5).

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
    -- Apps where Ctrl+W doesn't close the window (config.lua).
    ["no-tabs"] = windows.close,
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

-- Terminals have no ⌘ chord to receive, so these send their own: foot,
-- Ghostty, kitty and Alacritty open a new window on Ctrl+Shift+N.
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

-- Private window in browsers, new folder in file managers. Firefox's private
-- window is Ctrl+Shift+P.
mac({
  id = "new-window-private",
  category = "Windows",
  mac = "⌘⇧N",
  keys = "SUPER + SHIFT + N",
  desc = "New private window or folder",
  actions = {
    default = tap("CTRL + SHIFT", "N"),
    firefox = tap("CTRL + SHIFT", "P"),
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
-- Ctrl+O/P/R/L are readline keys in a terminal (history, reverse search,
-- clear screen) and terminals have no matching feature, so they swallow ⌘.
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

-- Zoom. Omarchy's resize binds for these keys are on ⌃⌥. foot and
-- Ghostty take the same chords (font size), so they have no entry; kitty's
-- font-size keys carry Shift (§9 F10). ⌘+ is ⌘⇧= and zooms in like ⌘=.
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
    vscode = tap("CTRL", "kp_0"), -- VS Code's reset zoom is Ctrl+Numpad0, not Ctrl+0
  },
})

-- Back and forward in browsers and Nautilus; outdent and indent in editors
-- (VS Code and Obsidian use Ctrl+[ / Ctrl+]). Terminals have no equivalent and
-- Ctrl+[ is Escape there. Omarchy's webcam binds are on ⌃⌥.
mac({
  id = "back",
  category = "Windows",
  mac = "⌘[",
  keys = "SUPER + bracketleft",
  desc = "Back or outdent",
  actions = {
    default = tap("CTRL", "bracketleft"),
    browser = tap("ALT", "Left"),
    nautilus = tap("ALT", "Left"),
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
    browser = tap("ALT", "Right"),
    nautilus = tap("ALT", "Right"),
  },
})

-- ⌘1–⌘9: tab N (⌘9 is the last tab in browsers, as on a Mac). Omarchy's
-- workspace binds are on ⌃1–0. One bind per digit, written as a loop like
-- spaces.lua; each gets its own actions table, so apps can have entries. Terminals consume, except Ghostty (Alt+N; Alt+9 is the last
-- tab). kitty has no key for tab N. Nautilus has no tabs by number here: ⌘1 / ⌘2
-- are Finder's icon / list view, which are Nautilus's Ctrl+2 / Ctrl+1 (§9 F5),
-- and ⌘3–9 do nothing (Finder's columns and gallery views don't exist).
local nautilus_views = { ["1"] = tap("CTRL", "2"), ["2"] = tap("CTRL", "1") }

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
      nautilus = nautilus_views[digit] or CONSUME,
    },
  })
end

-- Previous and next tab on both Mac chords. Browsers, VS Code and Nautilus
-- all take Ctrl+Page_Up/Down, and so does Ghostty. kitty switches tabs with
-- Ctrl+Shift+Left/Right; other terminals consume. In Obsidian ⌘⌥← / ⌘⌥→ are
-- back/forward. Omarchy's group moves (⌘⌥←/→) are on ⌃⌥⌘.
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
    obsidian = tap("CTRL + ALT", "Left"), -- navigate back, as on the Mac
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
    obsidian = tap("CTRL + ALT", "Right"), -- navigate forward
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

-- Preferences. Omarchy's "dismiss last notification" is on ⌃⌘⇧,.
-- VS Code, Obsidian and Nautilus open their settings on Ctrl+, ; LibreOffice
-- has no such shortcut. Browsers have none either. Firefox opens
-- about:preferences when run with that URL; the Chromium family turns a
-- chrome:// URL given on the command line into a blank tab, so there ⌘, sends the
-- generic Ctrl+, (some web apps use it) and settings stay unmapped (§7). In terminals the preferences are
-- the config file: kitty opens it on Ctrl+Shift+F2. Ghostty's own Ctrl+, runs
-- xdg-open, which starts nvim without a terminal and shows nothing (§9 F10), so
-- Ghostty gets Omarchy's editor launcher instead. Other terminals consume it.
mac({
  id = "preferences",
  category = "Windows",
  mac = "⌘,",
  keys = "SUPER + comma",
  desc = "Preferences",
  actions = {
    default = tap("CTRL", "comma"),
    firefox = function()
      hl.dispatch(hl.dsp.exec_cmd("firefox about:preferences"))
    end,
    libreoffice = tap("ALT", "F12"), -- Tools > Options
  },
})
