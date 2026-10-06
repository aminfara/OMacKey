-- Declares the Mac shortcuts (the modules listed in config.lua) and the app
-- profiles (APPS below), then builds and binds them in one pass
-- (lib/bind.lua), after Omarchy's defaults.
--
-- A module that fails to load is reported and skipped, and so is every spec
-- that fails validation; the rest still loads.

local config = require("hypr.omackey.config")
local bind = require("hypr.omackey.lib.bind")

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

for _, name in ipairs(config.modules) do
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
