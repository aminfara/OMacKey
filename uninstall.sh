#!/usr/bin/env bash
# Remove OMacKey: delete its loader blocks from ~/.config/hypr/hyprland.lua
# (backed up first), remove the ~/.config/hypr/omackey symlink, reload.
#
# Usage: ./uninstall.sh [--no-reload]

set -euo pipefail

hypr="$HOME/.config/hypr"
link="$hypr/omackey"
conf="$hypr/hyprland.lua"

reload=1
[[ ${1:-} == "--no-reload" ]] && reload=0

if [[ -f $conf ]] && grep -q '^-- >>> OMacKey' "$conf"; then
  backup="$conf.bak.omackey.$(date +%Y%m%d%H%M%S)"
  cp "$conf" "$backup"

  awk '
    /^-- >>> OMacKey/ { skip = 1; next }
    /^-- <<< OMacKey/ { skip = 0; next }
    !skip { print }
  ' "$backup" >"$conf"

  echo "Removed loader lines from $conf (backup: $backup)"
else
  echo "No OMacKey loader lines in $conf"
fi

if [[ -L $link ]]; then
  rm "$link"
  echo "Removed $link"
elif [[ -e $link ]]; then
  echo "Left $link in place: it is not a symlink created by install.sh" >&2
fi

if ((reload)) && command -v hyprctl >/dev/null; then
  hyprctl reload >/dev/null
  errors=$(hyprctl configerrors)
  [[ -z $errors ]] && echo "Reloaded Hyprland: no config errors" || echo "$errors"
fi
