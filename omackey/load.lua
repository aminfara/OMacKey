-- Entry points called from ~/.config/hypr/hyprland.lua (lines added by
-- install.sh):
--
--   pre()  right before require("default.hypr.omarchy"): start relocating
--   init() right after it: stop relocating, add the Mac bindings
--
-- Each stage is guarded, so an OMacKey error is reported as a notification
-- and Omarchy's defaults and the user's own config still load. Nothing is
-- printed: Omarchy's keybindings menu replays this config and parses stdout.

local M = {}

-- Global for introspection: hyprctl repl 'return omackey.status()'
omackey = omackey or { errors = {} }

local function report(stage, err)
  local message = "OMacKey " .. stage .. " failed: " .. tostring(err)
  table.insert(omackey.errors, message)
  pcall(hl.notification.create, { text = message, timeout = 15000 })
end

local function guarded(stage, fn)
  local ok, err = pcall(fn)
  if not ok then
    report(stage, err)
  end
end

function M.pre()
  guarded("pre", function()
    require("hypr.omackey.lib.relocate").hook()
  end)
end

function M.init()
  guarded("unhook", function()
    require("hypr.omackey.lib.relocate").unhook()
  end)

  guarded("init", function()
    require("hypr.omackey.init")
  end)
end

-- One-line summary for scripts/check.sh.
function omackey.status()
  local relocate = package.loaded["hypr.omackey.lib.relocate"]
  local bind = package.loaded["hypr.omackey.lib.bind"]
  local parts = {
    "bindings=" .. (bind and #bind.registry or 0),
    "relocated=" .. (relocate and #relocate.applied or 0),
  }

  local unused = relocate and relocate.unused() or {}
  if #unused > 0 then
    table.insert(parts, "unused_relocations=" .. table.concat(unused, ", "))
  end
  if #omackey.errors > 0 then
    table.insert(parts, "errors=" .. table.concat(omackey.errors, " | "))
  end

  return table.concat(parts, " ")
end

-- How often a binding fired since the last reload (automated tests).
function omackey.fired(id)
  local bind = package.loaded["hypr.omackey.lib.bind"]
  local spec = bind and bind.by_id[id]
  return spec and spec.fired or -1
end

-- Run a binding's handler as if its keys were pressed (automated tests):
-- hyprctl repl 'return omackey.trigger("line-start")'
function omackey.trigger(id)
  local bind = package.loaded["hypr.omackey.lib.bind"]
  local spec = bind and bind.by_id[id]
  if not spec then
    return "unknown binding id: " .. tostring(id)
  end

  local result = spec.handler()
  return (result and result.ok == false) and "passed through" or "handled"
end

return M
