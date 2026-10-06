-- LibreOffice. Accelerators from share/registry/main.xcd (PLAN.md §9 F17):
-- the generic F3 / Shift+F3 and a few Ctrl chords mean something else here.
-- Its dialogs (Options, Paste Special) have class `soffice`.

local app = require("hypr.omackey.lib.profiles").app
local bind = require("hypr.omackey.lib.bind")
local CONSUME = bind.CONSUME
local tap = require("hypr.omackey.lib.send").tap

app({
  name = "libreoffice",
  classes = {
    "libreoffice-writer", "libreoffice-calc", "libreoffice-impress", "libreoffice-draw",
    "libreoffice-math", "libreoffice-base", "libreoffice-startcenter", "soffice",
  },
  actions = {
    -- Editing
    ["paste-plain"] = tap("CTRL + ALT + SHIFT", "V"), -- Ctrl+Shift+V is Paste Special here
    ["paste-special"] = tap("CTRL + SHIFT", "V"), -- ⌘⌥V: the Paste Special dialog
    ["find-next"] = tap("CTRL + SHIFT", "F"), -- F3 is AutoText; Ctrl+Shift+F repeats the search
    ["find-previous"] = CONSUME, -- Shift+F3 changes case, and no key finds the previous match (§7)
    -- Windows and tabs
    ["preferences"] = tap("ALT", "F12"), -- Tools > Options
  },
})
