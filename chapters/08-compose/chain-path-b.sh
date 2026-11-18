#!/usr/bin/env bash
# chapter 8, sequencing a two-issue chain, path b (ch08.md fence 398-418): the rest blocker edge.
# changed from the book: titles are yours, and request bodies are built with jq -n so a quote
# in a title can't break the json. runs paid heartbeats: see DISCLAIMER.md.
set -euo pipefail

if [ "$#" -ne 4 ]; then
  echo "usage: $0 <company-id> <agent-id> \"<first title>\" \"<second title>\"" >&2
  echo "needs PAPERCLIP_API_URL and PAPERCLIP_API_KEY in the environment" >&2
  exit 2
fi
CID=$1 AID=$2 T1=$3 T2=$4
for t in npx jq curl; do command -v "$t" >/dev/null || { echo "$t not found (run chapters/01-setup-check/check-prereqs.sh)" >&2; exit 1; }; done
if [ -z "${PAPERCLIP_API_URL:-}" ] || [ -z "${PAPERCLIP_API_KEY:-}" ]; then
  echo "PAPERCLIP_API_URL and PAPERCLIP_API_KEY must be set. get them with:" >&2
  echo "  npx paperclipai agent local-cli <agent-ref> -C $CID --no-install-skills" >&2
  echo "then paste the export lines it prints into this shell." >&2
  exit 1
fi

echo "this runs 2 heartbeats on agent $AID in company $CID."
echo "each heartbeat spends money on that agent's model provider."
printf 'type yes to go on: '
read -r answer || answer=""
[ "$answer" = "yes" ] || { echo; echo "stopped. nothing was created or run."; exit 1; }

post_issue() {
  curl -s -X POST "$PAPERCLIP_API_URL/companies/$CID/issues" \
    -H "Authorization: Bearer $PAPERCLIP_API_KEY" -H "Content-Type: application/json" \
    -d "$1"
}
need_id() {
  local id
  id=$(printf '%s' "$1" | jq -r '.id // empty' 2>/dev/null || true)
  [ -n "$id" ] || { echo "the server did not return an issue id. it said:" >&2; printf '%s\n' "$1" >&2; exit 1; }
  echo "$id"
}
status() { npx paperclipai issue get "$1" --json | jq -r '.status'; }

PC1=$(post_issue "$(jq -n --arg t "$T1" --arg a "$AID" \
  '{title:$t, status:"todo", priority:"high", assigneeAgentId:$a}')")
PC1_ID=$(need_id "$PC1")
echo "created $(printf '%s' "$PC1" | jq -r '.identifier // .id') ($PC1_ID)"

PC2=$(post_issue "$(jq -n --arg t "$T2" --arg a "$AID" --arg b "$PC1_ID" \
  '{title:$t, status:"todo", priority:"high", assigneeAgentId:$a, blockedByIssueIds:[$b]}')")
PC2_ID=$(need_id "$PC2")
echo "created $(printf '%s' "$PC2" | jq -r '.identifier // .id') ($PC2_ID)"

# blockedByIssueIds reads back null; the stored edge comes back as .blockedBy[]
edge=$(curl -s "$PAPERCLIP_API_URL/issues/$PC2_ID" -H "Authorization: Bearer $PAPERCLIP_API_KEY" \
  | jq -r '[.blockedBy[]?.identifier] | join(", ")' 2>/dev/null || true)
echo "issue 2 is blocked by: ${edge:-(nothing read back, check the dashboard)}"

npx paperclipai heartbeat run --agent-id "$AID" --source on_demand --trigger manual
echo "issue 1 status: $(status "$PC1_ID")"
npx paperclipai heartbeat run --agent-id "$AID" --source on_demand --trigger manual
echo "issue 1 status: $(status "$PC1_ID")"
echo "issue 2 status: $(status "$PC2_ID")"
