-- Omarchy default binds moved off keys that macOS needs (PLAN.md §6).
--
-- `from` is Omarchy's key as written in
-- /usr/share/omarchy/default/hypr/bindings/*.lua (matching ignores modifier
-- order and case); `to` is the new key. Omarchy's action, description and
-- conditions are kept as they are.

return {
  -- §6.1 Window management → ⌃⌥ (Phase 1a; LEFT moved early in Phase 0.6)
  { from = "SUPER + LEFT", to = "CTRL + ALT + LEFT" }, -- Focus on left window
}
