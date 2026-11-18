# Chapter 11: the monthly numbers

`monthly-report.sh` is the script from "Building your own metrics dashboard". Changes: last month by date math (the printed `date -v` is BSD only, so it broke on Linux), `n/a` instead of a bc error in a month with no completed issues, a "company total to date" cost label, a temp file, and checks on the arguments and the two env vars. [BOOK-FIXES.md](../../BOOK-FIXES.md) shows the printed version failing.

```bash
mkdir -p ~/bin && cp chapters/11-revenue/monthly-report.sh ~/bin/   # then put ~/bin on your PATH
monthly-report.sh 2026-10 <company-id>
monthly-report.sh "" <company-id>      # empty month means last month
```

It needs `PAPERCLIP_API_URL` and `PAPERCLIP_API_KEY` exported (chapter 8's `agent local-cli`). Against the made-up activity log in `tests/fixtures/`, with stand-ins for `npx` and `curl`, it prints:

```
Month: 2026-10
Company: made-up-company
Issues completed: 3
Agent cost (company total to date): $12.34
Revisions requested: 1
Revision rate: 33.00%
```

Those numbers come from the test fixture, not a real company. Yours come from your server.

Read the cost line carefully. The cost endpoint has no month filter, so that figure is everything the company has spent so far. For one month's spend, run the report on the 1st and subtract last month's saved figure, as the chapter says. Save each run under its month:

```bash
mkdir -p monthly-reports
monthly-report.sh 2026-10 <company-id> > monthly-reports/2026-10.txt
```

## Revenue

`revenue.csv` is the header row from "Revenue tracking": `date,client,amount,type`, where `type` is `retainer` or `project`. Add a row when a payment lands, then total a month with the chapter's line:

```bash
awk -F, -v m="$(date +%Y-%m)" 'NR>1 && $1 ~ "^"m {sum+=$3} END {print "Total: $" sum}' revenue.csv
```

On the empty file it prints `Total: $`, because there's nothing to add yet.
