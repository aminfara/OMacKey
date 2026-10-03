-- Phase 4: window and tab controls (PLAN.md §5).

local bind = require("hypr.omackey.lib.bind")
local tap = require("hypr.omackey.lib.send").tap
local switcher = require("hypr.omackey.lib.switcher")
local mac, action = bind.mac, bind.action

switcher.start()

local function close_window()
  hl.dispatch(hl.dsp.window.close())
end

-- Quit like macOS: close every window of the active window's app (the same
-- window class). Apps with unsaved work still ask before closing.
local function quit_app()
  local active = hl.get_active_window()
  if not active then
    return
  end

  local class = active.class
  if class == "" then
    close_window() -- nothing to match on: just this window
    return
  end

  for _, window in ipairs(hl.get_windows({ mapped = true })) do
    if window.class == class then
      hl.dispatch(hl.dsp.window.close({ window = window }))
    end
  end
end

-- ⌘` and ⌘⇧`: step through the windows of the active app (same class, every
-- workspace) in a fixed order, wrapping around. Not recency: with three windows
-- the ring visits all of them, as on a Mac.
local function cycle_app_windows(step)
  local active = hl.get_active_window()
  if not active or active.class == "" then
    return
  end

  local windows = {}
  for _, window in ipairs(hl.get_windows({ mapped = true })) do
    local workspace = window.workspace
    if window.class == active.class and not window.hidden and not (workspace and workspace.special) then
      table.insert(windows, window)
    end
  end
  table.sort(windows, function(a, b)
    return a.stable_id < b.stable_id
  end)

  for index, window in ipairs(windows) do
    if window.address == active.address then
      switcher.focus(windows[(index - 1 + step) % #windows + 1])
      return
    end
  end
end

-- Omarchy's "Close window" moved to ⌃⌥W in Phase 1a, so ⌘W was free.
mac({
  id = "close-tab",
  category = "Windows",
  mac = "⌘W",
  keys = "SUPER + W",
  desc = "Close tab or window",
  actions = {
    default = tap("CTRL", "W"),
    -- foot, Alacritty and Omarchy's TUIs have no tabs, so close the window.
    -- Ghostty and kitty tabs come in 6a. Ctrl+W is readline's word delete.
    terminal = close_window,
    -- Apps where Ctrl+W doesn't close the window (config.lua).
    ["no-tabs"] = close_window,
  },
})

-- The compositor's close request is what an app's own "close window" shortcut
-- ends in, so one action covers every app (the plan's Ctrl+Shift+W for
-- browsers and VS Code would do the same). Omarchy's Omawrite launcher moved
-- off SUPER+SHIFT+W in Phase 1c.
action({
  id = "close-window",
  category = "Windows",
  mac = "⌘⇧W",
  keys = "SUPER + SHIFT + W",
  desc = "Close window",
  dispatcher = hl.dsp.window.close(),
})

mac({
  id = "quit-app",
  category = "Windows",
  mac = "⌘Q",
  keys = "SUPER + Q",
  desc = "Quit app (close all its windows)",
  actions = {
    default = quit_app, -- terminals too, as Terminal.app does
  },
})

-- Terminals have no ⌘ chord to receive, so these send their own: foot,
-- Ghostty, kitty and Alacritty open a new window on Ctrl+Shift+N. Ghostty and
-- kitty tabs come in 6a.
mac({
  id = "new-window",
  category = "Windows",
  mac = "⌘N",
  keys = "SUPER + N",
  desc = "New window",
  actions = {
    default = tap("CTRL", "N"),
    terminal = tap("CTRL + SHIFT", "N"),
  },
})

-- Private window in browsers, new folder in file managers. Firefox's private
-- window is Ctrl+Shift+P (6b).
mac({
  id = "new-window-private",
  category = "Windows",
  mac = "⌘⇧N",
  keys = "SUPER + SHIFT + N",
  desc = "New private window or folder",
  actions = {
    default = tap("CTRL + SHIFT", "N"),
    terminal = "consume",
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
    terminal = tap("CTRL + SHIFT", "N"), -- no tabs: a new window
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
    terminal = "consume",
  },
})

-- ⌘O/⌘P/⌘R/⌘L: Omarchy's pop, pseudo and layout binds moved to ⌃⌥ in Phase 1a.
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
    terminal = "consume",
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
    terminal = "consume",
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
    terminal = "consume",
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
    terminal = "consume",
  },
})

