-- The key table: every key OMacKey names, with its physical keycode (XKB
-- keycode = evdev + 8, US positions), how a Mac keyboard labels it (`glyph`)
-- and how a description names it (`label`, the glyph unless it is a symbol).
--
-- Synthetic keys are sent by keycode so a chord like Ctrl+C still reaches the
-- app as Ctrl+C while a non-Latin layout (e.g. Persian) is active.

local M = {
  list = {}, -- key entries in table order: { name, code, kind, glyph, label }
  by_name = {}, -- lowercase name → entry
  by_code = {}, -- keycode → entry
}

local function add(name, code, kind, glyph, label)
  local entry = { name = name, code = code, kind = kind, glyph = glyph, label = label or glyph }
  table.insert(M.list, entry)
  M.by_name[name] = entry
  M.by_code[code] = entry
end

-- Letters and digits, row by row from the keycode of each row's first key.
local function add_row(chars, first, kind)
  for i = 1, #chars do
    local char = chars:sub(i, i)
    add(char, first + i - 1, kind, char:upper())
  end
end

add_row("qwertyuiop", 24, "letter")
add_row("asdfghjkl", 38, "letter")
add_row("zxcvbnm", 52, "letter")
-- Letters A–Z in alphabetical order (the list holds only letters so far).
table.sort(M.list, function(a, b)
  return a.name < b.name
end)

add_row("1234567890", 10, "digit")

add("minus", 20, "punctuation", "-")
add("equal", 21, "punctuation", "=")
add("bracketleft", 34, "punctuation", "[")
add("bracketright", 35, "punctuation", "]")
add("backslash", 51, "punctuation", "\\")
add("semicolon", 47, "punctuation", ";")
add("apostrophe", 48, "punctuation", "'")
add("grave", 49, "punctuation", "`")
add("comma", 59, "punctuation", ",")
add("period", 60, "punctuation", ".")
add("slash", 61, "punctuation", "/")

add("return", 36, "editing", "⏎", "Return")
add("tab", 23, "editing", "⇥", "Tab")
add("space", 65, "editing", "Space")
add("backspace", 22, "editing", "⌫", "Backspace")
add("delete", 119, "editing", "⌦", "Delete")
add("insert", 118, "editing", "Insert")
add("escape", 9, "editing", "Esc")

add("left", 113, "navigation", "←", "Left")
add("right", 114, "navigation", "→", "Right")
add("up", 111, "navigation", "↑", "Up")
add("down", 116, "navigation", "↓", "Down")
add("home", 110, "navigation", "↖", "Home")
add("end", 115, "navigation", "↘", "End")
add("page_up", 112, "navigation", "⇞", "Page Up")
add("page_down", 117, "navigation", "⇟", "Page Down")

for n = 1, 10 do
  add("f" .. n, 66 + n, "function", "F" .. n)
end
add("f11", 95, "function", "F11")
add("f12", 96, "function", "F12")

add("kp_0", 90, "keypad", "Keypad 0")

-- keys.code("Home") → "code:110". Names are case-insensitive.
function M.code(name)
  local entry = M.by_name[string.lower(tostring(name))]
  if not entry then
    error("OMacKey: unknown key name '" .. tostring(name) .. "'", 2)
  end

  return "code:" .. entry.code
end

local MODIFIER_ORDER = { SUPER = 1, CTRL = 2, ALT = 3, SHIFT = 4 }
local MODIFIER_ALIASES = { CONTROL = "CTRL" }
-- Mac glyphs in Apple's order (⌃⌥⇧⌘), as menus and Apple's shortcut pages
-- write them.
local GLYPHS = { { "CTRL", "⌃" }, { "ALT", "⌥" }, { "SHIFT", "⇧" }, { "SUPER", "⌘" } }

-- Splits a key string into its modifiers (a set) and its key as written.
local function parse(keys)
  local modifiers, key = {}, nil

  for part in tostring(keys):gmatch("[^+]+") do
    local trimmed = part:match("^%s*(.-)%s*$")
    local upper = trimmed:upper()
    upper = MODIFIER_ALIASES[upper] or upper

    if MODIFIER_ORDER[upper] then
      modifiers[upper] = true
    else
      key = trimmed
    end
  end

  return modifiers, key
end

local function sorted_modifiers(modifiers)
  local list = {}
  for modifier in pairs(modifiers) do
    table.insert(list, modifier)
  end
  table.sort(list, function(a, b)
    return MODIFIER_ORDER[a] < MODIFIER_ORDER[b]
  end)
  return list
end

-- The table entry for a key as written ("f", "F", "comma", "code:59"), or nil.
local function entry_of(key)
  local lower = key:lower()
  local code = tonumber(lower:match("^code:(%d+)$"))
  if code then
    return M.by_code[code]
  end
  return M.by_name[lower]
end

-- A key string in one form, for comparing chords however they are written:
-- modifiers upper-case in a fixed order, the key lower-case, and a keycode of
-- a key in this table by its name, so "super + code:10" and "SUPER + 1" match.
--   "SUPER + ALT + SHIFT + F", "super + shift + alt + f" → "SUPER + ALT + SHIFT + f"
function M.normalize(keys)
  local modifiers, key = parse(keys)
  key = key and key:lower() or ""

  local entry = entry_of(key)
  if entry then
    key = entry.name
  end

  local parts = sorted_modifiers(modifiers)
  table.insert(parts, key)
  return table.concat(parts, " + ")
end

-- The one way OMacKey writes a key string, so a user's hl.unbind("<string>")
-- can be read off the docs: modifiers in the order SUPER, CTRL, ALT, SHIFT;
-- letters and named keys upper-case as Omarchy writes them; punctuation by
-- its lower-case xkb name (upper-case "COMMA" doesn't match), or by keycode
-- where it is written as one (a relocated Omarchy bind keeps Omarchy's
-- keycode, which stays on the same physical key in any layout); digits by
-- keycode, as Omarchy binds them. A key not in the table (mouse:272,
-- XF86VoiceCommand) stays as written.
--   "CTRL + SUPER + SHIFT + m" → "SUPER + CTRL + SHIFT + M"
--   "SUPER + 1" → "SUPER + code:10",   "SUPER + SLASH" → "SUPER + slash"
function M.canonical(keys)
  local modifiers, key = parse(keys)
  local parts = sorted_modifiers(modifiers)

  if key then
    local entry = entry_of(key)
    if not entry then
      table.insert(parts, key)
    elseif entry.kind == "digit" or (entry.kind == "punctuation" and key:match("^code:")) then
      table.insert(parts, "code:" .. entry.code)
    elseif entry.kind == "punctuation" then
      table.insert(parts, entry.name)
    else
      table.insert(parts, entry.name:upper())
    end
  end

  return table.concat(parts, " + ")
end

-- The Mac form of a key string, modifiers in Apple's order, or nil for a key
-- the table doesn't know (mouse buttons, XF86 keys):
--   "SUPER + SHIFT + bracketleft" → "⇧⌘[",   "SUPER + ALT + ESCAPE" → "⌥⌘Esc"
function M.glyph(keys)
  if keys == nil then
    return nil
  end

  local modifiers, key = parse(keys)
  local entry = key and entry_of(key)
  if not entry then
    return nil
  end

  local text = ""
  for _, pair in ipairs(GLYPHS) do
    if modifiers[pair[1]] then
      text = text .. pair[2]
    end
  end
  return text .. entry.glyph
end

return M
