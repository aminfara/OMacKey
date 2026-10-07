#!/usr/bin/env bash
# Behaviour snapshot of OMacKey (docs/TESTING.md). Loads Omarchy's defaults plus
# an OMacKey tree under a fake Hyprland (tests/snapshot/mock.lua), presses every
# bind in every test app and writes down what it does; then compares that with
# the expected output. Needs lua5.5 and Omarchy's files; Hyprland need not run.
#
#   scripts/snapshot.sh                 compare the working tree with tests/snapshot/expected
#   scripts/snapshot.sh --update        rewrite tests/snapshot/expected from the working tree
#   scripts/snapshot.sh --against REV   compare with REV's omackey/ instead of expected/
#   scripts/snapshot.sh --tree DIR      test DIR/omackey instead of the working tree
#   scripts/snapshot.sh --out DIR       also keep the rendered files in DIR
#   scripts/snapshot.sh --live          compare the main variant's binds with live `hyprctl binds`
#
# Exit status: 0 = the frozen files match (differences in the reported files
# are shown but allowed), 1 = the frozen files differ, 2 = the harness failed.

set -uo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
harness="$repo/tests/snapshot"
expected="$harness/expected"
omarchy="${OMARCHY_PATH:-/usr/share/omarchy}"

variants=(main bare emacs-off mode-off no-preinstalls)
frozen=(binds behaviour load scenarios)
reported=(metadata order strings)

mode=compare
against=""
tree="$repo"
keep=""

die() {
  echo "snapshot: $*" >&2
  exit 2
}

while (($#)); do
  case "$1" in
    --update) mode=update ;;
    --live) mode=live ;;
    --against) against="${2:?--against needs a revision}"; shift ;;
    --tree) tree="$(cd "${2:?--tree needs a directory}" 2>/dev/null && pwd)" || die "no such directory: $2"; shift ;;
    --out) keep="${2:?--out needs a directory}"; shift ;;
    -h | --help) sed -n '2,16p' "$0"; exit 0 ;;
    *) die "unknown argument: $1" ;;
  esac
  shift
done

command -v lua5.5 >/dev/null || die "lua5.5 not found"
[[ -f $omarchy/default/hypr/bootstrap.lua ]] || die "Omarchy not found in $omarchy"
[[ -d $tree/omackey ]] || die "no omackey/ in $tree"

scratch="$(mktemp -d)"
trap 'rm -rf "$scratch"' EXIT

# Fingerprint of the Omarchy files the snapshot depends on: when it changes,
# expected/ was made against another Omarchy and a plain compare would mislead.
omarchy_hash() {
  (cd "$omarchy/default/hypr" && cat bootstrap.lua helpers.lua omarchy.lua bindings/*.lua) | sha256sum | cut -d' ' -f1
}

# render <tree-root> <out-dir>: every variant of <tree-root>/omackey into <out-dir>.
render() {
  local root="$1" out="$2" variant dir
  mkdir -p "$out"
  for variant in "${variants[@]}"; do
    dir="$scratch/variant-$(basename "$out")-$variant"
    mkdir -p "$dir/state" "$dir/config"
    cp -r "$root/omackey" "$dir/omackey"

    case "$variant" in
      emacs-off)
        if [[ -f $dir/omackey/settings.lua ]]; then
          mkdir -p "$dir/config/omackey"
          echo 'return { emacs_keys = false }' >"$dir/config/omackey/settings.lua"
        elif grep -q 'emacs_keys = true' "$dir/omackey/config.lua" 2>/dev/null; then
          sed -i 's/emacs_keys = true/emacs_keys = false/' "$dir/omackey/config.lua"
        else
          die "emacs-off: no way to turn the Emacs keys off in $root/omackey"
        fi
        ;;
      mode-off)
        mkdir -p "$dir/state/omackey"
        touch "$dir/state/omackey/off"
        ;;
    esac

    SNAPSHOT_TREE="$dir" SNAPSHOT_VARIANT="$variant" SNAPSHOT_OUT="$out" \
      XDG_STATE_HOME="$dir/state" XDG_CONFIG_HOME="$dir/config" \
      lua5.5 "$harness/render.lua" || die "render failed for variant $variant of $root"
  done
  omarchy_hash >"$out/omarchy.sha256"
}

current="$scratch/current"
render "$tree" "$current"
[[ -n $keep ]] && mkdir -p "$keep" && cp "$current"/* "$keep"/

if [[ $mode == update ]]; then
  rm -rf "$expected"
  mkdir -p "$expected"
  cp "$current"/* "$expected"/
  echo "snapshot: wrote $(find "$expected" -type f | wc -l) files to tests/snapshot/expected"
  exit 0
fi

if [[ $mode == live ]]; then
  command -v hyprctl >/dev/null || die "hyprctl not found"
  hyprctl binds | lua5.5 "$harness/live.lua" | sort >"$scratch/live.txt" || die "cannot read the live binds"
  sed -E 's/^(.*")  .*$/\1/' "$current/binds-main.txt" | sort >"$scratch/mock.txt"
  if diff -u --label "snapshot (main variant)" --label "live hyprctl binds" "$scratch/mock.txt" "$scratch/live.txt"; then
    echo "snapshot: the main variant matches the live binds"
    exit 0
  fi
  echo "snapshot: differences above (lines only in the live config come from your own files, e.g. hypr.bindings)"
  exit 1
fi

if [[ -n $against ]]; then
  base="$scratch/base"
  mkdir -p "$base/tree"
  git -C "$repo" archive "$against" omackey | tar -x -C "$base/tree" || die "cannot read omackey/ at $against"
  render "$base/tree" "$base/out"
  baseline="$base/out"
  label="$against"
else
  [[ -d $expected ]] || die "no tests/snapshot/expected yet (run with --update)"
  if [[ $(cat "$expected/omarchy.sha256" 2>/dev/null) != $(omarchy_hash) ]]; then
    die "Omarchy's files changed since tests/snapshot/expected was made; run scripts/drift.sh to see what changed, then compare with --against <rev>"
  fi
  baseline="$expected"
  label="expected"
fi

status=0
for name in "${frozen[@]}" "${reported[@]}"; do
  for variant in "${variants[@]}"; do
    file="$name-$variant.txt"
    if ! diff -u --label "$label/$file" --label "current/$file" "$baseline/$file" "$current/$file" >"$scratch/diff"; then
      if [[ " ${frozen[*]} " == *" $name "* ]]; then
        echo "✗ $file differs (frozen):"
        status=1
      else
        echo "• $file differs (reported: allowed, review it before --update):"
      fi
      cat "$scratch/diff"
    fi
  done
done

if ((status == 0)); then
  echo "✓ snapshot: frozen behaviour unchanged (${#variants[@]} variants, compared with $label)"
fi
exit $status
