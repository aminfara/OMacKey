-- Active window → chain of profile names to try, most specific first, ending
-- in "default". Profiles are configured in config.lua.

local config = require("hypr.omackey.config")

local M = {}

local function has_tag(window, wanted)
  local tags = window.tags
  if type(tags) == "string" then
    tags = { tags }
  end

  for _, tag in ipairs(tags or {}) do
    -- Dynamic tags carry a trailing "*".
    if tag:gsub("%*$", "") == wanted then
      return true
    end
  end

  return false
end

local function matches(profile, window)
  for _, class in ipairs(profile.classes or {}) do
    if window.class == class then
      return true
    end
  end

  for _, tag in ipairs(profile.tags or {}) do
    if has_tag(window, tag) then
      return true
    end
  end

  return false
end

local function find(name)
  for _, profile in ipairs(config.profiles) do
    if profile.name == name then
      return profile
    end
  end
end

-- apps.chain(window) → e.g. { "foot", "terminal", "default" }
function M.chain(window)
  local chain = {}

  if window then
    for _, profile in ipairs(config.profiles) do
      if matches(profile, window) then
        local current = profile
        while current and #chain < 8 do
          table.insert(chain, current.name)
          current = current.family and find(current.family)
        end
        break
      end
    end
  end

  table.insert(chain, "default")
  return chain
end

return M
