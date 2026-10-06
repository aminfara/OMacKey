-- Nautilus (Files): where its keys differ from Finder's (PLAN.md §9 F5).

local app = require("hypr.omackey.lib.profiles").app
local bind = require("hypr.omackey.lib.bind")
local CONSUME = bind.CONSUME
local tap = require("hypr.omackey.lib.send").tap

local actions = {
  -- Text navigation and deletion: Finder's meanings of these keys
  ["document-start"] = tap("ALT", "Up"), -- ⌘↑: parent folder
  ["document-end"] = tap("", "Return"), -- ⌘↓: open the selection
  ["delete-line-start"] = tap("", "Delete"), -- ⌘⌫: move to trash
  -- Editing
  ["find-previous"] = tap("CTRL", "L"), -- ⌘⇧G: go to location
  -- Windows and tabs
  ["back"] = tap("ALT", "Left"),
  ["forward"] = tap("ALT", "Right"),
  -- Files
  ["show-hidden-files"] = tap("CTRL", "H"), -- ⌘⇧. in Finder
}

-- ⌘1 / ⌘2 are Finder's icon / list view: Nautilus's Ctrl+2 / Ctrl+1. ⌘3–⌘9 do
-- nothing (Finder's column and gallery views don't exist; no tabs by number).
actions["tab-1"] = tap("CTRL", "2")
actions["tab-2"] = tap("CTRL", "1")
for n = 3, 9 do
  actions["tab-" .. n] = CONSUME
end

app({
  name = "nautilus",
  classes = { "org.gnome.Nautilus" },
  actions = actions,
})
