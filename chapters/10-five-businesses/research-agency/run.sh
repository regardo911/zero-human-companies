#!/usr/bin/env bash
# chapter 10, the research agency end to end (ch10.md fence 169-229), steps 1-7, then stops for you.
# changed from the book: your brief and questions, not the acme ones; the writer waits on this
# job's research issues only (printed step 5 takes every issue the researcher ever had); it stops
# at the first step that is not done. runs paid heartbeats: see DISCLAIMER.md.
# shellcheck disable=SC2153  # the agent ids come from your environment, checked by name below
set -euo pipefail

if [ "$#" -ne 2 ]; then
  cat >&2 <<EOF
usage: $0 <brief-file> <questions-file>
  brief-file      first line = title, the rest = the client's request
  questions-file  one research question per line
see example-brief.txt and example-questions.txt next to this script.
EOF
  exit 2
fi
BRIEF=$1 QUESTIONS=$2
[ -s "$BRIEF" ] || { echo "brief file is missing or empty: $BRIEF" >&2; exit 2; }
[ -s "$QUESTIONS" ] || { echo "questions file is missing or empty: $QUESTIONS" >&2; exit 2; }

missing=""
for v in CID INTAKE_AID RESEARCHER_AID WRITER_AID EDITOR_AID OPS_AID BOARD_UID PAPERCLIP_API_URL PAPERCLIP_API_KEY; do
  eval "val=\${$v:-}"
  # shellcheck disable=SC2154
  [ -n "$val" ] || missing="$missing $v"
done
if [ -n "$missing" ]; then
  echo "set these first:$missing" >&2
  echo "agent ids: npx paperclipai agent list --company-id <company-id>" >&2
  echo "PAPERCLIP_API_URL / PAPERCLIP_API_KEY: npx paperclipai agent local-cli <agent-ref> -C <company-id> --no-install-skills" >&2
  exit 1
fi
for t in npx jq curl; do command -v "$t" >/dev/null || { echo "$t not found" >&2; exit 1; }; done

TITLE=$(head -1 "$BRIEF")
DESC=$(tail -n +2 "$BRIEF")
[ -n "${DESC//[[:space:]]/}" ] || DESC=$TITLE
NQ=0
while IFS= read -r q || [ -n "$q" ]; do
  [ -n "${q//[[:space:]]/}" ] && NQ=$((NQ + 1))
done < "$QUESTIONS"
[ "$NQ" -gt 0 ] || { echo "no questions in $QUESTIONS" >&2; exit 2; }

echo "brief:     $TITLE"
echo "questions: $NQ"
echo "this runs heartbeats on 5 agents: Intake ($INTAKE_AID), Researcher ($RESEARCHER_AID, up to $NQ),"
echo "Writer ($WRITER_AID), Editor ($EDITOR_AID), Ops ($OPS_AID). up to $((NQ + 4)) heartbeats in all."
echo "each heartbeat spends money on that agent's model provider."
printf 'type yes to go on: '
read -r answer || answer=""
[ "$answer" = "yes" ] || { echo; echo "stopped. nothing was created or run."; exit 1; }

auth="Authorization: Bearer $PAPERCLIP_API_KEY"
post_issue() {
  local reply id
  reply=$(curl -s -X POST "$PAPERCLIP_API_URL/companies/$CID/issues" \
    -H "$auth" -H "Content-Type: application/json" -d "$1")
  id=$(printf '%s' "$reply" | jq -r '.id // empty' 2>/dev/null || true)
  [ -n "$id" ] || { echo "no issue id came back. the server said:" >&2; printf '%s\n' "$reply" >&2; exit 1; }
  echo "$id"
}
beat() { npx paperclipai heartbeat run --agent-id "$1" --source on_demand --trigger manual; }
status() { npx paperclipai issue get "$1" --json | jq -r '.status'; }
# stop the run (and the spending) when a step did not finish
must_be() {
  local id=$1 want=$2 step=$3 s
  s=$(status "$id")
  echo "step $step: issue $id is $s"
  if [ "$s" != "$want" ]; then
    echo "expected $want. stopping here so later agents don't run on missing work."
    echo "look at it: npx paperclipai issue get $id --json"
    echo "when it's $want, carry on by hand from step $((step + 1)) in chapter 10."
    exit 1
  fi
}

