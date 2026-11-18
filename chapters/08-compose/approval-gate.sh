#!/usr/bin/env bash
# chapter 8, governance: an executionPolicy approval stage on an issue (ch08.md fence 448-470).
# create posts the gated issue; approve sends the done + comment patch. changed from the book:
# ids and text are yours, and bodies are built with jq -n. runs no heartbeat.
set -euo pipefail

usage() {
  cat >&2 <<EOF
usage: $0 create <company-id> <agent-id> <board-user-id> "<title>"
       $0 approve <issue-id> "<comment>"
needs PAPERCLIP_API_URL and PAPERCLIP_API_KEY in the environment
EOF
  exit 2
}
[ "$#" -ge 1 ] || usage
cmd=$1; shift
case "$cmd" in
  create)  [ "$#" -eq 4 ] || usage ;;
  approve) [ "$#" -eq 2 ] || usage
           if [ -z "${2// /}" ]; then
             echo "the comment can't be empty: with commentRequired the server answers 422" >&2
             echo "\"Approving a review or approval stage requires a comment\"" >&2
             exit 2
           fi ;;
  *) usage ;;
esac
for t in jq curl; do command -v "$t" >/dev/null || { echo "$t not found" >&2; exit 1; }; done
if [ -z "${PAPERCLIP_API_URL:-}" ] || [ -z "${PAPERCLIP_API_KEY:-}" ]; then
  echo "PAPERCLIP_API_URL and PAPERCLIP_API_KEY must be set. get them with:" >&2
  echo "  npx paperclipai agent local-cli <agent-ref> -C <company-id> --no-install-skills" >&2
  exit 1
fi
auth="Authorization: Bearer $PAPERCLIP_API_KEY"

if [ "$cmd" = create ]; then
  CID=$1 AID=$2 UID_=$3 TITLE=$4
  body=$(jq -n --arg t "$TITLE" --arg a "$AID" --arg u "$UID_" '{
    title: $t,
    assigneeAgentId: $a,
    executionPolicy: {
      mode: "normal",
      commentRequired: true,
      stages: [ { type: "approval", participants: [ { type: "user", userId: $u } ] } ]
    }
  }')
  reply=$(curl -s -X POST "$PAPERCLIP_API_URL/companies/$CID/issues" \
    -H "$auth" -H "Content-Type: application/json" -d "$body")
  id=$(printf '%s' "$reply" | jq -r '.id // empty' 2>/dev/null || true)
  [ -n "$id" ] || { echo "no issue id came back. the server said:" >&2; printf '%s\n' "$reply" >&2; exit 1; }
  echo "created $(printf '%s' "$reply" | jq -r '.identifier // .id') ($id), gated on user $UID_"
  echo "when the agent sets it to done, Paperclip moves it to in_review and assigns it to that user."
  echo "approve it: $0 approve $id \"<your comment>\""
  exit 0
fi

ISSUE=$1 COMMENT=$2
reply=$(curl -s -X PATCH "$PAPERCLIP_API_URL/issues/$ISSUE" \
  -H "$auth" -H "Content-Type: application/json" \
  -d "$(jq -n --arg c "$COMMENT" '{status:"done", comment:$c}')")
st=$(printf '%s' "$reply" | jq -r '.status // empty' 2>/dev/null || true)
if [ -z "$st" ]; then
  echo "the server did not return a status. it said:" >&2
  printf '%s\n' "$reply" >&2
  exit 1
fi
echo "issue $ISSUE status: $st"
