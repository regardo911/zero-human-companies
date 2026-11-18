---
name: social-media-adaptation
description: When given an approved article, adapt it into a LinkedIn post, a Twitter/X thread, and a newsletter blurb, preserving the article's factual claims and writing files only.
version: 1.0.0
author: Your Name
license: MIT
metadata:
  hermes:
    tags: [content, social-media, repurposing, distribution]
---

# Social Media Adaptation

## Overview
Repurposes one approved article into three channel-specific drafts (LinkedIn post, Twitter/X thread, newsletter blurb) without changing any factual claim, and writes them to files for human review.

## When to Use
Use when the task mentions:
- "adapt this for social" or "repurpose the article"
- "LinkedIn / Twitter / newsletter version"
- an approved article file

## Procedure
1. Read the approved article from disk (file toolset). Extract its claims, numbers, and the single core takeaway.
2. LinkedIn post: 1100-1300 characters, hook first line, three short body paragraphs, one CTA.
3. Twitter/X thread: 5-8 tweets, each under 280 characters, the first tweet a standalone hook.
4. Newsletter blurb: 80-120 words plus a subject line.
5. Write each to its own file (`linkedin.md`, `thread.md`, `newsletter.md`). Do not post anything.

## Constraints
- Every factual claim must trace to the source article; never add a new statistic, quote, or promise.
- Do not publish or call any posting API; write files only.
- Keep each piece within its length budget.

## Output Format
Three files plus a `SOURCES:` block mapping each channel's claims back to lines in the source article.

## Verification
Confirm every number and named claim in all three drafts appears in the source article.
