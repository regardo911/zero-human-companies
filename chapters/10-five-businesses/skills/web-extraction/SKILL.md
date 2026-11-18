---
name: web-extraction
description: When given target URLs and a target schema, fetch each page and extract the requested fields into structured JSON, recording extraction failures.
version: 1.0.0
author: Your Name
license: MIT
metadata:
  hermes:
    tags: [scraping, extraction, data, pipeline]
---

# Web Extraction

## Overview
Fetches a list of source URLs and extracts a fixed set of fields from each into a single structured JSON array, with an explicit record of any page that failed or was missing a field.

## When to Use
Use when the task mentions:
- "scrape these pages" or "extract data from these URLs"
- "pull pricing/specs into JSON"
- a source list plus a target schema/field list

## Procedure
1. Read the source-URL list and the target field schema from disk (file toolset).
2. For each URL, fetch the page (web toolset). On fetch failure, record `{url, error}` in a failures list; continue.
3. Extract each schema field. If a field is absent, set it null and record it in the failures list; never guess a value.
4. Normalize obvious format variance (dates to ISO, currency to a numeric + code) only where unambiguous.
5. Write one JSON array of records plus a `failures` array. Use the `terminal` toolset for any parsing that needs Python.

## Constraints
- Never fabricate a field value to fill a gap; null + log it.
- Keep one record per source; do not silently drop failed sources.
- Respect rate limits; space requests if the source list is large.

## Output Format
`{ "records": [ {schema fields...} ], "failures": [ {"url":..., "error":...} ] }`

## Verification
Run on a list including one URL that 404s; confirm it lands in `failures` and the good URLs produce complete records.
