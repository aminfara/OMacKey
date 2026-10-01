-- Loads the feature modules listed in config.lua, after Omarchy's defaults.

local config = require("hypr.omackey.config")

for _, name in ipairs(config.modules) do
  require("hypr.omackey." .. name)
end
