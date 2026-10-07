-- LibreOffice. Accelerators from share/registry/main.xcd (docs/FINDINGS.md
-- F17, F23): the generic F3 / Shift+F3 and a few Ctrl chords mean something
-- else here.
-- Its dialogs (Options, Paste Special) have class `soffice`.

local app = require("hypr.omackey.lib.profiles").app
local send = require("hypr.omackey.lib.send")
local tap, seq = send.tap, send.seq

app({
  name = "libreoffice",
  classes = {
    "libreoffice-writer", "libreoffice-calc", "libreoffice-impress", "libreoffice-draw",
    "libreoffice-math", "libreoffice-base", "libreoffice-startcenter", "soffice",
  },
  actions = {
    -- Editing
    ["paste-plain"] = tap("CTRL + ALT + SHIFT", "V"), -- Ctrl+Shift+V is Paste Special here
    ["paste-special"] = tap("CTRL + SHIFT", "V"), -- ⌥⌘V: the Paste Special dialog
    -- ⌘G / ⇧⌘G step through the find bar's matches: Ctrl+F focuses the bar
    -- (it keeps the search text), Return / Shift+Return find the next /
    -- previous match, Escape closes the bar with the match selected. F3 is
    -- AutoText and Shift+F3 changes case here, and Ctrl+Shift+F (Repeat
    -- Search) only repeats a search made in the Find & Replace dialog.
    ["find-next"] = seq(tap("CTRL", "F"), tap("", "Return"), tap("", "Escape")),
    ["find-previous"] = seq(tap("CTRL", "F"), tap("SHIFT", "Return"), tap("", "Escape")),
    -- Windows and tabs
    ["preferences"] = tap("ALT", "F12"), -- Tools > Options
  },
})
