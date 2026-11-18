---
name: citation-verification
description: When a draft contains cited sources, verify each citation resolves and supports the claim, and flag any that do not.
version: 1.0.0
author: Your Name
license: MIT
metadata:
  hermes:
    tags: [research, fact-check, citations, verification]
---

# Citation Verification

## Overview
Checks every citation in a draft: that the source exists, is reachable, and actually supports the claim it is attached to. Produces a pass/flag verdict per citation.

## When to Use
Use when the task mentions:
- "verify citations" or "fact-check sources"
- "check the references in this report"
- a draft that contains URLs, paper titles, or attributed quotes

## Procedure
1. Extract every citation (URL, title, quote, statistic) and the specific claim it supports.
2. For each URL citation, fetch it (web toolset). If it 404s or is unreachable, mark FLAG: unreachable.
3. Compare the fetched content against the claim. If the source does not state the claim, mark FLAG: unsupported.
4. For non-URL citations (papers, quotes, stats) with no fetchable source, mark FLAG: unverifiable. Do not pass on plausibility.
5. Leave the draft text unchanged. Write a verdict list only.

## Constraints
- Never invent a replacement source for a broken citation.
- Never upgrade an unverifiable citation to PASS because it "sounds right."
- Do not rewrite the draft; output verdicts only.

## Output Format
A list, one line per citation: `PASS` or `FLAG:<reason>`, then the citation and the claim it backs.

## Verification
Re-run on a draft with one known-bad URL; confirm it returns FLAG:unreachable for that line and PASS for a known-good one.
