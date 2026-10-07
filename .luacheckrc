-- luacheck configuration (scripts/lint.sh). Hyprland and Omarchy's helpers are
-- globals only inside the config, never in scripts or tests.
-- luacheck has no Lua 5.5 standard; 5.4 is the closest.
std = "lua54"
max_line_length = 120
globals = { "hl", "o", "omackey" }