# 1. intake issue, assigned to Intake
out=$(npx paperclipai issue create -C "$CID" \
  --title "Parse client brief: $TITLE" \
  --description "$DESC" \
  --status todo --priority high --assignee-agent-id "$INTAKE_AID" --json)
INTAKE_ID=$(printf '%s' "$out" | jq -r '.id // empty' 2>/dev/null || true)
[ -n "$INTAKE_ID" ] || { echo "issue create returned no id:" >&2; printf '%s\n' "$out" >&2; exit 1; }
echo "step 1: intake issue $INTAKE_ID"

# 2. Intake works it
beat "$INTAKE_AID"
must_be "$INTAKE_ID" "done" 2

# 3. one research issue per question, each blocked by intake
RESEARCH_IDS=""
while IFS= read -r q || [ -n "$q" ]; do
  [ -n "${q//[[:space:]]/}" ] || continue
  id=$(post_issue "$(jq -n --arg t "Research: $q" --arg a "$RESEARCHER_AID" --arg b "$INTAKE_ID" \
    '{title:$t, status:"todo", priority:"high", assigneeAgentId:$a, blockedByIssueIds:[$b]}')")
  RESEARCH_IDS="$RESEARCH_IDS $id"
  echo "step 3: research issue $id ($q)"
done < "$QUESTIONS"

# 4. heartbeat the Researcher until this job's research issues are done, one beat per question at most
open_count() {
  local n=0 id
  for id in $RESEARCH_IDS; do [ "$(status "$id")" = "done" ] || n=$((n + 1)); done
  echo "$n"
}
beats=0
while [ "$(open_count)" -gt 0 ] && [ "$beats" -lt "$NQ" ]; do
  beat "$RESEARCHER_AID"
  beats=$((beats + 1))
done
left=$(open_count)
echo "step 4: $beats researcher heartbeat(s), $left of $NQ research issues not done"
if [ "$left" -gt 0 ]; then
  echo "stopping here. check them: npx paperclipai issue list -C $CID --assignee-agent-id $RESEARCHER_AID --json"
  exit 1
fi

# 5. writer, blocked by this job's research issues
# shellcheck disable=SC2086
ids_json=$(printf '%s\n' $RESEARCH_IDS | jq -R . | jq -sc .)
WRITE_ID=$(post_issue "$(jq -n --arg a "$WRITER_AID" --argjson b "$ids_json" \
  '{title:"Write report from research notes", status:"todo", priority:"high", assigneeAgentId:$a, blockedByIssueIds:$b}')")
beat "$WRITER_AID"
must_be "$WRITE_ID" "done" 5

# 6. editor, blocked by the writer
EDIT_ID=$(post_issue "$(jq -n --arg a "$EDITOR_AID" --arg b "$WRITE_ID" \
  '{title:"Fact-check + verify citations", status:"todo", priority:"high", assigneeAgentId:$a, blockedByIssueIds:[$b]}')")
beat "$EDITOR_AID"
must_be "$EDIT_ID" "done" 6

# 7. ops delivery, gated on your approval
OPS_ID=$(post_issue "$(jq -n --arg a "$OPS_AID" --arg b "$EDIT_ID" --arg u "$BOARD_UID" '{
  title: "Format + deliver to client",
  status: "todo", priority: "high", assigneeAgentId: $a,
  blockedByIssueIds: [$b],
  executionPolicy: {
    mode: "normal", commentRequired: true,
    stages: [ { type: "approval", participants: [ { type: "user", userId: $u } ] } ]
  }
}')")
beat "$OPS_AID"
must_be "$OPS_ID" in_review 7

# 8. yours: read the report, then approve
here=$(cd "$(dirname "$0")/../../.." && pwd)
echo
echo "the delivery issue is waiting for you (in_review): $OPS_ID"
echo "read the work first. whether it is good enough is unknown, you must observe this."
echo "list it:    npx paperclipai issue list -C $CID --status in_review --json"
echo "approve it: $here/chapters/08-compose/approval-gate.sh approve $OPS_ID \"QA passed. Delivered to client.\""
