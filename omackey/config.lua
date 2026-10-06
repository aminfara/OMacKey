-- OMacKey settings.

return {
  -- Modules that declare the Mac shortcuts (omackey/<name>.lua), loaded in
  -- this order after Omarchy's defaults; they are bound in the same order.
  modules = {
    "spaces", -- workspaces on ⌃ (vertical pair, move window)
    "text", -- cursor movement, selection, deletion
    "editing", -- clipboard, undo/redo, find, save
    "windows", -- window and tab controls
    "system", -- OS controls (lock, screenshots, emoji)
    "mouse", -- ⌘-click and ⌘-scroll as Ctrl-click and Ctrl-scroll (scroll needs wtype)
    "emacs", -- Emacs ⌃ keys (bound only when emacs_keys is true)
    "catchall", -- every ⌘ / ⌘⇧ key nothing else claims
  },

  -- Emacs keys: Mac text-field editing keys on physical ⌃ — ⌃A / ⌃E line start /
  -- end, ⌃F / ⌃B / ⌃N / ⌃P arrows, ⌃D / ⌃H delete, ⌃K kill to line end. Terminals
  -- keep the raw key, and so does ⌃D in VS Code. They take ⌃A, ⌃F, ⌃H … away from
  -- GUI apps (select all, find, history): set this to false to get those back.
  -- The default is on at the user's request; reload after changing it.
  emacs_keys = true,

  -- How long a synthetic key stays down before its release is sent.
  -- (Omarchy uses 50 ms, the r/omarchy snippet 5 ms.)
  release_ms = 20,
}
