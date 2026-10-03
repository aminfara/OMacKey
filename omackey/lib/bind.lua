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

local function check(kind, spec, fields)
  for _, field in ipairs(fields) do
    if spec[field] == nil then
      error("OMacKey: " .. kind .. "{} needs '" .. field .. "' (" .. tostring(spec.id or spec.keys) .. ")", 3)
    end
  end
  if M.by_id[spec.id] then
    error("OMacKey: duplicate binding id '" .. spec.id .. "'", 3)
  end
end

local function register(spec)
  table.insert(M.registry, spec)
  M.by_id[spec.id] = spec
  return spec
end

function M.mac(spec)
  check("mac", spec, { "id", "keys", "desc", "actions" })

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

  return register(spec)
end

-- action{}: a Hyprland action on a key, the same in every app (workspaces,
-- windows). Recorded in the registry like mac{}.
--
--   action({
--     id = "workspace-next-down", category = "Spaces", mac = "⌃↓",
--     keys = "CTRL + DOWN", desc = "Next workspace",
--     dispatcher = hl.dsp.focus({ workspace = "e+1" }),
--   })
function M.action(spec)
  check("action", spec, { "id", "keys", "desc", "dispatcher" })

  hl.bind(spec.keys, spec.dispatcher, {
    description = spec.desc,
    repeating = spec.repeating,
    release = spec.release,
  })

  return register(spec)
end

return M
