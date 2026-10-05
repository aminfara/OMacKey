-- Loads the feature modules listed in config.lua, after Omarchy's defaults.

local config = require("hypr.omackey.config")

for _, name in ipairs(config.modules) do
  require("hypr.omackey." .. name)
end

-- Phase 7d: the on/off key (it is also the only bind while OMacKey is off).
require("hypr.omackey.lib.mode").bind()
