-- Core editing: clipboard, undo/redo, find, save, and the code-editing keys
-- (PLAN.md §5). Each spec says what the key does in a generic app; apps/*.lua
-- add per-app entries. Omarchy's universal copy, paste and cut are dropped in
-- relocations.lua.

local bind = require("hypr.omackey.lib.bind")
local mac, CONSUME = bind.mac, bind.CONSUME
local tap = require("hypr.omackey.lib.send").tap

mac({
  id = "copy",
  category = "Editing",
  mac = "⌘C",
  keys = "SUPER + C",
  desc = "Copy",
  actions = {
    default = tap("CTRL", "C"),
  },
})

mac({
  id = "paste",
  category = "Editing",
  mac = "⌘V",
  keys = "SUPER + V",
  desc = "Paste",
  actions = {
    default = tap("CTRL", "V"),
  },
})

mac({
  id = "cut",
  category = "Editing",
  mac = "⌘X",
  keys = "SUPER + X",
  desc = "Cut",
  actions = {
    default = tap("CTRL", "X"),
  },
})

mac({
  id = "paste-plain",
  category = "Editing",
  mac = "⌘⇧V",
  keys = "SUPER + SHIFT + V",
  desc = "Paste without formatting",
  actions = {
    default = tap("CTRL + SHIFT", "V"),
  },
})

mac({
  id = "undo",
  category = "Editing",
  mac = "⌘Z",
  keys = "SUPER + Z",
  desc = "Undo",
  repeating = true,
  actions = {
    default = tap("CTRL", "Z"),
  },
})

mac({
  id = "redo",
  category = "Editing",
  mac = "⌘⇧Z",
  keys = "SUPER + SHIFT + Z",
  desc = "Redo",
  repeating = true,
  actions = {
    default = tap("CTRL + SHIFT", "Z"), -- LibreOffice uses Ctrl+Y
  },
})

mac({
  id = "select-all",
  category = "Editing",
  mac = "⌘A",
  keys = "SUPER + A",
  desc = "Select all",
  actions = {
    default = tap("CTRL", "A"),
  },
})

mac({
  id = "save",
  category = "Editing",
  mac = "⌘S",
  keys = "SUPER + S",
  desc = "Save",
  actions = {
    default = tap("CTRL", "S"),
  },
})

mac({
  id = "save-as",
  category = "Editing",
  mac = "⌘⇧S",
  keys = "SUPER + SHIFT + S",
  desc = "Save as",
  actions = {
    default = tap("CTRL + SHIFT", "S"),
  },
})

mac({
  id = "find",
  category = "Editing",
  mac = "⌘F",
  keys = "SUPER + F",
  desc = "Find",
  actions = {
    default = tap("CTRL", "F"),
  },
})

-- F3 / Shift+F3 work in Chromium, Firefox, VS Code and GTK.
mac({
  id = "find-next",
  category = "Editing",
  mac = "⌘G",
  keys = "SUPER + G",
  desc = "Find next",
  repeating = true,
  actions = {
    default = tap("", "F3"),
  },
})

mac({
  id = "find-previous",
  category = "Editing",
  mac = "⌘⇧G",
  keys = "SUPER + SHIFT + G",
  desc = "Find previous",
  repeating = true,
  actions = {
    default = tap("SHIFT", "F3"),
  },
})

mac({
  id = "bold",
  category = "Editing",
  mac = "⌘B",
  keys = "SUPER + B",
  desc = "Bold",
  actions = {
    default = tap("CTRL", "B"),
  },
})

mac({
  id = "italic",
  category = "Editing",
  mac = "⌘I",
  keys = "SUPER + I",
  desc = "Italic",
  actions = {
    default = tap("CTRL", "I"),
  },
})

mac({
  id = "underline",
  category = "Editing",
  mac = "⌘U",
  keys = "SUPER + U",
  desc = "Underline",
  actions = {
    default = tap("CTRL", "U"),
  },
})

mac({
  id = "toggle-comment",
  category = "Editing",
  mac = "⌘/",
  keys = "SUPER + SLASH",
  desc = "Toggle comment",
  actions = {
    default = tap("CTRL", "slash"),
  },
})

-- ⌘. cancels: Escape in GUI apps (dialogs, menus, search bars). Terminals
-- interrupt (Ctrl+C, like Terminal.app); in VS Code it is Quick Fix.
mac({
  id = "cancel",
  category = "Editing",
  mac = "⌘.",
  keys = "SUPER + period",
  desc = "Cancel (Escape)",
  actions = {
    default = tap("", "Escape"),
  },
})

-- Code editing. These keys have no generic action: they act in the apps that
-- have an entry (VS Code, Obsidian) and reach other apps as raw chords.

mac({
  id = "add-cursor-above",
  category = "VS Code",
  mac = "⌘⌥↑",
  keys = "SUPER + ALT + UP",
  desc = "Add cursor above",
  repeating = true,
})

mac({
  id = "add-cursor-below",
  category = "VS Code",
  mac = "⌘⌥↓",
  keys = "SUPER + ALT + DOWN",
  desc = "Add cursor below",
  repeating = true,
})

-- Omarchy's webcam size binds for these keys are on ⌃⌥.
mac({
  id = "fold",
  category = "VS Code",
  mac = "⌘⌥[",
  keys = "SUPER + ALT + bracketleft",
  desc = "Fold code",
})

mac({
  id = "unfold",
  category = "VS Code",
  mac = "⌘⌥]",
  keys = "SUPER + ALT + bracketright",
  desc = "Unfold code",
})

-- Omarchy's "Full width" is on ⌃⌥⏎.
mac({
  id = "replace",
  category = "VS Code",
  mac = "⌘⌥F",
  keys = "SUPER + ALT + F",
  desc = "Replace",
})

mac({
  id = "shrink-selection",
  category = "VS Code",
  mac = "⌃⇧⌘←",
  keys = "SUPER + CTRL + SHIFT + LEFT",
  desc = "Shrink selection",
  repeating = true,
})

mac({
  id = "expand-selection",
  category = "VS Code",
  mac = "⌃⇧⌘→",
  keys = "SUPER + CTRL + SHIFT + RIGHT",
  desc = "Expand selection",
  repeating = true,
})

mac({
  id = "copy-line-up",
  category = "VS Code",
  mac = "⌥⇧↑",
  keys = "ALT + SHIFT + UP",
  desc = "Copy line up",
  repeating = true,
})

mac({
  id = "copy-line-down",
  category = "VS Code",
  mac = "⌥⇧↓",
  keys = "ALT + SHIFT + DOWN",
  desc = "Copy line down",
  repeating = true,
})

mac({
  id = "block-comment",
  category = "VS Code",
  mac = "⌥⇧A",
  keys = "ALT + SHIFT + A",
  desc = "Toggle block comment",
})

-- ⌘⇧- zooms out in VS Code, as on the Mac; elsewhere it sends Ctrl+Shift+-,
-- like the catch-all.
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

-- Find widget toggles (VS Code). Match case is ⌘⌥C, which is also the
-- browsers' inspect key (windows.lua).
mac({
  id = "find-whole-word",
  category = "VS Code",
  mac = "⌘⌥W",
  keys = "SUPER + ALT + W",
  desc = "Find: match whole word",
})

mac({
  id = "find-regex",
  category = "VS Code",
  mac = "⌘⌥R",
  keys = "SUPER + ALT + R",
  desc = "Find: use regular expression",
})

mac({
  id = "find-in-selection",
  category = "VS Code",
  mac = "⌘⌥L",
  keys = "SUPER + ALT + L",
  desc = "Find: in selection",
})

mac({
  id = "find-preserve-case",
  category = "VS Code",
  mac = "⌘⌥P",
  keys = "SUPER + ALT + P",
  desc = "Replace: preserve case",
})

-- Redo selection (Obsidian). Elsewhere ⌘⇧U is consumed, as in the catch-all
-- (Ctrl+Shift+U starts Unicode input in GTK and fcitx5).
mac({
  id = "redo-selection",
  category = "Obsidian",
  mac = "⌘⇧U",
  keys = "SUPER + SHIFT + U",
  desc = "Redo selection (Obsidian)",
  actions = {
    default = CONSUME,
  },
})

-- Paste Special (LibreOffice). ⌘⇧V pastes unformatted text everywhere, so this
-- is the way to the dialog. Elsewhere ⌘⌥V reaches the app as a raw chord.
mac({
  id = "paste-special",
  category = "LibreOffice",
  mac = "⌘⌥V",
  keys = "SUPER + ALT + V",
  desc = "Paste special (LibreOffice)",
})
