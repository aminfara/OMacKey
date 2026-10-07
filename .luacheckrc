-- luacheck configuration (scripts/lint.sh). Hyprland and Omarchy's helpers are
-- globals only inside the config, never in scripts or tests.
std = "lua54"
max_line_length = 120
globals = { "hl", "o", "omackey" }
