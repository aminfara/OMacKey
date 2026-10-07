-- The manifest: declares the Mac shortcuts (MODULES) and the apps
-- (APPS). load.lua then validates and binds them in one pass (lib/bind.lua),
-- after Omarchy's defaults.
--
-- A module that fails to load is reported and skipped, and so is every spec
-- that fails validation; the rest still loads.

local bind = require("hypr.omackey.lib.bind")
local settings = require("hypr.omackey.settings")

-- Modules that declare the Mac shortcuts (omackey/<name>.lua).
local MODULES = {
  "shortcuts", -- every Mac shortcut, one section per group
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
