---
name: headline-writing
description: When given an article or its thesis and a target audience, generate ten headline options grouped by angle, within length and clarity constraints.
version: 1.0.0
author: Your Name
license: MIT
metadata:
  hermes:
    tags: [content, headlines, copywriting, editorial]
---

# Headline Writing

## Overview
Produces ten headline candidates for one piece, grouped by angle (benefit, curiosity, how-to, contrarian, number/list), each within a clarity and length budget, so an editor can pick.

## When to Use
Use when the task mentions:
- "write headlines" or "title options"
- "headline variants for this article"
- a drafted article or a one-line thesis plus an audience

## Procedure
1. Read the article or thesis and the target audience from disk (file toolset).
2. Extract the single concrete promise the piece delivers.
3. Write ten headlines: two each across five angles (benefit, curiosity, how-to, contrarian, number/list).
4. Keep each under 65 characters where possible; never exceed 80.
5. Flag any headline that overstates what the article actually proves.

## Constraints
- Every headline must be supported by the article; no clickbait the body does not deliver.
- No ALL-CAPS, and no more than one piece of punctuation per headline.
- Match the audience register (developer, executive, consumer) named in the brief.

## Output Format
Markdown grouped by angle: `### Benefit`, `### Curiosity`, `### How-To`, `### Contrarian`, `### Number/List`, two options each, with the character count after each line.

## Verification
Pick the two strongest headlines and confirm the article body explicitly delivers what each promises.
