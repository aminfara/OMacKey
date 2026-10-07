-- Apps (the module keeps its old name, "profiles"): app{} declares an app (or a family of apps), how its windows
-- are recognised, and its actions on Mac shortcuts by key id. The key specs
-- say what a shortcut does in a generic app (`default`); an app's actions are
-- overlaid on them when the config is built (lib/bind.lua).
--
--   app({
--     name = "foot",
--     family = "terminal",             -- tried next when foot has no action
--     classes = { "foot", "org.codeberg.dnkl.foot" },
--     tags = { … },                    -- Omarchy's window tags (default/hypr/apps/*.lua)
--     catchall = CONSUME,              -- its action on every catch-all key
--     actions = {
--       ["find"] = send.tap("CTRL + SHIFT", "R"),
--     },
--   })
--
-- Apps are matched in declaration order (the manifest in init.lua): the first
-- app whose classes or tags match the active window wins. Its chain is the
-- app, then its family, then "default"; the first of them with an action on
-- the key decides, and none means the raw key passes through.

local M = {
  apps = {}, -- declared apps, in match order
  by_name = {},
}

function M.app(def)
  table.insert(M.apps, def)
  return def
end

local rank_by_class, rank_by_tag, chains = {}, {}, {}

-- Validates the declared apps and builds the match index and the chains.
-- Appends a message to `errors` for each faulty app, which is left out.
function M.build(errors)
  local valid = {}

  for _, def in ipairs(M.apps) do
    local problem
    if type(def.name) ~= "string" or def.name == "" then
      problem = "needs 'name'"
    elseif def.name == "default" or M.by_name[def.name] then
      problem = "is declared twice"
    end

    if problem then
      table.insert(errors, "app '" .. tostring(def.name) .. "' " .. problem)
    else
      M.by_name[def.name] = def
      table.insert(valid, def)
    end
  end

  for _, def in ipairs(valid) do
    if def.family and not M.by_name[def.family] then
      table.insert(errors, "app '" .. def.name .. "' has an unknown family '" .. tostring(def.family) .. "'")
      def.family = nil
    end
  end

  for rank, def in ipairs(valid) do
    for _, class in ipairs(def.classes or {}) do
      rank_by_class[class] = rank_by_class[class] or rank
    end
    for _, tag in ipairs(def.tags or {}) do
      rank_by_tag[tag] = rank_by_tag[tag] or rank
    end

    local chain, current = {}, def
    while current and #chain < 8 do
      table.insert(chain, current.name)
      current = current.family and M.by_name[current.family]
    end
    table.insert(chain, "default")
    chains[rank] = chain
  end

  M.apps = valid
end

local DEFAULT_CHAIN = { "default" }

-- profiles.chain(window) → e.g. { "foot", "terminal", "default" }
function M.chain(window)
  if not window then
    return DEFAULT_CHAIN
  end

  local best = rank_by_class[window.class]

  local tags = window.tags
  if type(tags) == "string" then
    tags = { tags }
  end
  for _, tag in ipairs(tags or {}) do
    -- Dynamic tags carry a trailing "*".
    local rank = rank_by_tag[(tag:gsub("%*$", ""))]
    if rank and (not best or rank < best) then
      best = rank
    end
  end

  return best and chains[best] or DEFAULT_CHAIN
end

return M
