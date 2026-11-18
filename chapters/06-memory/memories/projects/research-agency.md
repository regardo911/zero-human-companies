# Project: Research Agency

## Context
A zero-human research agency: competitive-intelligence reports for B2B
clients who don't have an analyst on staff. Target customers: product
managers, VCs, and consultants.

## Key decisions
- Pricing: $300 per report until the first ten clients, then re-price
- Primary stack: Hermes Agent + Paperclip via the hermes_local adapter
- Every claim in a client report carries a source citation

## What's been done
- Intake, Researcher, and Writer agents configured and tested
- First two pilot reports delivered (AI code editors, CRM pricing)
- Report template approved by both pilot clients

## What's next
- The Editor agent (the quality pass before anything ships)
- Delivery automation for the final report handoff
- Client #3 onboarding

## Constraints
- Nothing ships to a client without the Editor agent's pass
- Every data point must trace to a source the client can open
- Model spend per report gets logged and reviewed weekly
