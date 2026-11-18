---
name: standup-notes
description: When asked to summarize work into a standup update, produce a
  three-line "Yesterday / Today / Blockers" note in plain text.
version: 1.0.0
author: Your Name
license: MIT
metadata:
  hermes:
    tags: [standup, summary, status, notes]
---

# Standup Notes

## Overview

Turns a description of recent work into a tight standup update. No filler,
exactly three lines.

## When to Use

Use when the task mentions:
- "standup"
- "status update"
- "what I did yesterday"

## Procedure

1. Read the work the user describes.
2. Write exactly three lines, each starting with a label:
   `Yesterday:`, `Today:`, `Blockers:`.
3. Keep each line under 20 words. If there are no blockers, write
   `Blockers: none`.
