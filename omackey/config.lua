-- OMacKey settings. See PLAN.md for what each phase adds.

return {
  -- Feature modules loaded after Omarchy's defaults, in this order
  -- (omackey/<name>.lua). Each phase appends its module here.
  modules = {
    "spaces", -- Phase 1b: workspaces on ⌃ (vertical pair, move window)
    "text", -- Phase 2: cursor movement, selection, deletion
    "editing", -- Phase 3: clipboard, undo/redo, find, save
  },

  -- How long a synthetic key stays down before its release is sent.
  -- Spike S2 tunes this (Omarchy uses 50 ms, the r/omarchy snippet 5 ms).
  release_ms = 20,

  -- App profiles, checked in order against the active window; the first match
  -- wins. When a binding has no action for a profile, its `family` is tried
  -- next, then "default". Tags are Omarchy's (default/hypr/apps/*.lua).
  profiles = {
    { name = "terminal", tags = { "terminal" } },
    {
      name = "browser",
      tags = { "chromium-based-browser", "firefox-based-browser" },
      -- Omarchy's browser tag regex does not cover Brave Origin.
      classes = { "brave-origin" },
    },
  },
}
