---
name: personalized-outreach
description: When given qualified-prospect research, write a subject line and outreach email that references specific verifiable details about the prospect.
version: 1.0.0
author: Your Name
license: MIT
metadata:
  hermes:
    tags: [sales, outreach, email, personalization]
---

# Personalized Outreach

## Overview
Turns prospect research into a subject line plus a short outreach email built around specific, verifiable details (a launch, a hire, a blog post), not generic flattery.

## When to Use
Use when the task mentions:
- "write outreach" or "draft a cold email"
- "personalize this for the prospect"
- a qualified-prospect research file

## Procedure
1. Read the prospect research file (file toolset). Pick the 1-2 most specific, recent, verifiable hooks.
2. Write a subject line under 60 characters that names the hook.
3. Write a 90-130 word email: one-line hook tied to the prospect, one line of relevance, one specific ask, a single CTA.
4. Cite each personalization detail inline as a comment so a reviewer can verify it traces to the research file.

## Constraints
- Every personal detail must come from the research file; never invent a launch, role, or quote.
- One CTA only. No multi-paragraph pitches.
- No web access; the research file is the source of truth.

## Output Format
`SUBJECT: <line>` then the email body, then a `SOURCES:` block mapping each personalized claim to a line in the research file.

## Verification
Confirm every personalized claim in the email appears in the SOURCES block and in the research file.
