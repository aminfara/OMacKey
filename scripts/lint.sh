#!/usr/bin/env bash
# Lint pass (docs/ROADMAP.md 8.4). Needs only luac5.5 and bash; luacheck and
# shellcheck run too when they are installed.
#
#   scripts/lint.sh
#
# 1. syntax of every Lua file (luac5.5 -p);
# 2. unknown globals: any global a file reads or writes that is not part of
#    Lua's standard library, OMacKey's own (`hl`, `o`, `omackey`) or `arg`.
#    This catches typos (`tostirng`) and leaked variables (a missing `local`);
# 3. no `print` in omackey/ (stdout at load breaks the help menu, ARCHITECTURE.md §10);
# 4. bash -n on every shell script, and shellcheck if present;
# 5. luacheck if present.
#
# The modules also load under the mock on every scripts/snapshot.sh run.
# Exit status: 0 = clean, 1 = findings.

set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 2

command -v luac5.5 >/dev/null || { echo "lint: luac5.5 not found" >&2; exit 2; }

allowed=" _G _ENV _VERSION arg assert collectgarbage coroutine debug dofile error getmetatable io ipairs load loadfile math next os package pairs pcall print rawequal rawget rawlen rawset require select setmetatable string table tonumber tostring type utf8 warn xpcall hl o omackey "
failed=0
bad() { echo "✗ $*"; failed=1; }

lua_files=$(find omackey scripts tests -name '*.lua' | sort)
sh_files=$( (find scripts tests -name '*.sh'; echo install.sh uninstall.sh; ls scripts/omackey-mode .githooks/* 2>/dev/null) | tr ' ' '\n' | sort -u )

syntax=0
for f in $lua_files; do
  luac5.5 -p "$f" || { bad "syntax: $f"; syntax=1; continue; }
  while read -r name; do
    [[ $allowed == *" $name "* ]] || bad "$f: global '$name' (a typo, or a missing local?)"
  done < <(luac5.5 -l -l "$f" | sed -nE 's/.*(GET|SET)TABUP.*; _ENV "([^"]+)".*/\2/p' | sort -u)
done
((syntax == 0)) && echo "✓ Lua syntax ($(wc -w <<<"$lua_files") files)"

prints=$(grep -rnE '(^|[^.:_[:alnum:]])print\(' omackey --include='*.lua' || true)
if [[ -n $prints ]]; then
  bad "print in omackey/ (no stdout at load):"
  echo "$prints" | sed 's/^/    /'
else
  echo "✓ no print in omackey/"
fi

for f in $sh_files; do
  bash -n "$f" || bad "bash syntax: $f"
done
if command -v shellcheck >/dev/null; then
  # shellcheck disable=SC2086
  shellcheck $sh_files && echo "✓ shellcheck" || failed=1
else
  echo "• shellcheck not installed (skipped)"
fi

if command -v luacheck >/dev/null; then
  luacheck --no-color --globals hl o omackey -- omackey scripts tests && echo "✓ luacheck" || failed=1
else
  echo "• luacheck not installed (skipped)"
fi

((failed == 0)) && echo "✓ lint clean"
exit $failed
