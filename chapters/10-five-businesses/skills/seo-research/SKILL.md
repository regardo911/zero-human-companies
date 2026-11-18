---
name: seo-research
description: When given a topic and target audience, produce a keyword and intent brief (primary/secondary keywords, search intent, competing pages, and a recommended outline) for a content piece.
version: 1.0.0
author: Your Name
license: MIT
metadata:
  hermes:
    tags: [content, seo, keywords, research]
---

# SEO Research

## Overview
Turns a topic and audience into a content brief: the primary keyword, supporting keywords, the search intent behind them, the pages already ranking, and an outline that can outrank them.

## When to Use
Use when the task mentions:
- "keyword research" or "SEO brief"
- "what should this article target"
- a topic plus a target audience or niche

## Procedure
1. Read the topic and audience from the task or a brief file (file toolset).
2. Identify one primary keyword and 4-8 secondary/long-tail keywords. State the search intent for each (informational, comparison, transactional).
3. Fetch the current top-ranking pages for the primary keyword (web toolset). Record their angle, length, and what they cover.
4. List the gaps: subtopics the ranking pages miss or cover thinly.
5. Produce a recommended outline (H2/H3 structure) that covers the intent and fills the gaps, plus a target word-count range.

## Constraints
- Do not invent search-volume numbers or rankings; if you cannot fetch them, mark them NOT FOUND.
- Keywords must come from the topic and the ranking-page analysis, not guesses.
- No publishing; write the brief to a file only.

## Output Format
Markdown: `## Primary Keyword`, `## Secondary Keywords` (with intent), `## Ranking Pages` (URL + angle), `## Gaps`, `## Recommended Outline`, `## Target Length`.

## Verification
Confirm every keyword appears either in the topic or in a fetched ranking page, and that each ranking-page row has a real URL.
