---
name: my-research-workflow
description: When researching a software library, produce a comparison table
  and a recommendation section, prioritizing production-ready options.
version: 1.0.0
author: Your Name
license: MIT
metadata:
  hermes:
    tags: [research, comparison, recommendation, software-libraries]
    related_skills: [codebase-inspection]
---

# My Research Workflow

## Overview

A focused research process for evaluating software libraries. Produces a
comparison table and a recommendation.

## When to Use

Use when the task mentions:
- "research library X"
- "compare libraries"
- "which X should I use"
- "evaluate options for X"

## Procedure

1. Identify the top 5 candidates by GitHub stars, recency, and community mentions
2. For each candidate, extract: name, license, last release date, star count,
   primary maintainer, key differentiator, known limitations
3. Format as a Markdown table with one row per candidate
4. Add a recommendation section that picks the best fit with reasoning
5. Cite sources for all data points

## Constraints

- Every statistic must cite a source URL
- Flag any library with no release in the last 12 months as "maintenance concern"
- Never invent star counts or maintainer names

## Output Format

Markdown with a table first, then a recommendation section (200-300 words).
