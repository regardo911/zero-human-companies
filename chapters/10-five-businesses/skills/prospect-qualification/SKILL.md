---
name: prospect-qualification
description: When given a prospect's research and a client ICP, score the prospect and emit qualify or disqualify with reasoning.
version: 1.0.0
author: Your Name
license: MIT
metadata:
  hermes:
    tags: [sales, lead-gen, qualification, scoring]
---

# Prospect Qualification

## Overview
Scores one prospect against the client's Ideal Customer Profile and outputs a qualify/disqualify decision with the evidence behind it.

## When to Use
Use when the task mentions:
- "qualify this prospect" or "score this lead"
- "does this company fit the ICP"
- a prospect research file plus an ICP/criteria file

## Procedure
1. Read the ICP/criteria file from disk (file toolset). Identify the hard disqualifiers and the weighted fit signals.
2. Read the prospect research file.
3. Check each hard disqualifier first. If any is present, output DISQUALIFY with the disqualifier named; stop.
4. Score each weighted signal present in the research. Sum to a 0-100 fit score.
5. Output QUALIFY (score >= threshold) or DISQUALIFY (below), with the top 3 reasons.

## Constraints
- Use only facts present in the prospect research file; do not infer revenue/headcount you cannot cite.
- Disqualifiers override score; a high score never overrides a hard disqualifier.
- No web access; do not re-fetch prospect data.

## Output Format
`QUALIFY|DISQUALIFY  score=<0-100>` then 3 bullet reasons, each citing a fact from the research file.

## Verification
Run on one prospect that violates a hard disqualifier; confirm DISQUALIFY regardless of other signals.
