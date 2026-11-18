#!/usr/bin/env bash
# chapter 8, sequencing a two-issue chain, path a (ch08.md fence 376-394): cli only.
# changed from the book: titles are yours, and issue 2 is created only if issue 1 reads done.
# uses the ids the server returns, never PC-1. runs paid heartbeats: see DISCLAIMER.md.
set -euo pipefail

if [ "$#" -ne 4 ]; then
  echo "usage: $0 <company-id> <agent-id> \"<first title>\" \"<second title>\"" >&2
  exit 2
fi
CID=$1 AID=$2 T1=$3 T2=$4
for t in npx jq; do command -v "$t" >/dev/null || { echo "$t not found (run chapters/01-setup-check/check-prereqs.sh)" >&2; exit 1; }; done

echo "this runs up to 2 heartbeats on agent $AID in company $CID."
echo "each heartbeat spends money on that agent's model provider."
printf 'type yes to go on: '
read -r answer || answer=""
[ "$answer" = "yes" ] || { echo; echo "stopped. nothing was created or run."; exit 1; }

# $1 = json from issue create; prints "<uuid> <identifier>" or dies with the raw reply
ids() {
  local id ident
  id=$(printf '%s' "$1" | jq -r '.id // empty' 2>/dev/null || true)
  [ -n "$id" ] || { echo "issue create did not return an id. server said:" >&2; printf '%s\n' "$1" >&2; exit 1; }
  ident=$(printf '%s' "$1" | jq -r '.identifier // .id')
  echo "$id $ident"
}
status() { npx paperclipai issue get "$1" --json | jq -r '.status'; }

out=$(npx paperclipai issue create -C "$CID" \
  --title "$T1" --description "First step" \
  --status todo --priority high --assignee-agent-id "$AID" --json)
read -r ID1 N1 <<EOF
$(ids "$out")
EOF
echo "created $N1 ($ID1)"

npx paperclipai heartbeat run --agent-id "$AID" --source on_demand --trigger manual

s1=$(status "$ID1")
echo "$N1 status: $s1"
if [ "$s1" != "done" ]; then
  echo "$N1 is not done, so issue 2 was not created."
  echo "check it: npx paperclipai issue get $ID1 --json"
  exit 1
fi

out=$(npx paperclipai issue create -C "$CID" \
  --title "$T2" \
  --status todo --priority high --assignee-agent-id "$AID" --json)
read -r ID2 N2 <<EOF
$(ids "$out")
EOF
echo "created $N2 ($ID2)"

npx paperclipai heartbeat run --agent-id "$AID" --source on_demand --trigger manual
echo "$N1 status: $(status "$ID1")"
echo "$N2 status: $(status "$ID2")"
