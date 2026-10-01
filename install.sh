#!/usr/bin/env bash
# Install OMacKey into Omarchy's Hyprland config:
#   - link this repo's omackey/ to ~/.config/hypr/omackey
#   - add two guarded loader blocks around require("default.hypr.omarchy") in
#     ~/.config/hypr/hyprland.lua (backed up first)
#   - reload Hyprland and run scripts/check.sh
#
# Usage: ./install.sh [--no-reload]
# Safe to run again; uninstall with ./uninstall.sh.

set -euo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Omarchy's bootstrap.lua resolves user modules from $HOME/.config, not $XDG_CONFIG_HOME.
hypr="$HOME/.config/hypr"
link="$hypr/omackey"
conf="$hypr/hyprland.lua"
anchor='^[[:space:]]*require\("default\.hypr\.omarchy"\)[[:space:]]*$'

reload=1
[[ ${1:-} == "--no-reload" ]] && reload=0

die() {
  echo "OMacKey install: $*" >&2
  exit 1
}

[[ -f $conf ]] || die "$conf not found (OMacKey needs Omarchy's Lua Hyprland config)."

anchors=$(grep -cE "$anchor" "$conf" || true)
[[ $anchors == 1 ]] || die "expected exactly one require(\"default.hypr.omarchy\") line in $conf, found $anchors."

if [[ -L $link ]]; then
  ln -sfn "$repo/omackey" "$link"
elif [[ -e $link ]]; then
  die "$link exists and is not a symlink; move it away first."
else
  ln -s "$repo/omackey" "$link"
fi
echo "Linked $link -> $repo/omackey"

if grep -q '^-- >>> OMacKey' "$conf"; then
  echo "Loader lines already present in $conf"
else
  backup="$conf.bak.omackey.$(date +%Y%m%d%H%M%S)"
  cp "$conf" "$backup"

  # The regex goes through the environment: awk -v would eat its backslashes.
  ANCHOR="$anchor" awk '
    $0 ~ ENVIRON["ANCHOR"] {
      print "-- >>> OMacKey pre (managed by OMacKey install.sh)"
      print "do local ok, loader = pcall(require, \"hypr.omackey.load\"); if ok then loader.pre() end end"
      print "-- <<< OMacKey pre"
      print
      print "-- >>> OMacKey (managed by OMacKey install.sh)"
      print "do local ok, loader = pcall(require, \"hypr.omackey.load\"); if ok then loader.init() end end"
      print "-- <<< OMacKey"
      next
    }
    { print }
  ' "$backup" >"$conf"

  if [[ $(grep -c '^-- >>> OMacKey' "$conf") != 2 ]]; then
    cp "$backup" "$conf"
    die "could not add the loader lines; $conf restored from backup."
  fi

  echo "Added loader lines to $conf (backup: $backup)"
fi

if ((reload)); then
  "$repo/scripts/check.sh"
fi
