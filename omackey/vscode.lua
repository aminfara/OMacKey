-- Phase 6c: VS Code shortcuts (PLAN.md §5). The Mac keybindings use ⌘ where the
-- Linux ones use Ctrl, so most keys are covered by the generic rules. These are
-- the ones whose Linux chord differs from the Mac's, so ⌘ → Ctrl is not enough.
-- Chords read from the installed workbench.desktop.main.js (§9 F13).
--
-- Elsewhere these have no action, so the raw ⌘ chord reaches the app as before;
-- Phase 7a decides what the catch-all sends there.

local mac = require("hypr.omackey.lib.bind").mac
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
    vscode = tap("CTRL + SHIFT", "Up"),
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
    vscode = tap("CTRL + SHIFT", "Down"),
  },
})

-- Omarchy's webcam size binds moved to ⌃⌥ in Phase 1a.
mac({
  id = "fold",
  category = "VS Code",
  mac = "⌘⌥[",
  keys = "SUPER + ALT + bracketleft",
  desc = "Fold code",
  actions = {
    vscode = tap("CTRL + SHIFT", "bracketleft"),
  },
})

mac({
  id = "unfold",
  category = "VS Code",
  mac = "⌘⌥]",
  keys = "SUPER + ALT + bracketright",
  desc = "Unfold code",
  actions = {
    vscode = tap("CTRL + SHIFT", "bracketright"),
  },
})

-- Omarchy's "Full width" moved to ⌃⌥⏎ in Phase 1a.
mac({
  id = "replace",
  category = "VS Code",
  mac = "⌘⌥F",
  keys = "SUPER + ALT + F",
  desc = "Replace",
  actions = {
    vscode = tap("CTRL", "H"),
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
    vscode = tap("SHIFT + ALT", "Left"),
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
    vscode = tap("SHIFT + ALT", "Right"),
  },
})

-- Quick fix is Ctrl+. on Linux and ⌘. on the Mac. Phase 7b adds the generic
-- ⌘. (Escape) on this key and keeps this entry.
mac({
  id = "quick-fix",
  category = "VS Code",
  mac = "⌘.",
  keys = "SUPER + period",
  desc = "Quick fix",
  actions = {
    vscode = tap("CTRL", "period"),
  },
})
