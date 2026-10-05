-- Phase 3: core editing (PLAN.md §5).

local mac = require("hypr.omackey.lib.bind").mac
local tap = require("hypr.omackey.lib.send").tap

-- Replaces Omarchy's universal copy, paste and cut. Exact strings from
-- /usr/share/omarchy/default/hypr/bindings/clipboard.lua.
hl.unbind("SUPER + C")
hl.unbind("SUPER + V")
hl.unbind("SUPER + X")

mac({
  id = "copy",
  category = "Editing",
  mac = "⌘C",
  keys = "SUPER + C",
  desc = "Copy",
  actions = {
    default = tap("CTRL", "C"),
    terminal = tap("CTRL", "Insert"), -- Ctrl+C is SIGINT in a terminal
    vscode = tap("CTRL", "Insert"), -- because hyprland does not distinguisdh between vscode and its integrated terminal
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
    terminal = tap("SHIFT", "Insert"), -- Ctrl+V is a literal-next in a terminal
    vscode = tap("SHIFT", "Insert"), -- because hyprland does not distinguisdh between vscode and its integrated terminal
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
    terminal = "consume", -- Ctrl+X is a readline prefix; a terminal has nothing to cut
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
    terminal = tap("SHIFT", "Insert"), -- terminals paste plain text already
    libreoffice = tap("CTRL + ALT + SHIFT", "V"), -- Ctrl+Shift+V is Paste Special there
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
    terminal = "consume", -- Ctrl+Z would suspend the foreground job
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
    default = tap("CTRL + SHIFT", "Z"), -- LibreOffice uses Ctrl+Y (6f)
    terminal = "consume",
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
    terminal = "consume", -- Ctrl+A is readline's line start
    ghostty = tap("CTRL + SHIFT", "A"),
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
    terminal = "consume", -- Ctrl+S freezes terminal output (XOFF)
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
    terminal = "consume",
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
    terminal = "consume", -- Ctrl+F is readline's forward-char
    -- Each terminal's scrollback search. ⌘G / ⌘⇧G stay consumed: they only
    -- mean something while a search is open, which Hyprland can't tell (§9 F10).
    ghostty = tap("CTRL + SHIFT", "F"),
    kitty = tap("CTRL + SHIFT", "slash"),
    foot = tap("CTRL + SHIFT", "R"),
  },
})

-- F3 works in Chromium, Firefox, VS Code and GTK. LibreOffice (6f) and
-- Nautilus (6d) override these.
mac({
  id = "find-next",
  category = "Editing",
  mac = "⌘G",
  keys = "SUPER + G",
  desc = "Find next",
  repeating = true,
  actions = {
    default = tap("", "F3"),
    terminal = "consume",
    libreoffice = tap("CTRL + SHIFT", "F"), -- F3 is AutoText there; Ctrl+Shift+F repeats the search
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
    terminal = "consume",
    nautilus = tap("CTRL", "L"), -- go to location, as in Finder
    libreoffice = "consume", -- Shift+F3 changes case there, and no key finds the previous match (§7)
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
    terminal = "consume", -- Ctrl+B is readline's backward-char (and tmux's prefix)
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
    terminal = "consume", -- Ctrl+I is Tab
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
    terminal = "consume", -- Ctrl+U deletes the line (⌘⌫ owns that)
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
    terminal = "consume",
  },
})
