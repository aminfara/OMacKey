#!/usr/bin/env bash
# Drift check after `omarchy update` (docs/TESTING.md §1): shows how Omarchy's
# own bindings differ from the ones tests/snapshot/expected was recorded
# against, and which new or changed ones sit on a key OMacKey uses.
#
#   scripts/drift.sh
#
# It renders Omarchy's defaults alone (the "mode-off" variant, no OMacKey
# shortcuts) under the snapshot's fake Hyprland and compares them with
# expected/binds-mode-off.txt. Hyprland need not run.
#
# Exit status: 0 = no drift, 1 = Omarchy's binds changed, 2 = the check failed.

set -uo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
harness="$repo/tests/snapshot"
expected="$harness/expected"
omarchy="${OMARCHY_PATH:-/usr/share/omarchy}"

die() {
  echo "drift: $*" >&2
  exit 2
}

command -v lua5.5 >/dev/null || die "lua5.5 not found"
[[ -f $omarchy/default/hypr/bootstrap.lua ]] || die "Omarchy not found in $omarchy"
[[ -f $expected/binds-mode-off.txt && -f $expected/binds-main.txt ]] || die "no tests/snapshot/expected yet"

scratch="$(mktemp -d)"
trap 'rm -rf "$scratch"' EXIT

dir="$scratch/variant"
mkdir -p "$dir/state/omackey" "$dir/config" "$scratch/out"
cp -r "$repo/omackey" "$dir/omackey"
touch "$dir/state/omackey/off"
SNAPSHOT_TREE="$dir" SNAPSHOT_VARIANT=mode-off SNAPSHOT_OUT="$scratch/out" \
  XDG_STATE_HOME="$dir/state" XDG_CONFIG_HOME="$dir/config" \
  lua5.5 "$harness/render.lua" || die "render failed"

old="$expected/binds-mode-off.txt"
sort "$old" >"$scratch/old.sorted"
sort "$scratch/out/binds-mode-off.txt" >"$scratch/new.sorted"
comm -23 "$scratch/old.sorted" "$scratch/new.sorted" >"$scratch/gone"
comm -13 "$scratch/old.sorted" "$scratch/new.sorted" >"$scratch/added"

if [[ ! -s $scratch/gone && ! -s $scratch/added ]]; then
  echo "✓ drift: Omarchy's bindings match tests/snapshot/expected ($(wc -l <"$old") binds)"
  exit 0
fi

# Lines are: <chord> "<description>"  {<flags>}  <dispatcher>. A chord can have
# several lines (Omarchy binds ALT+TAB twice), so lines are compared whole and
# grouped by chord. "OMacKey uses this key" is whatever expected/binds-main.txt
# (the full OMacKey config) has on that chord: a shortcut, a relocated Omarchy
# bind or a catch-all key.
echo "✗ drift: Omarchy's bindings differ from tests/snapshot/expected"
awk -v main="$expected/binds-main.txt" -v goneFile="$scratch/gone" -v addedFile="$scratch/added" '
  function chord(line) { return substr(line, 1, index(line, " ") - 1) }
  function desc(line,   s) {
    s = substr(line, index(line, "\""))
    sub(/"  .*$/, "\"", s)
    return s
  }
  function show(mark, text, c) {
    printf "  %s %s\n%s", mark, c, text
    if (c in mine) printf "      OMacKey uses this key: %s\n", mine[c]
  }
  BEGIN {
    while ((getline line < main) > 0) {
      c = chord(line)
      mine[c] = mine[c] (mine[c] == "" ? "" : ", ") desc(line)
    }
    while ((getline line < goneFile) > 0) { c = chord(line); g[c] = g[c] "      was: " line "\n" }
    while ((getline line < addedFile) > 0) { c = chord(line); a[c] = a[c] "      now: " line "\n" }
    for (c in a) { if (c in g) { both[c] = g[c] a[c]; nc++ } else { na++ } }
    for (c in g) if (!(c in a)) nr++
    if (na) { printf "\nNew in Omarchy (%d):\n", na; for (c in a) if (!(c in g)) show("+", a[c], c) }
    if (nc) { printf "\nChanged in Omarchy (%d):\n", nc; for (c in both) show("~", both[c], c) }
    if (nr) { printf "\nGone from Omarchy (%d):\n", nr; for (c in g) if (!(c in a)) show("-", g[c], c) }
  }
' </dev/null

cat <<'EOF'

Next:
  - A new or changed bind on a key marked "OMacKey uses this key" needs a
    relocation row (docs/ARCHITECTURE.md §11) or a LIMITATIONS.md entry.
  - Relocation rows whose Omarchy key is gone show up in omackey.status() as
    unused_relocations (scripts/check.sh).
  - scripts/snapshot.sh --against <last good commit> shows what the update did
    to OMacKey; scripts/snapshot.sh --update records the new baseline.
EOF
exit 1
