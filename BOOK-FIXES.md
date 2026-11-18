# Book fixes

Places where the printed book and the tools disagree, the version this repo ships instead, and the command output that shows why. The book is a fixed print; this file is where the drift gets tracked. Newest tool versions win: if your `--help` disagrees with both, trust your `--help`.

## Chapter 10: systematic-debugging and jupyter-live-kernel come from Hermes

The book prints: chapter 10's Research Agency install block says `systematic-debugging` is "NOT a Hermes builtin" and has you search skills.sh for it. The Data Pipeline section says to author `jupyter-live-kernel` yourself because "it is not a Hermes builtin". Chapter 5's own `hermes skills list` shows `jupyter-live-kernel` as `builtin`, and chapter 5 prints `systematic-debugging` from the author's install.

What I ran, against the Hermes source on GitHub:

```
$ gh api repos/NousResearch/hermes-agent/contents/skills/software-development --jq '.[].name'
codebase-inspection
dogfood
github
requesting-code-review
simplify-code
spike
systematic-debugging
test-driven-development

$ gh api "repos/NousResearch/hermes-agent/contents/skills/data-science?ref=v2026.6.5" --jq '.[].name'
DESCRIPTION.md
jupyter-live-kernel

$ gh api "repos/NousResearch/hermes-agent/contents/skills/data-science?ref=v2026.7.20" --jq '.[].name'
DESCRIPTION.md
jupyter-live-kernel

$ gh api "repos/NousResearch/hermes-agent/contents/skills/data-science?ref=v2026.7.30" --jq '.[].name'
{"message":"Not Found","documentation_url":"https://docs.github.com/rest/repos/contents#get-repository-content","status":"404"}gh: Not Found (HTTP 404)

$ gh api repos/NousResearch/hermes-agent/contents/optional-skills/data-science/jupyter-notebook/SKILL.md --jq .content | base64 -d | head -3
---
name: jupyter-notebook
description: "Iterative Python via live Jupyter kernel (hamelnb)."
```

So `systematic-debugging` ships with Hermes today. `jupyter-live-kernel` shipped with Hermes up to the v2026.7.20 release (the book's sample `hermes --version` is the 2026.6.5 build), and from v2026.7.30 it's an optional skill renamed `jupyter-notebook`. The commit that moved it gives the install command as `hermes skills install official/data-science/jupyter-notebook`.

**The repo ships:** no copy of either skill. The chapter 10 README has the `hermes skills list | grep` check for both and the install line for the renamed one.

## Chapter 10: the Collector preloads two names that match no skill folder

The book prints: the Data Pipeline Collector config with `"extraArgs": ["--skills", "jupyter-live-kernel,web-scraping,data-extraction"]`. The only extraction template in "Skill Templates: Author These" is headed `web-extraction (web-scraping / data-extraction)`, and its `name:` is `web-extraction`. Chapter 5 says a skill whose name doesn't match its folder gets skipped.

What I ran: `bash tests/run.sh`, which checks every `--skills` name in every agent config against the skills in this repo plus the two Hermes ones above. With the printed config:

```
  FAIL  chapters/10-five-businesses/data-pipeline/agents/collector.json preloads skills nobody ships: web-scraping data-extraction
71 passed, 1 failed
```

With the one changed line:

```
  ok    chapters/10-five-businesses/data-pipeline/agents/collector.json
72 passed, 0 failed
```

**The repo ships:** `collector.json` with `"extraArgs": ["--skills", "jupyter-live-kernel,web-extraction"]`. Every other line is as printed.

## Chapter 11: monthly-report.sh in a month with no completed issues

The book prints: `echo "Revision rate: $(echo "scale=2; $REVISIONS / $ISSUES * 100" | bc)%"` with nothing guarding `ISSUES=0`.

What I ran: the printed script, word for word, saved as `printed-monthly-report.sh`, with stand-in `npx` and `curl` reading the made-up activity log in `tests/fixtures/` with its completed issues taken out (one revision request stays). bc here is 7.0.3 on macOS; other bc builds word the error differently:

```
$ bash printed-monthly-report.sh 2026-10 made-up-company
Month: 2026-10
Company: made-up-company
Issues completed: 0
Agent cost: $12.34
Revisions requested: 1

Math error: divide by 0
    0: (main)

Revision rate: %
```

**The repo ships:** `chapters/11-revenue/monthly-report.sh`, which prints `Revision rate: n/a (no completed issues)` in that case. Same inputs:

```
Month: 2026-10
Company: made-up-company
Issues completed: 0
Agent cost (company total to date): $12.34
Revisions requested: 1
Revision rate: n/a (no completed issues)
```

It also labels the cost line "company total to date". The chapter's own comment says the cost endpoint has no month window; the printed output line just says "Agent cost".

## Chapter 11: monthly-report.sh's default month on Linux

The book prints: `MONTH=${1:-$(date -v-1m +%Y-%m)}`. `-v` is a BSD `date` flag.

What I ran: the printed script with GNU `date` first on `PATH` and an empty month, against `tests/fixtures/made-up-activity.json`, a made-up log with three completed issues in October and one in September:

```
$ date --version | head -1
date (GNU coreutils) 9.11
$ bash printed-monthly-report.sh "" made-up-company
date: invalid option -- 'v'
Try 'date --help' for more information.
Month: 
Company: made-up-company
Issues completed: 4
Agent cost: $12.34
Revisions requested: 1
Revision rate: 25.00%
```

The month comes out empty, every row matches, and the totals mix both months. The only warning is the one `date` line on stderr.

**The repo ships:** last month worked out from `date +%Y` and `date +%m`. Same inputs, run in November:

```
Month: 2026-10
Company: made-up-company
Issues completed: 3
Agent cost (company total to date): $12.34
Revisions requested: 1
Revision rate: 33.00%
```

## Chapter 6: the knowledge backup exits 1 when a path is missing

The book prints, in build step 8: `tar czf hermes-knowledge.tar.gz ~/.hermes/SOUL.md ~/.hermes/memories ~/.hermes/skills/personal ~/.hermes/config.yaml 2>/dev/null`, and says the `2>/dev/null` keeps tar quiet if you skipped chapter 5's custom skill.

What I ran, in a throwaway home with no `skills/personal`:

```
$ tar czf hermes-knowledge.tar.gz ~/.hermes/SOUL.md ~/.hermes/memories ~/.hermes/skills/personal ~/.hermes/config.yaml 2>/dev/null; echo "exit=$?"
exit=1
```

The archive is written, but the command reports failure, so anything that runs it with `&&` or `set -e` (a cron line, a script) stops there.

**The repo ships:** `chapters/06-memory/backup.sh`, which names each missing path, archives the rest and exits 0:

```
  skipped (not there): ~/.hermes/skills/personal
  skipped (not there): ~/.hermes/config.yaml
wrote ./hermes-knowledge-20261118.tar.gz (4.0K)
```
