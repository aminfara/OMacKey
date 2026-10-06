-- The manifest: declares the Mac shortcuts (MODULES) and the app profiles
-- (APPS), then builds and binds them in one pass (lib/bind.lua), after
-- Omarchy's defaults.
--
-- A module that fails to load is reported and skipped, and so is every spec
-- that fails validation; the rest still loads.

local bind = require("hypr.omackey.lib.bind")
local settings = require("hypr.omackey.settings")

-- Modules that declare the Mac shortcuts (omackey/<name>.lua), in this order;
-- they are bound in the same order.
local MODULES = {
  "spaces", -- workspaces on ⌃ (vertical pair, move window)
  "text", -- cursor movement, selection, deletion
  "editing", -- clipboard, undo/redo, find, save, code editing
  "windows", -- windows and tabs, navigation, browser and terminal keys
  "system", -- OS controls (lock, screenshots, emoji)
  "mouse", -- ⌘-click and ⌘-scroll as Ctrl-click and Ctrl-scroll (scroll needs wtype)
  "emacs", -- Emacs ⌃ keys (bound only when the emacs_keys setting is on)
  "catchall", -- every ⌘ / ⌘⇧ key nothing else claims
}

-- App profiles (omackey/apps/<name>.lua), in match order: the first app whose
-- classes or tags match the active window wins, so specific apps come before
-- the families they belong to.
local APPS = {
  "ghostty",
  "kitty",
  "foot",
  "terminal",
  "firefox",
  "browser",
  "vscode",
  "libreoffice",
  "obsidian",
  "nautilus",
  "no-tabs",
}

local function declare(path)
  local ok, err = pcall(require, "hypr.omackey." .. path)
  if not ok then
    table.insert(bind.errors, "module " .. path .. ": " .. tostring(err))
  end
end

for _, message in ipairs(settings.errors) do
  table.insert(bind.errors, message)
end

for _, name in ipairs(MODULES) do
  declare(name)
end
for _, name in ipairs(APPS) do
  declare("apps." .. name)
end

local errors = bind.build()
if #errors > 0 then
  for _, message in ipairs(errors) do
    table.insert(omackey.errors, "OMacKey config: " .. message)
  end
  pcall(hl.notification.create, {
    text = "OMacKey: " .. #errors .. " config error(s), see omackey.status(): " .. errors[1],
    timeout = 15000,
  })
end

bind.apply()

-- The on/off key (it is also the only bind while OMacKey is off).
require("hypr.omackey.lib.mode").bind()
