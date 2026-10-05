-- Key names → physical keycodes ("code:N", XKB keycode = evdev + 8, US
-- positions). Synthetic keys are sent by keycode so a chord like Ctrl+C still
-- reaches the app as Ctrl+C while a non-Latin layout (e.g. Persian) is active.

local codes = {
  escape = 9,
  minus = 20,
  equal = 21,
  backspace = 22,
  tab = 23,
  bracketleft = 34,
  bracketright = 35,
  ["return"] = 36,
  semicolon = 47,
  apostrophe = 48,
  grave = 49,
  backslash = 51,
  comma = 59,
  period = 60,
  slash = 61,
  space = 65,
  f11 = 95,
  f12 = 96,
  kp_0 = 90, -- numpad 0
  home = 110,
  up = 111,
  page_up = 112,
  left = 113,
  right = 114,
  ["end"] = 115,
  down = 116,
  page_down = 117,
  insert = 118,
  delete = 119,
}

-- Rows of the US layout, each starting at the keycode of its first key.
local rows = {
  { "1234567890", 10 },
  { "qwertyuiop", 24 },
  { "asdfghjkl", 38 },
  { "zxcvbnm", 52 },
}

for _, row in ipairs(rows) do
  local chars, first = row[1], row[2]
  for i = 1, #chars do
    codes[chars:sub(i, i)] = first + i - 1
  end
end

for n = 1, 10 do
  codes["f" .. n] = 66 + n
end

local M = { codes = codes }

-- keys.code("Home") → "code:110". Names are case-insensitive.
function M.code(name)
  local code = codes[string.lower(tostring(name))]
  if not code then
    error("OMacKey: unknown key name '" .. tostring(name) .. "'", 2)
  end

  return "code:" .. code
end

return M
