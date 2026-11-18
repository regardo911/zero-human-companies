#!/usr/bin/env bash
# offline checks for the repo. no network, no keys, no paperclip server.
# every script that touches $HOME runs against a throwaway home, never yours.
# usage: bash tests/run.sh
set -uo pipefail

ROOT=$(cd "$(dirname "$0")/.." && pwd)
cd "$ROOT" || exit 1
PASS=0 FAIL=0
ok()  { PASS=$((PASS + 1)); printf '  ok    %s\n' "$1"; }
bad() { FAIL=$((FAIL + 1)); printf '  FAIL  %s\n' "$1"; [ -n "${2:-}" ] && printf '%s\n' "$2" | sed 's/^/        /'; }
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

# hermes builtins the book's configs preload but this repo does not ship (chapter 5's skill list)
BUILTINS="systematic-debugging jupyter-live-kernel"

echo "agent configs parse"
for f in $(find chapters -name '*.json' | sort); do
  if jq -e . "$f" >/dev/null 2>&1; then ok "$f"; else bad "$f is not valid JSON"; fi
done

echo "skill name matches its folder"
SHIPPED=""
for f in $(find chapters -name SKILL.md | sort); do
  dir=$(basename "$(dirname "$f")")
  name=$(awk 'NR==1 && $0!="---"{exit} NR>1 && /^---$/{exit} /^name:/{sub(/^name:[ ]*/,""); print; exit}' "$f")
  SHIPPED="$SHIPPED $dir"
  if [ "$name" = "$dir" ]; then ok "$dir"; else bad "$f: name '$name' does not match folder '$dir'"; fi
done

echo "every --skills name in an agent config exists"
for f in $(find chapters -name '*.json' | sort); do
  list=$(jq -r '.adapterConfig.extraArgs // [] | if type=="array" then . else [.] end
               | . as $a | range(0; length) | select($a[.] == "--skills") | $a[. + 1] // empty' "$f" 2>/dev/null)
  [ -n "$list" ] || continue
  unknown=""
  for s in $(printf '%s\n' "$list" | tr ',' ' '); do
    case " $SHIPPED $BUILTINS " in *" $s "*) ;; *) unknown="$unknown $s" ;; esac
  done
  if [ -z "$unknown" ]; then ok "$f"; else bad "$f preloads skills nobody ships:$unknown"; fi
done

echo "install.sh into a throwaway home"
H="$WORK/home-empty"; mkdir -p "$H"
out=$(env HOME="$H" bash ./install.sh 2>&1); rc=$?
if [ "$rc" -eq 1 ] && printf '%s' "$out" | grep -q "Chapter 4"; then ok "no ~/.hermes: exit 1 with the chapter 4 pointer"; else bad "no ~/.hermes: expected exit 1 + chapter 4 pointer, got $rc" "$out"; fi
H="$WORK/home-hermes"; mkdir -p "$H/.hermes"
out=$(env HOME="$H" bash ./install.sh 2>&1); rc=$?
n=$(find "$H/.hermes/skills/personal" -name SKILL.md | wc -l | tr -d ' ')
if [ "$rc" -eq 0 ] && [ "$n" -eq 11 ]; then ok "first run copies 11 skills"; else bad "first run: exit $rc, $n skills" "$out"; fi
out=$(env HOME="$H" bash ./install.sh 2>&1); rc=$?
c=$(printf '%s\n' "$out" | grep -c ' copied$' || true); k=$(printf '%s\n' "$out" | grep -c 'exists, left alone' || true)
if [ "$rc" -eq 0 ] && [ "$c" -eq 0 ] && [ "$k" -eq 11 ]; then ok "second run copies 0, leaves 11 alone"; else bad "second run: exit $rc, copied $c, left $k" "$out"; fi
echo "my edit" >> "$H/.hermes/skills/personal/standup-notes/SKILL.md"
env HOME="$H" bash ./install.sh >/dev/null 2>&1
if tail -1 "$H/.hermes/skills/personal/standup-notes/SKILL.md" | grep -q "my edit"; then ok "a skill you edited survives a re-run"; else bad "install.sh overwrote an edited skill"; fi
env HOME="$H" bash ./install.sh work >/dev/null 2>&1
n=$(find "$H/.hermes/skills/work" -name SKILL.md 2>/dev/null | wc -l | tr -d ' ')
if [ "$n" -eq 11 ]; then ok "./install.sh work puts them in skills/work"; else bad "category arg: $n skills in skills/work"; fi

