-- Scripted sequences for the stateful features, each run in a freshly loaded
-- config. Keys are pressed by chord, so the scenarios don't depend on how
-- OMacKey names or organizes its bindings.
--
-- S.windows{ … }   set up the world; the first window has focus, the rest
--                   follow in focus-history order
-- S.press(keys)     press a bind (S.release(keys) for its release bind)
-- S.key(code, st)   a raw key event (133 = Super_L, state 0 = released)
-- S.wait(ms)        advance the clock, running due timers
-- S.click(label)    the user focuses a window with the mouse
-- S.close(label)    a window goes away on its own
-- S.at(ms)          advance the clock to ms after the start

local SUPER_L = 133

local function apps(S)
  S.windows({
    { "brave", "brave-origin", ws = 1 },
    { "vscode", "com.microsoft.VSCode", ws = 2 },
    { "foot", "foot", ws = 3, tags = { "terminal*" } },
    { "nautilus", "org.gnome.Nautilus", ws = 4, floating = true },
  })
end

return {
  {
    name = "⌘Tab: tap twice (flip between the last two apps)",
    run = function(S)
      apps(S)
      S.press("SUPER + TAB")
      S.key(SUPER_L, 0)
      S.press("SUPER + TAB")
      S.key(SUPER_L, 0)
    end,
  },
  {
    name = "⌘Tab: three steps while ⌘ is held, then a tap",
    run = function(S)
      apps(S)
      S.press("SUPER + TAB")
      S.press("SUPER + TAB")
      S.press("SUPER + TAB")
      S.key(SUPER_L, 0)
      S.press("SUPER + TAB")
      S.key(SUPER_L, 0)
    end,
  },
  {
    name = "⌘⇧Tab from the front app, twice while held",
    run = function(S)
      apps(S)
      S.press("SUPER + SHIFT + TAB")
      S.press("SUPER + SHIFT + TAB")
      S.key(SUPER_L, 0)
      S.press("SUPER + TAB")
      S.key(SUPER_L, 0)
    end,
  },
  {
    name = "⌘Tab: a click on another app in the middle of a session",
    run = function(S)
      apps(S)
      S.press("SUPER + TAB")
      S.click("nautilus")
      S.press("SUPER + TAB")
      S.key(SUPER_L, 0)
    end,
  },
  {
    name = "⌘Tab: an app closes in the middle of a session",
    run = function(S)
      apps(S)
      S.press("SUPER + TAB")
      S.close("foot")
      S.press("SUPER + TAB")
      S.press("SUPER + TAB")
      S.key(SUPER_L, 0)
    end,
  },
  {
    name = "⌘Tab: clicks before the first press set the recency order",
    run = function(S)
      apps(S)
      S.click("nautilus")
      S.click("foot")
      S.click("brave")
      S.press("SUPER + TAB")
      S.key(SUPER_L, 0)
    end,
  },
  {
    name = "⌘Q: every window of the app, not others",
    run = function(S)
      S.windows({
        { "foot-1", "foot", ws = 1, tags = { "terminal*" } },
        { "brave", "brave-origin", ws = 1 },
        { "foot-2", "foot", ws = 2, tags = { "terminal*" } },
      })
      S.press("SUPER + Q")
    end,
  },
  {
    name = "⌘Q: a window with no class closes alone",
    run = function(S)
      S.windows({
        { "nameless-1", "", ws = 1 },
        { "nameless-2", "", ws = 1 },
      })
      S.press("SUPER + Q")
    end,
  },
  {
    name = "⌘` / ⌘⇧`: the app's windows in a fixed ring, scratchpad left out",
    run = function(S)
      S.windows({
        { "code-b", "com.microsoft.VSCode", ws = 2, stable_id = 30 },
        { "code-a", "com.microsoft.VSCode", ws = 1, stable_id = 10 },
        { "brave", "brave-origin", ws = 1 },
        { "code-c", "com.microsoft.VSCode", ws = 3, stable_id = 20, floating = true },
        { "code-hidden", "com.microsoft.VSCode", special = "scratchpad", stable_id = 5 },
      })
      S.press("SUPER + grave")
      S.press("SUPER + grave")
      S.press("SUPER + grave")
      S.press("SUPER + grave")
      S.press("SUPER + SHIFT + grave")
      S.press("SUPER + SHIFT + grave")
    end,
  },
  {
    name = "⌘-click: press and release with ⌘ held",
    run = function(S)
      S.windows({ { "brave", "brave-origin" } })
      S.press("SUPER + mouse:272")
      S.wait(80)
      S.release("SUPER + mouse:272")
    end,
  },
  {
    name = "⌘-click: ⌘ let go before the button",
    run = function(S)
      S.windows({ { "brave", "brave-origin" } })
      S.press("SUPER + mouse:272")
      S.wait(80)
      S.release("mouse:272")
    end,
  },
  {
    name = "⌘⇧-click: release with ⇧ still held, and with ⌘⇧ held",
    run = function(S)
      S.windows({ { "nautilus", "org.gnome.Nautilus" } })
      S.press("SUPER + SHIFT + mouse:272")
      S.wait(50)
      S.release("SHIFT + mouse:272")
      S.press("SUPER + SHIFT + mouse:272")
      S.wait(50)
      S.release("SUPER + SHIFT + mouse:272")
    end,
  },
  {
    name = "plain click release with nothing pending passes through",
    run = function(S)
      S.windows({ { "brave", "brave-origin" } })
      S.release("mouse:272")
      S.release("SHIFT + mouse:272")
      S.release("SUPER + mouse:272")
    end,
  },
  {
    name = "⌘-scroll: warm-up, held Ctrl, overlapping hold, end of hold",
    run = function(S)
      S.windows({ { "brave", "brave-origin" } })
      for _, at in ipairs({ 0, 30, 80, 250, 500, 1200, 1210, 1300 }) do
        S.at(at)
        S.press("SUPER + mouse_up")
      end
      S.at(1400)
      S.press("SUPER + mouse_down")
    end,
  },
  {
    name = "Mac-mode toggle (⌃⌘⇧M)",
    run = function(S)
      S.windows({ { "keylog", "omackey.keylog" } })
      S.press("CTRL + SUPER + SHIFT + M")
    end,
  },
  {
    name = "F5 dictation: press and release; ⇧F5",
    run = function(S)
      S.windows({ { "keylog", "omackey.keylog" } })
      S.press("XF86VoiceCommand")
      S.wait(500)
      S.release("XF86VoiceCommand")
      S.press("SHIFT + XF86VoiceCommand")
    end,
  },
}
