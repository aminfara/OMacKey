-- mac{}: one global bind per Mac shortcut that picks the action for the active
-- window's profile at press time, and records the binding in a registry for
-- `hyprctl repl` introspection and the docs generator.
--
--   mac({
--     id = "line-start", category = "Cursor", mac = "⌘←",
--     keys = "SUPER + LEFT", desc = "Line start", repeating = true,
--     actions = {
--       default = send.tap("", "Home"),  -- function: run it
--       terminal = "consume",            -- do nothing
--       vscode = "pass",                 -- let the app receive the raw key
--     },
--   })

local apps = require("hypr.omackey.lib.apps")

local M = {
  registry = {}, -- specs in definition order
  by_id = {},
}

local function run(spec)
  for _, profile in ipairs(apps.chain(hl.get_active_window())) do
    local action = spec.actions[profile]
    if action ~= nil then
      if action == "pass" then
        return { ok = false }
      elseif action ~= "consume" then
        action()
      end
      return
    end
  end

  -- No action for any profile: behave as if the bind did not exist.
  return { ok = false }
end

function M.mac(spec)
  for _, field in ipairs({ "id", "keys", "desc", "actions" }) do
    if spec[field] == nil then
      error("OMacKey: mac{} needs '" .. field .. "' (" .. tostring(spec.id or spec.keys) .. ")", 2)
    end
  end
  if M.by_id[spec.id] then
    error("OMacKey: duplicate binding id '" .. spec.id .. "'", 2)
  end

  spec.fired = 0 -- press count, for tests: hyprctl repl 'return omackey.fired("line-start")'
  spec.handler = function()
    spec.fired = spec.fired + 1
    return run(spec)
  end

  -- auto_consuming: a handler returning { ok = false } passes the key through.
  hl.bind(spec.keys, spec.handler, {
    description = spec.desc,
    repeating = spec.repeating,
    auto_consuming = true,
  })

  table.insert(M.registry, spec)
  M.by_id[spec.id] = spec
  return spec
end

return M
