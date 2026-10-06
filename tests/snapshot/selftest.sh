#!/usr/bin/env bash
# Proves the snapshot can see a change: each case edits a scratch copy of
# omackey/ and checks the exit status of scripts/snapshot.sh against it. Also
# checks that two renders of the same tree are byte-identical.
#
# Usage: tests/snapshot/selftest.sh      (takes about two minutes)
#
# The edits find their target by a text pattern. When a refactoring phase moves
# or rewrites that text, the case reports "pattern not found": update the case
# so it still makes the same kind of change.

set -uo pipefail

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
snapshot="$repo/scripts/snapshot.sh"
scratch="$(mktemp -d)"
trap 'rm -rf "$scratch"' EXIT

failures=0

# first_file <fixed text>: the first omackey/ file containing it.
first_file() {
  grep -rlF -- "$1" "$scratch/tree/omackey" | sort | head -1
}

# check <name> <expected exit> <pattern> <edit>: copy the tree, set $file to the
# file holding <pattern>, run the <edit> function on it, then the snapshot.
check() {
  local name="$1" want="$2" pattern="$3" edit="$4"
  rm -rf "$scratch/tree"
  mkdir -p "$scratch/tree"
  cp -r "$repo/omackey" "$scratch/tree/omackey"

  file="$(first_file "$pattern")"
  if [[ -z $file ]]; then
    echo "✗ $name: pattern not found: $pattern"
    failures=$((failures + 1))
    return
  fi
  cp "$file" "$scratch/before"
  "$edit"
  if cmp -s "$file" "$scratch/before"; then
    echo "✗ $name: the edit changed nothing in ${file#"$scratch/tree/"}"
    failures=$((failures + 1))
    return
  fi

  "$snapshot" --tree "$scratch/tree" >"$scratch/log" 2>&1
  local got=$?
  if [[ $got == "$want" ]]; then
    echo "✓ $name (exit $got)"
  else
    echo "✗ $name: snapshot exited $got, expected $want"
    tail -5 "$scratch/log" | sed 's/^/    /'
    failures=$((failures + 1))
  fi
}

# The edits. Each changes "$file", the first file holding the case's pattern.
tap_modifier() { sed -i '0,/tap("CTRL", "Home")/s//tap("ALT", "Home")/' "$file"; }
delete_app_entry() { sed -i '/tap("CTRL + SHIFT", "R")/d' "$file"; }
release_ms() { sed -i 's/release_ms = 20/release_ms = 25/' "$file"; }
match_order() { sed -i -e '/{ name = "firefox", family = "browser"/{h;d}' -e '/{ name = "nautilus"/G' "$file"; }
broken_relocation() { sed -i 's/from = "SUPER + J", to/from = "SUPER + JJ", to/' "$file"; }
print_at_load() { sed -i '1i print("snapshot selftest")' "$file"; }
action_typo() { sed -i '0,/terminal = CONSUME/s//terminal = "consme"/' "$file"; }
rename_local() { sed -i 's/\bpending\b/pending_timers/g' "$file"; }

check "a changed tap modifier" 1 'tap("CTRL", "Home")' tap_modifier
check "a deleted app entry (foot's ⌘F)" 1 'tap("CTRL + SHIFT", "R")' delete_app_entry
check "release_ms changed" 1 'release_ms = 20' release_ms
check "app match order (Firefox after the generic browser)" 1 '{ name = "firefox", family = "browser"' match_order
check "a broken relocation row" 1 'from = "SUPER + J", to' broken_relocation
check "a print at load" 1 'from = "SUPER + J", to' print_at_load
check "an action string typo" 1 'terminal = CONSUME' action_typo
check "a local variable renamed (no behaviour change)" 0 'local pending = {}' rename_local

# Determinism: two renders of the working tree are identical.
"$snapshot" --out "$scratch/run1" >/dev/null 2>&1
"$snapshot" --out "$scratch/run2" >/dev/null 2>&1
if [[ -n $(ls "$scratch/run1" 2>/dev/null) ]] && diff -r "$scratch/run1" "$scratch/run2" >/dev/null; then
  echo "✓ two renders are byte-identical"
else
  echo "✗ two renders differ (or none was written)"
  failures=$((failures + 1))
fi

if ((failures)); then
  echo "selftest: $failures case(s) failed"
  exit 1
fi
echo "selftest: all cases passed"