-- Zoom. Omarchy's resize binds on these keys moved to ⌃⌥ in Phase 1a. Terminals
-- take the same chords (foot and Ghostty bind them to font size), so there is
-- no terminal entry. ⌘+ is ⌘⇧= and zooms in like ⌘=.
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

-- Back and forward in browsers and Nautilus; outdent and indent in editors
-- (VS Code and Obsidian use Ctrl+[ / Ctrl+]). Terminals have no equivalent and
-- Ctrl+[ is Escape there. Omarchy's webcam binds moved to ⌃⌥ in Phase 1a.
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
    terminal = "consume",
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
    terminal = "consume",
  },
})

-- ⌘1–⌘9: tab N (⌘9 is the last tab in browsers, as on a Mac). Omarchy's
-- workspace binds moved to ⌃1–0 in Phase 1b. One bind per digit, written as a
-- loop like spaces.lua; each gets its own actions table, so Phase 6 can add
-- per-app entries. Terminals consume (Ghostty's Alt+N comes in 6a).
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
      terminal = "consume",
    },
  })
end

-- Previous and next tab on both Mac chords. Browsers, VS Code and Nautilus
-- all take Ctrl+Page_Up/Down. Terminals consume until 6a (Ghostty and kitty
-- have their own tab keys); Obsidian's ⌘⌥← / ⌘⌥→ become back/forward in 6e.
-- Omarchy's webcam binds (⌘⌥[ ]) and group moves (⌘⌥←/→) moved in Phase 1a.
mac({
  id = "previous-tab",
  category = "Windows",
  mac = "⌘⇧[",
  keys = "SUPER + SHIFT + bracketleft",
  desc = "Previous tab",
  actions = {
    default = tap("CTRL", "Page_Up"),
    terminal = "consume",
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
    terminal = "consume",
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
    terminal = "consume",
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
    terminal = "consume",
  },
})

-- ⌘Tab flips between the last two apps and, with ⌘ held, steps further along
-- the recency list (lib/switcher.lua). Omarchy's workspace switching on these
-- keys moved to ⌃⌥← / ⌃⌥→ in Phase 1b; ⌥Tab still cycles windows in layout order.
mac({
  id = "switch-app",
  category = "Windows",
  mac = "⌘Tab",
  keys = "SUPER + TAB",
  desc = "Switch app",
  actions = {
    default = function()
      switcher.step(true)
    end,
  },
})

mac({
  id = "switch-app-back",
  category = "Windows",
  mac = "⌘⇧Tab",
  keys = "SUPER + SHIFT + TAB",
  desc = "Switch app backwards",
  actions = {
    default = function()
      switcher.step(false)
    end,
  },
})

-- Fixed-order ring of the active app's windows, across workspaces. With one
-- window nothing happens.
mac({
  id = "next-app-window",
  category = "Windows",
  mac = "⌘`",
  keys = "SUPER + grave",
  desc = "Next window of this app",
  actions = {
    default = function()
      cycle_app_windows(1)
    end,
  },
})

mac({
  id = "previous-app-window",
  category = "Windows",
  mac = "⌘⇧`",
  keys = "SUPER + SHIFT + grave",
  desc = "Previous window of this app",
  actions = {
    default = function()
      cycle_app_windows(-1)
    end,
  },
})

-- Preferences. Omarchy's "dismiss last notification" moved off ⌘, in Phase 1d.
-- VS Code, Obsidian and Nautilus open their settings on Ctrl+, ; browsers and
-- LibreOffice have no such shortcut (6b, 6f) and Ghostty's open-config key comes
-- in 6a. Terminals consume it: Ctrl+, is not a control character.
mac({
  id = "preferences",
  category = "Windows",
  mac = "⌘,",
  keys = "SUPER + comma",
  desc = "Preferences",
  actions = {
    default = tap("CTRL", "comma"),
    terminal = "consume",
  },
})
