#!/usr/bin/env bash
# Checks the kit and the scaffold script: ./tests/run.sh
set -euo pipefail
here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)
scaffold="$here/../skills/new-project/scripts/scaffold.sh"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
fail=0
ok()  { echo "ok   $1"; }
bad() { echo "FAIL $1"; fail=1; }
check() { if "${@:2}" >/dev/null 2>&1; then ok "$1"; else bad "$1"; fi; }

repo="$tmp/repo"
bash "$scaffold" "$repo" >/dev/null

# 1. From zero files to every documentation file.
for f in CLAUDE.md CONTRIBUTING.md README.md .env.example .gitignore .editorconfig \
  docs/PLAN.md docs/STATUS.md docs/ARCHITECTURE.md docs/GLOSSARY.md docs/README.md \
  docs/decisions/README.md docs/decisions/0001-record-decisions.md docs/decisions/_template.md \
  docs/handover/README.md docs/plans/_template.md docs/tasks/_template.md \
  docs/agents/issue-tracker.md docs/agents/domain.md \
  .claude/settings.json .claude/protected-paths .claude/hooks/protect-files.sh \
  .claude/agents/code-reviewer.md .github/workflows/ci.yml; do
  check "kit has $f" test -f "$repo/$f"
done
check "no dot- prefix left" bash -c "! find '$repo' -name 'dot-*' | grep -q ."
check "the kit copies no skills (they come from the plugin)" test ! -e "$repo/.claude/skills"

# The plugin holds every skill of the cycle, each with a name that matches its folder.
for skill in new-project start-session replan plan adr write-prompt end-session; do
  check "plugin has the skill $skill" grep -qx "name: $skill" "$here/../skills/$skill/SKILL.md"
done
check "no skill the kit's documents name is missing" bash -c '
  cd "$1/.." && for s in $(grep -rhoE "\`/(start-session|end-session|replan|plan|adr|write-prompt|handover|ship)\`" skills README.md | tr -d "\`/" | sort -u); do
    test -f "skills/$s/SKILL.md" || { echo "missing $s"; exit 1; }
  done' _ "$here"

check "every reference file new-project names exists" bash -c '
  cd "$1/../skills/new-project" && for f in $(grep -oE "reference/[a-z-]+\.md" SKILL.md | sort -u); do
    test -f "$f" || { echo "missing $f"; exit 1; }
  done' _ "$here"

# install.sh links every skill.
bash "$here/../install.sh" "$tmp/skills-dir" >/dev/null
for skill in new-project start-session replan end-session; do
  check "install.sh links $skill" test -f "$tmp/skills-dir/$skill/SKILL.md"
done
check "scaffold works through the link" bash "$tmp/skills-dir/new-project/scripts/scaffold.sh" "$tmp/linked"
check "replan finds the check script and the task guide beside it" bash -c "test -f '$tmp/skills-dir/replan/../new-project/scripts/scaffold.sh' && test -f '$tmp/skills-dir/replan/../new-project/reference/tasks.md'"

# 2. Nothing is overwritten on a second run.
echo "mine" > "$repo/CLAUDE.md"
out=$(bash "$scaffold" "$repo")
check "second run copies nothing" grep -q "Copied 0 files" <<<"$out"
check "existing file kept" grep -qx "mine" "$repo/CLAUDE.md"

# 3. Settings enable both plugins and are valid JSON.
check "settings.json is valid JSON and enables the three plugins" python3 - "$repo/.claude/settings.json" "$here/../.claude-plugin/plugin.json" <<'PY'
import json, sys
d = json.load(open(sys.argv[1]))
name = json.load(open(sys.argv[2]))["name"]
assert d["enabledPlugins"][name + "@stemee-org"] is True, "the kit must enable this plugin"
assert d["extraKnownMarketplaces"]["stemee-org"]["source"]["source"] == "github"
assert d["enabledPlugins"]["mattpocock-skills@claude-plugins-official"] is True
assert d["enabledPlugins"]["ponytail@ponytail"] is True
assert d["extraKnownMarketplaces"]["ponytail"]["source"] == {"source": "github", "repo": "DietrichGebert/ponytail"}
PY

# 4. The hook blocks secrets.
check "hooks are executable" test -x "$repo/.claude/hooks/protect-files.sh"
set +e
echo '{"tool_input":{"file_path":".env"}}' | "$repo/.claude/hooks/protect-files.sh" >/dev/null 2>&1
code=$?
set -e
check "protect-files.sh blocks .env (exit 2)" test "$code" -eq 2

# 5. --check: a fresh kit is reported as unfilled.
out=$(bash "$scaffold" --check "$repo")
check "--check lists {{placeholders}} of a fresh kit" grep -q '{{' <<<"$out"
check "--check reports a task with no card" grep -q 'T01 has no card' <<<"$out"

# 6. --check on tasks: clean when filled, precise when not.
filled="$tmp/filled"
mkdir -p "$filled/docs/tasks"
cat > "$filled/docs/PLAN.md" <<'MD'
| ID | Task | Milestone | Blocked by | Owner | Branch | Status |
|---|---|---|---|---|---|---|
| T00 | Fill documents | M0 | — | ada | `ada/T00-docs-setup` | in progress |
| T01 | [Scaffold](tasks/T01-scaffold.md) | M1 | — | — | — | todo |
MD
cat > "$filled/docs/tasks/T01-scaffold.md" <<'MD'
# T01 · The repo installs and starts with one command

## Why
Every later task needs a place to put code and a command to run it.

## What to build
`pnpm install` and `pnpm dev` work on a fresh clone.

## Done when
- [ ] A fresh clone starts with the two commands in the README
MD
check "--check is silent on filled tasks" test -z "$(bash "$scaffold" --check "$filled")"

sed -i.bak '/^Every later task/d' "$filled/docs/tasks/T01-scaffold.md"
check "--check reports an empty Why" grep -q '«## Why» is empty' <<<"$(bash "$scaffold" --check "$filled")"

cp "$here/../skills/new-project/templates/docs/tasks/_template.md" "$filled/docs/tasks/T01-scaffold.md"
check "--check reports a card left as the template" grep -q "still holds the template's text" <<<"$(bash "$scaffold" --check "$filled")"

rm "$filled/docs/tasks/"*.bak
echo "# T09 · Orphan" > "$filled/docs/tasks/T09-orphan.md"
check "--check reports a card with no row" grep -q 'no row for T09' <<<"$(bash "$scaffold" --check "$filled")"

# 7. The documentation exists in two languages with the same structure.
same_shape() {  # same number of headings, table rows and code fences in both files
  for pattern in '^#+ ' '^\|' '^ *```'; do
    [ "$(grep -cE "$pattern" "$1")" = "$(grep -cE "$pattern" "$2")" ] || return 1
  done
}
check "README.md and README.it.md have the same structure" same_shape "$here/../README.md" "$here/../README.it.md"
check "the two codes of conduct have the same structure" same_shape "$here/../CODE_OF_CONDUCT.md" "$here/../CODE_OF_CONDUCT.it.md"
check "docs/guide.md and docs/guida.md have the same structure" same_shape "$here/../docs/guide.md" "$here/../docs/guida.md"
check "every command in the English docs exists as a skill" bash -c '
  cd "$1/.." && for s in $(grep -hoE "/relay:[a-z-]+" README.md docs/guide.md | sed "s#/relay:##" | sort -u); do
    test -f "skills/$s/SKILL.md" || { echo "missing $s"; exit 1; }
  done' _ "$here"

[ "$fail" -eq 0 ] && echo "All checks passed." || { echo "Some checks failed."; exit 1; }
