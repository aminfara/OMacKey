-- Declares the Mac shortcuts from the modules listed in config.lua, then
-- builds and binds them in one pass (lib/bind.lua), after Omarchy's defaults.
--
-- A module that fails to load is reported and skipped, and so is every spec
-- that fails validation; the rest still loads.

local config = require("hypr.omackey.config")
local bind = require("hypr.omackey.lib.bind")

for _, name in ipairs(config.modules) do
  local ok, err = pcall(require, "hypr.omackey." .. name)
  if not ok then
    table.insert(bind.errors, "module " .. name .. ": " .. tostring(err))
  end
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
