---
name: policy-check
description: When given a drafted response and a policy document, flag any part of the draft that violates the policy, with line and clause references.
version: 1.0.0
author: Your Name
license: MIT
metadata:
  hermes:
    tags: [compliance, support, policy, review]
---

# Policy Check

## Overview
Compares a drafted customer-facing response against a client policy document and returns PASS, FLAG, or ESCALATE. Does not rewrite.

## When to Use
Use when the task mentions:
- "check this against policy" or "policy review"
- "does this draft violate our rules"
- a drafted response plus a policy file

## Procedure
1. Read the policy document from disk (file toolset). Index its clauses.
2. Read the drafted response.
3. For each policy clause, check whether the draft contradicts or over-promises against it (refunds, feature claims, commitments, tone rules).
4. If any violation: FLAG with the draft line(s) and the policy clause violated.
5. If the situation is outside the policy's scope: ESCALATE. If clean: PASS.

## Constraints
- Do not rewrite the draft. Output a verdict only.
- Do not approve ambiguous cases; ESCALATE them.
- No web, no terminal; read draft and policy, write verdict.

## Output Format
One of: `PASS`, `FLAG` (with line refs + clause), or `ESCALATE` (with the out-of-scope reason).

## Verification
Run on a draft that promises a refund the policy forbids; confirm FLAG with the refund clause cited.