echo "backup.sh into a throwaway home"
H="$WORK/home-backup"; mkdir -p "$H/.hermes/memories" "$WORK/bk"
echo "# me" > "$H/.hermes/SOUL.md"; echo "x" > "$H/.hermes/memories/USER.md"
out=$(env HOME="$H" bash chapters/06-memory/backup.sh "$WORK/bk" 2>&1); rc=$?
f=$(find "$WORK/bk" -name 'hermes-knowledge-*.tar.gz' | head -1)
if [ "$rc" -eq 0 ] && [ -n "$f" ] && tar tzf "$f" | grep -q '^memories/USER.md$' && printf '%s' "$out" | grep -q 'skipped (not there): ~/.hermes/skills/personal'; then
  ok "archives what exists, names what it skipped"; else bad "backup.sh: exit $rc" "$out"; fi

echo "monthly-report.sh against made-up activity (fake npx and curl first on PATH)"
FAKE="$WORK/fakebin"; mkdir -p "$FAKE"
cat > "$FAKE/npx" <<'EOF'
#!/usr/bin/env bash
cat "$FAKE_ACTIVITY"
EOF
cat > "$FAKE/curl" <<'EOF'
#!/usr/bin/env bash
echo '{"spendCents": 1234}'
EOF
chmod +x "$FAKE/npx" "$FAKE/curl"
report() { env HOME="$WORK" PATH="$FAKE:$PATH" FAKE_ACTIVITY="$1" PAPERCLIP_API_URL=http://fake.invalid/api PAPERCLIP_API_KEY=fake \
  bash chapters/11-revenue/monthly-report.sh "$2" made-up-company 2>&1; }
out=$(report tests/fixtures/made-up-activity.json 2026-10)
if printf '%s\n' "$out" | grep -qx 'Issues completed: 3' && printf '%s\n' "$out" | grep -qx 'Revisions requested: 1' \
   && printf '%s\n' "$out" | grep -qx 'Revision rate: 33.00%' && printf '%s\n' "$out" | grep -qxF "Agent cost (company total to date): \$12.34"; then
  ok "2026-10: 3 done, 1 revision, 33.00%, \$12.34 to date"; else bad "2026-10 report" "$out"; fi
out=$(report tests/fixtures/made-up-activity.json 2026-09)
if printf '%s\n' "$out" | grep -qx 'Issues completed: 1'; then ok "2026-09: only that month's rows count"; else bad "2026-09 report" "$out"; fi
# the same made-up log with every completion taken out
jq '[.[] | select((.details.status // "") != "done")]' tests/fixtures/made-up-activity.json > "$WORK/no-done.json"
out=$(report "$WORK/no-done.json" 2026-10)
if printf '%s\n' "$out" | grep -qx 'Revision rate: n/a (no completed issues)' && ! printf '%s' "$out" | grep -qi 'divide'; then
  ok "zero completed issues: n/a, no bc error"; else bad "zero-issue report" "$out"; fi
out=$(report tests/fixtures/made-up-activity.json "")
lm=$(printf '%s\n' "$out" | sed -n 's/^Month: //p')
if printf '%s' "$lm" | grep -qE '^[0-9]{4}-(0[1-9]|1[0-2])$' && [ "$lm" != "$(date +%Y-%m)" ]; then ok "empty month means last month ($lm)"; else bad "default month" "$out"; fi
out=$(report tests/fixtures/made-up-activity.json 2026-1); rc=$?
if [ "$rc" -ne 0 ]; then ok "a malformed month is refused"; else bad "malformed month accepted" "$out"; fi

