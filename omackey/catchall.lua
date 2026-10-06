-- The catch-all (PLAN.md §5). Every ⌘ / ⌘⇧ + letter, punctuation or Return key
-- that no other module and no Omarchy default claimed sends Ctrl / Ctrl+Shift +
-- the same key, so a Mac shortcut that has no entry of its own still does what
-- it does on the Mac. Terminals consume them (D5).
--
-- Keep this module last in config.modules: it reads the registry and the keys
-- Omarchy registered (lib/relocate.lua), then fills the gaps. A key you rebind
-- in ~/.config/hypr/bindings.lua still wins, since that file loads later.

local bind = require("hypr.omackey.lib.bind")
local keys = require("hypr.omackey.lib.keys")
local relocate = require("hypr.omackey.lib.relocate")
local tap = require("hypr.omackey.lib.send").tap

-- The keys covered, in key-table order: A–Z, the punctuation keys, Return.
local covered_keys = {}
for _, key in ipairs(keys.list) do
  if key.kind == "letter" or key.kind == "punctuation" or key.name == "return" then
    table.insert(covered_keys, key)
  end
end

-- Consumed everywhere: nothing is sent.
--   ⌘H, ⌘M: no hide or minimize on Omarchy (D13), and Ctrl+H / Ctrl+M are
--           browser history and Enter in a terminal.
--   ⌘⇧Q:    Ctrl+Shift+Q quits Chrome.
--   ⌘⇧I:    Ctrl+Shift+I is Format Document in VS Code; DevTools has ⌘⌥I.
--   ⌘⇧U:    Ctrl+Shift+U starts Unicode input in GTK and fcitx5.
--   ⌘⇧H:    Ctrl+Shift+H is not Chrome's home page (user's choice).
local consumed = {
  ["SUPER + h"] = true,
  ["SUPER + m"] = true,
  ["SUPER + SHIFT + q"] = true,
  ["SUPER + SHIFT + i"] = true,
  ["SUPER + SHIFT + u"] = true,
  ["SUPER + SHIFT + h"] = true,
}

local variants = {
  { keys = "SUPER", ctrl = "CTRL", glyph = "⌘", text = "Ctrl+" },
  { keys = "SUPER + SHIFT", ctrl = "CTRL + SHIFT", glyph = "⌘⇧", text = "Ctrl+Shift+" },
}

-- Normalized chord → { variant, key } for every chord this module covers.
local covered = {}
for _, variant in ipairs(variants) do
  for _, key in ipairs(covered_keys) do
    covered[keys.normalize(variant.keys .. " + " .. key.name)] = { variant = variant, key = key }
  end
end

local taken = {}
for key in pairs(relocate.claimed) do
  taken[key] = true
end

-- A key another module claimed for some apps only (⌘K and ⌘D in terminals, ⌘Y in
-- browsers) has no action elsewhere, so the raw ⌘ chord would reach the app. Give
-- it the catch-all's default outside its own profiles.
for _, spec in ipairs(bind.registry) do
  local chord = keys.normalize(spec.keys)
  taken[chord] = true

  local target = covered[chord]
  if target and spec.actions and spec.actions.default == nil then
    spec.actions.default = consumed[chord] and "consume" or tap(target.variant.ctrl, target.key.name)
    if spec.actions.terminal == nil then
      spec.actions.terminal = "consume"
    end
  end
end

for _, variant in ipairs(variants) do
  for _, key in ipairs(covered_keys) do
    local name = key.name
    local chord = variant.keys .. " + " .. name

    if not taken[keys.normalize(chord)] then
      local desc = variant.glyph .. key.glyph .. " sent as " .. variant.text .. key.label
      local default = tap(variant.ctrl, name)
      if consumed[keys.normalize(chord)] then
        desc = variant.glyph .. key.glyph .. " not mapped"
        default = "consume"
      end

      bind.mac({
        id = "catchall-" .. variant.glyph .. name,
        category = "Catch-all",
        mac = variant.glyph .. key.glyph,
        keys = chord,
        desc = desc,
        actions = {
          default = default,
          terminal = "consume",
        },
      })
    end
  end
end
