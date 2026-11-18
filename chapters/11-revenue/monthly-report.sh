#!/usr/bin/env bash
# chapter 11, building your own metrics dashboard (ch11.md fence 252-274). save as ~/bin/monthly-report.sh
# changed from the book: last month via date +%Y/+%m math (date -v-1m is bsd-only); 0 completed
# issues prints n/a, not a bc divide-by-zero; the cost line says "company total to date"; temp file.
set -euo pipefail

usage() {
  echo "usage: $0 <YYYY-MM> <company-id>" >&2
  echo "       $0 \"\" <company-id>     (empty month = last month)" >&2
  echo "needs PAPERCLIP_API_URL and PAPERCLIP_API_KEY in the environment" >&2
  exit 2
}
[ "$#" -eq 2 ] || usage

last_month() {
  local y m
  y=$(date +%Y); m=$((10#$(date +%m) - 1))
  if [ "$m" -eq 0 ]; then m=12; y=$((y - 1)); fi
  printf '%04d-%02d\n' "$y" "$m"
}
MONTH=${1:-$(last_month)}
COMPANY_ID=${2:?usage: monthly-report.sh <YYYY-MM> <company-id>}
case "$MONTH" in
  [0-9][0-9][0-9][0-9]-[0-1][0-9]) ;;
  *) echo "month must look like 2026-10, got: $MONTH" >&2; usage ;;
esac
if [ -z "${PAPERCLIP_API_URL:-}" ] || [ -z "${PAPERCLIP_API_KEY:-}" ]; then
  echo "PAPERCLIP_API_URL and PAPERCLIP_API_KEY must be set (npx paperclipai agent local-cli prints them)" >&2
  exit 1
fi

ACT=$(mktemp)
trap 'rm -f "$ACT"' EXIT

# activity list has no --since/--until flags; fetch the log and filter by createdAt in jq.
npx paperclipai activity list --company-id "$COMPANY_ID" --json > "$ACT"

ISSUES=$(jq --arg m "$MONTH" '[.[] | select(.action == "issue.updated" and (.details.status // "") == "done" and (.createdAt | startswith($m)))] | length' "$ACT")
# cost is cumulative company spend to date (the cost endpoint has no month window); run on
# the 1st and diff against last month's saved value for a true monthly figure:
COST=$(curl -s "$PAPERCLIP_API_URL/companies/$COMPANY_ID/costs/summary" -H "Authorization: Bearer $PAPERCLIP_API_KEY" | jq '.spendCents / 100')
REVISIONS=$(jq --arg m "$MONTH" '[.[] | select(.action == "issue.updated" and (.details.executionState.lastDecisionOutcome // "") == "changes_requested" and (.createdAt | startswith($m)))] | length' "$ACT")

echo "Month: $MONTH"
echo "Company: $COMPANY_ID"
echo "Issues completed: $ISSUES"
echo "Agent cost (company total to date): \$$COST"
echo "Revisions requested: $REVISIONS"
if [ "$ISSUES" -eq 0 ]; then
  echo "Revision rate: n/a (no completed issues)"
else
  echo "Revision rate: $(echo "scale=2; $REVISIONS / $ISSUES * 100" | bc)%"
fi
