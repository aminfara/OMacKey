#!/usr/bin/env bash
# Validate the live Hyprland config after an OMacKey change.
#
#   scripts/check.sh            reload, config errors, OMacKey status, duplicate binds
#   scripts/check.sh <text>     also search Omarchy's keybindings menu for <text>
#
# Exits non-zero when something needs attention.

set -uo pipefail

failed=0

hyprctl reload >/dev/null

errors=$(hyprctl configerrors)
if [[ -n $errors ]]; then
  echo "✗ Hyprland config errors:"
  echo "$errors"
  failed=1
else
  echo "✓ No Hyprland config errors"
fi

status=$(hyprctl repl 'return omackey and omackey.status() or "not loaded"')
if [[ $status == "not loaded" ]]; then
  echo "✗ OMacKey is not loaded (run ./install.sh)"
  failed=1
elif [[ $status == off* ]]; then
  echo "✗ OMacKey is switched off: $status"
  failed=1
elif [[ $status == *errors=* || $status == *unused_relocations=* ]]; then
  echo "✗ OMacKey: $status"
  failed=1
else
  echo "✓ OMacKey: $status"
fi

# Two binds on the same key both fire. Omarchy binds ALT+TAB and ALT+SHIFT+TAB
# twice on purpose (cycle, then bring to top).
allowed_duplicates=$'8 tab\n9 tab'

duplicates=$(
  hyprctl binds | awk -v allowed="$allowed_duplicates" '
    function emit(   key, id) {
      if (!seen) return
      seen = 0
      key = f["key"]
      sub(/^.* \+ /, "", key) # Lua binds may report "SUPER + code:20"
      if (key == "" && f["keycode"] != "0") key = "code:" f["keycode"]
      id = f["submap"] "|" f["modmask"] "|" tolower(key) "|" release
      count[id]++
      what[id] = what[id] (what[id] == "" ? "" : "; ") f["description"]
      label[id] = f["modmask"] " " tolower(key) (f["submap"] == "" ? "" : " [" f["submap"] "]") (release ? " (release)" : "")
      plain[id] = f["modmask"] " " tolower(key)
    }
    BEGIN {
      n = split(allowed, list, "\n")
      for (i = 1; i <= n; i++) ok[list[i]] = 1
    }
    /^bind/ { emit(); seen = 1; delete f; release = (substr($0, 5) ~ /r/); next }
    seen && match($0, /^\t[a-z_]+: /) { f[substr($0, 2, RLENGTH - 3)] = substr($0, RLENGTH + 1) }
    END {
      emit()
      for (id in count)
        if (count[id] > 1 && !(plain[id] in ok))
          printf "  modmask %s: %s\n", label[id], what[id]
    }
  '
)
if [[ -n $duplicates ]]; then
  echo "✗ Keys bound more than once (modmask: SHIFT=1 CTRL=4 ALT=8 SUPER=64):"
  echo "$duplicates"
  failed=1
else
  echo "✓ No duplicate binds"
fi

if [[ -n ${1:-} ]]; then
  echo "Keybindings menu entries matching '$1':"
  omarchy menu keybindings --print | grep -i -- "$1" || echo "  (none)"
fi

exit $failed
