-- VS Code shortcuts (PLAN.md §5). The Mac keybindings use ⌘ where the
-- Linux ones use Ctrl, so most keys are covered by the generic rules. These are
-- the ones whose Linux chord differs from the Mac's, so ⌘ → Ctrl is not enough.
-- Chords read from the installed workbench.desktop.main.js (§9 F13).
--
-- A key here without a `default` does nothing outside VS Code: the raw chord
-- reaches the app.

local bind = require("hypr.omackey.lib.bind")
local mac, CONSUME = bind.mac, bind.CONSUME
local tap = require("hypr.omackey.lib.send").tap

-- Add cursor above / below. Linux's own primary is Shift+Alt+Up; Ctrl+Shift+Up
-- is its secondary key for the same command.
mac({
  id = "add-cursor-above",
  category = "VS Code",
  mac = "⌘⌥↑",
  keys = "SUPER + ALT + UP",
  desc = "Add cursor above",
  repeating = true,
  actions = {
    obsidian = tap("CTRL + ALT", "Up"), -- Mod+Alt+Up is the same chord on both platforms
  },
})

mac({
  id = "add-cursor-below",
  category = "VS Code",
  mac = "⌘⌥↓",
  keys = "SUPER + ALT + DOWN",
  desc = "Add cursor below",
  repeating = true,
  actions = {
    obsidian = tap("CTRL + ALT", "Down"),
  },
})

-- Omarchy's webcam size binds for these keys are on ⌃⌥.
mac({
  id = "fold",
  category = "VS Code",
  mac = "⌘⌥[",
  keys = "SUPER + ALT + bracketleft",
  desc = "Fold code",
  actions = {
  },
})

mac({
  id = "unfold",
  category = "VS Code",
  mac = "⌘⌥]",
  keys = "SUPER + ALT + bracketright",
  desc = "Unfold code",
  actions = {
  },
})

-- Omarchy's "Full width" is on ⌃⌥⏎.
mac({
  id = "replace",
  category = "VS Code",
  mac = "⌘⌥F",
  keys = "SUPER + ALT + F",
  desc = "Replace",
  actions = {
    obsidian = tap("CTRL", "H"),
  },
})

mac({
  id = "shrink-selection",
  category = "VS Code",
  mac = "⌃⇧⌘←",
  keys = "SUPER + CTRL + SHIFT + LEFT",
  desc = "Shrink selection",
  repeating = true,
  actions = {
  },
})

mac({
  id = "expand-selection",
  category = "VS Code",
  mac = "⌃⇧⌘→",
  keys = "SUPER + CTRL + SHIFT + RIGHT",
  desc = "Expand selection",
  repeating = true,
  actions = {
  },
})

-- Quick fix is Ctrl+. on Linux and ⌘. on the Mac: the VS Code entry of ⌘.
-- (cancel, editing.lua).

-- Keys whose Mac and Linux chords differ. Found by diffing the Mac
-- and Linux keymaps in the installed workbench.desktop.main.js (§9 F15).

-- Mac ⌥⇧↑ / ⌥⇧↓ copy the line. On Linux the same physical chord adds a cursor
-- (Shift+Alt+Up), and the copy is Ctrl+Shift+Alt+Up.
mac({
  id = "copy-line-up",
  category = "VS Code",
  mac = "⌥⇧↑",
  keys = "ALT + SHIFT + UP",
  desc = "Copy line up",
  repeating = true,
  actions = {
  },
})

mac({
  id = "copy-line-down",
  category = "VS Code",
  mac = "⌥⇧↓",
  keys = "ALT + SHIFT + DOWN",
  desc = "Copy line down",
  repeating = true,
  actions = {
  },
})

-- Toggle block comment: Shift+Alt+A on the Mac, Ctrl+Shift+A on Linux.
mac({
  id = "block-comment",
  category = "VS Code",
  mac = "⌥⇧A",
  keys = "ALT + SHIFT + A",
  desc = "Toggle block comment",
  actions = {
  },
})

-- The Mac zooms out on ⌘⇧- as well as ⌘-. On Linux Ctrl+Shift+- is Navigate
-- Forward, which is what the catch-all would send. Other apps keep the
-- catch-all's Ctrl+Shift+-.
mac({
  id = "zoom-out-shifted",
  category = "VS Code",
  mac = "⌘⇧-",
  keys = "SUPER + SHIFT + minus",
  desc = "Zoom out (VS Code)",
  actions = {
    default = tap("CTRL + SHIFT", "minus"),
  },
})

-- Find widget toggles: ⌘⌥ + letter on the Mac, Alt + letter on Linux. Case
-- (⌘⌥C) and the secondary side bar (⌘⌥B) sit on the browser entries in
-- browsers.lua, which own those keys.
mac({
  id = "find-whole-word",
  category = "VS Code",
  mac = "⌘⌥W",
  keys = "SUPER + ALT + W",
  desc = "Find: match whole word",
  actions = {
  },
})

mac({
  id = "find-regex",
  category = "VS Code",
  mac = "⌘⌥R",
  keys = "SUPER + ALT + R",
  desc = "Find: use regular expression",
  actions = {
  },
})

mac({
  id = "find-in-selection",
  category = "VS Code",
  mac = "⌘⌥L",
  keys = "SUPER + ALT + L",
  desc = "Find: in selection",
  actions = {
  },
})

mac({
  id = "find-preserve-case",
  category = "VS Code",
  mac = "⌘⌥P",
  keys = "SUPER + ALT + P",
  desc = "Replace: preserve case",
  actions = {
  },
})
