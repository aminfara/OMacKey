-- Actions that describe themselves. A shortcut's action is something to run
-- (a function, a Hyprland dispatcher) or one of two fixed answers (PASS,
-- CONSUME); every one of them also carries a text saying what it does, which
-- bind.build() requires and the catalog and omackey.explain() show.
--
--   does("Close every window of the app", windows.quit_app)
--   does("Lock the screen", hl.dsp.exec_cmd("omarchy-system-lock"))
--
-- A described function is a callable table, so it runs like the function
-- (arguments and results pass through, including { ok = false } to let the
-- key through). A described dispatcher is a table holding the dispatcher;
-- unwrap() gives it back, so it is still bound natively.

local M = {}

M.PASS = "pass"
M.CONSUME = "consume"

local STANDARD_TEXTS = {
  [M.PASS] = "Nothing: the key reaches the app unchanged",
  [M.CONSUME] = "Nothing: the key does nothing",
}

local CALLABLE = {
  __call = function(self, ...)
    return self.fn(...)
  end,
}

local DESCRIBED = {} -- metatable of a described dispatcher

-- does(text, action) → the action with its text. The text is one short line,
-- e.g. "Ctrl+Shift+F" or "Delete the word before the cursor".
function M.does(text, action)
  if type(text) ~= "string" or text == "" then
    error("OMacKey: does() needs a text as its first argument", 2)
  end

  if type(action) == "function" then
    return setmetatable({ text = text, fn = action }, CALLABLE)
  elseif action == M.PASS or action == M.CONSUME or action == nil then
    error("OMacKey: does() describes a function or a dispatcher", 2)
  end
  return setmetatable({ text = text, dispatcher = action }, DESCRIBED)
end

-- The dispatcher inside a described dispatcher; anything else comes back as it is.
function M.unwrap(action)
  if getmetatable(action) == DESCRIBED then
    return action.dispatcher
  end
  return action
end

-- The text of an action, or nil when it has none.
function M.text_of(action)
  if action == M.PASS or action == M.CONSUME then
    return STANDARD_TEXTS[action]
  end

  local meta = type(action) == "table" and getmetatable(action)
  if meta == CALLABLE or meta == DESCRIBED then
    return action.text
  end
end

return M
