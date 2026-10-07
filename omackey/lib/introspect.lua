-- Introspection helpers on the global `omackey` table (created by load.lua),
-- for scripts and tests:
--
--   hyprctl repl 'return omackey.status()'            one-line summary (scripts/check.sh)
--   hyprctl repl 'return omackey.fired("find")'       presses since the last reload
--   hyprctl repl 'return omackey.trigger("find")'     run a bind's handler as if pressed
--   hyprctl repl 'return omackey.explain("find")'     what the key does, per app
--
-- They read the modules that are loaded now (package.loaded) and never load
-- any, so they work, and say so, when OMacKey failed to load or is off.

local M = {}

function M.install(omackey)
  -- One-line summary for scripts/check.sh.
  function omackey.status()
    if omackey.off then
      return "off (Omarchy defaults; toggle: ⌃⇧⌘M or scripts/omackey-mode on)"
    end

    local relocate = package.loaded["hypr.omackey.lib.relocate"]
    local bind = package.loaded["hypr.omackey.lib.bind"]
    local parts = {
      "bindings=" .. (bind and #bind.bound or 0),
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

  -- How often a binding fired since the last reload (automated tests). Bindings
  -- with a dispatcher action are bound natively and not counted (-1).
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

    if not spec.bound then
      return "not bound: " .. tostring(id)
    end

    if not spec.handler then
      hl.dispatch(require("hypr.omackey.lib.action").unwrap(spec.action))
      return "dispatched"
    end

    local result = spec.handler()
    return (result and result.ok == false) and "passed through" or "handled"
  end

  -- What a key does: its chord, then its action in a generic app and in every
  -- app that differs, as text.
  --   hyprctl repl 'return omackey.explain("find-next")'
  function omackey.explain(id)
    local bind = package.loaded["hypr.omackey.lib.bind"]
    if not (bind and bind.by_id[id]) then
      return "unknown binding id: " .. tostring(id)
    end

    local row = require("hypr.omackey.lib.catalog").find(id)
    local lines = {
      string.format("%s  %s  %s  \"%s\"", row.id, row.mac or "", row.keys, row.desc),
    }
    if not row.bound then
      table.insert(lines, "  not bound" .. (row.condition and (": " .. row.condition) or ""))
    end

    if row.action then
      table.insert(lines, "  everywhere: " .. row.action)
    else
      table.insert(lines, "  default: " .. (row.default or "the raw key passes through"))
      local names = {}
      for name in pairs(row.apps) do
        table.insert(names, name)
      end
      table.sort(names)
      for _, name in ipairs(names) do
        table.insert(lines, "  " .. name .. ": " .. row.apps[name])
      end
    end

    return table.concat(lines, "\n")
  end
end

return M
