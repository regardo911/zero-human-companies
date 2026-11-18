---
name: research-comparison-table
description: When comparing products, vendors, markets, or tools, produce a cited comparison table plus a short recommendation.
version: 1.0.0
author: Your Name
license: MIT
metadata:
  hermes:
    tags: [research, comparison, competitive-analysis, tables]
---

# Research Comparison Table

## Overview
Turns raw research on multiple companies, tools, or products into a structured comparison table with cited evidence and a recommendation.

## When to Use
Use when the task mentions:
- "compare these companies"
- "competitive analysis"
- "market overview"
- "top tools/vendors/products"
- "pricing/features comparison"

## Procedure
1. Identify the entities being compared. If the task does not name them, propose 5-7 candidates and state the selection basis.
2. Define 5-8 comparison dimensions relevant to the decision: pricing, target customer, key features, integrations, limitations, proof points, and recent activity.
3. Gather source-backed facts for each entity. Prefer official pricing/docs pages, changelogs, public case studies, and recent credible third-party sources.
4. Build a Markdown table with one row per entity and one column per comparison dimension.
5. Add a short "Best fit" recommendation that names the winner for the stated use case and explains the tradeoff.
6. Add a "Missing / unverifiable" note for any field where the source does not support a confident answer.

## Constraints
- Every non-obvious claim must cite a source URL or local file path.
- Never invent pricing, feature support, customer counts, funding, dates, or integrations.
- If a source is stale, mark the field as stale instead of treating it as current.
- Do not hide uncertainty inside polished prose; put `UNVERIFIED` or `NOT FOUND` in the table cell.

## Output Format
Markdown:

1. `## Comparison Table`
2. Table columns: `Entity | Best For | Pricing | Key Features | Limitations | Evidence | Notes`
3. `## Recommendation`
4. `## Missing / Unverified Data`

## Verification
Before final output, pick two table cells at random and confirm each is backed by the cited source. If either fails, re-check the whole table.