echo "check-prereqs.sh"
out=$(env HOME="$WORK" bash chapters/01-setup-check/check-prereqs.sh 2>&1); rc=$?
lines=0; for t in node python3 curl git jq bc; do printf '%s\n' "$out" | grep -qE "^  $t " && lines=$((lines + 1)); done
if [ "$lines" -eq 6 ]; then ok "prints a line for each of the six tools"; else bad "only $lines of 6 tool lines" "$out"; fi
if [ "$rc" -eq 0 ]; then ok "exit 0: all six present on this machine"; else bad "exit $rc on this machine" "$out"; fi

echo "scripts that spend money stop without a typed yes"
FAKE2="$WORK/spybin"; mkdir -p "$FAKE2"
for t in npx curl; do printf '#!/usr/bin/env bash\necho called >> "%s/calls"\necho "{}"\n' "$WORK" > "$FAKE2/$t"; chmod +x "$FAKE2/$t"; done
spend() { env HOME="$WORK" PATH="$FAKE2:$PATH" PAPERCLIP_API_URL=http://fake.invalid/api PAPERCLIP_API_KEY=fake \
  CID=c INTAKE_AID=a RESEARCHER_AID=a WRITER_AID=a EDITOR_AID=a OPS_AID=a BOARD_UID=u "$@" < /dev/null 2>&1; }
RA=chapters/10-five-businesses/research-agency
for cmd in "chapters/08-compose/chain-path-a.sh c a one two" "chapters/08-compose/chain-path-b.sh c a one two" \
           "$RA/run.sh $RA/example-brief.txt $RA/example-questions.txt"; do
  rm -f "$WORK/calls"
  # shellcheck disable=SC2086
  out=$(spend bash $cmd); rc=$?
  name=$(basename "${cmd%% *}")
  if [ "$rc" -ne 0 ] && [ ! -e "$WORK/calls" ] && printf '%s' "$out" | grep -q 'nothing was created or run'; then
    ok "$name: < /dev/null stops before any npx or curl call"; else bad "$name ran something without yes (exit $rc)" "$out"; fi
done

echo "usage on wrong arguments"
for s in install.sh chapters/01-setup-check/check-prereqs.sh chapters/06-memory/backup.sh chapters/08-compose/chain-path-a.sh \
         chapters/08-compose/chain-path-b.sh chapters/08-compose/approval-gate.sh "$RA/run.sh" chapters/11-revenue/monthly-report.sh; do
  out=$(env HOME="$WORK" bash "$s" x y z w v 2>&1); rc=$?
  if [ "$rc" -eq 2 ] && printf '%s' "$out" | grep -qi usage; then ok "$s"; else bad "$s: exit $rc, no usage line" "$out"; fi
done
out=$(env HOME="$WORK" PAPERCLIP_API_URL=x PAPERCLIP_API_KEY=y bash chapters/08-compose/approval-gate.sh approve some-id "  " 2>&1); rc=$?
if [ "$rc" -eq 2 ] && printf '%s' "$out" | grep -q 'requires a comment'; then ok "approval-gate.sh refuses an empty comment"; else bad "empty comment accepted (exit $rc)" "$out"; fi

echo "shell syntax and shellcheck"
for s in $(find . -name '*.sh' -not -path './.git/*' | sort); do
  if bash -n "$s" 2>"$WORK/err"; then ok "bash -n $s"; else bad "bash -n $s" "$(cat "$WORK/err")"; fi
  if command -v shellcheck >/dev/null; then
    if shellcheck "$s" >"$WORK/err" 2>&1; then ok "shellcheck $s"; else bad "shellcheck $s" "$(cat "$WORK/err")"; fi
  fi
done
command -v shellcheck >/dev/null || echo "  (shellcheck not installed here: CI runs it)"

echo
echo "$PASS passed, $FAIL failed"
[ "$PASS" -gt 0 ] && [ "$FAIL" -eq 0 ]
