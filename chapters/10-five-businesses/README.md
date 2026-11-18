# Chapter 10: five businesses

Pick one business, set up its agents in a new Paperclip company, and push one test job through every step. This folder has every agent config the chapter prints in full, the nine skill templates from "Skill Templates: Author These", and `research-agency/run.sh`, which runs the Research Agency's eight-step sequence on your own brief.

```
research-agency/    agents/intake.json, researcher.json, writer.json, editor.json, ops.json
                    run.sh, example-brief.txt, example-questions.txt
content-agency/     agents/social.json
lead-gen/           agents/qualifier.json
support-copilot/    agents/policy-check.json
data-pipeline/      agents/collector.json
skills/             nine SKILL.md folders
```

The chapter prints all five Research Agency agents and one distinctive agent for each of the other four businesses. For the rest of a team (Editorial, Prospect Hunter, Drafter, Scoper and so on) the book says to copy the Research Agency shape and change the model and toolsets per role, and that's what you do here too. Chapter 7 mentions company templates. Chapter 10 prints configs, and this repo ships exactly those.

## 1. Install the skills

From the repo root:

```bash
./install.sh
```

That copies all 11 of the book's skills (these nine plus chapter 5's two) into `~/.hermes/skills/personal/`. Then `hermes skills inspect <name>` for each one your business uses:

| Business | Skills from this folder | Also preloaded by its configs |
|---|---|---|
| Research Agency | `research-comparison-table`, `citation-verification` | `systematic-debugging` (Editor) |
| Content Agency | `seo-research`, `headline-writing`, `social-media-adaptation` | |
| Lead Gen | `prospect-qualification`, `personalized-outreach` | |
| Support Copilot | `policy-check` | `systematic-debugging` |
| Data Pipeline | `web-extraction` | `jupyter-live-kernel` |

Change `author: Your Name` in each, then tune the procedure to your clients. The book also names skills it never prints: `prospect-deep-dive`, `fintech-competitor-research`, `developer-audience-tone` and the like. Those are yours to write, with any template here as the starting shape.

### The two skills that aren't in this folder

`systematic-debugging` ships with Hermes. Chapter 10's install block says to search skills.sh for it; you don't need to. Confirm with:

```bash
hermes skills list | grep systematic-debugging
```

`jupyter-live-kernel` shipped with Hermes too, in the version the book was written against (chapter 5's `hermes skills list` shows it as `builtin`). Hermes releases tagged v2026.7.30 and later moved it out of the default set and renamed it `jupyter-notebook`, an optional skill; the change's own notes give the install command. On a current Hermes:

```bash
hermes skills list | grep -E 'jupyter-live-kernel|jupyter-notebook'
hermes skills install official/data-science/jupyter-notebook     # if neither shows up
```

and if you installed `jupyter-notebook`, change that one name in `data-pipeline/agents/collector.json`. The proof for both is in [BOOK-FIXES.md](../../BOOK-FIXES.md).

## 2. Create the agents

One company per business (dashboard only; the CLI has no `company create`). Then for each agent: Agents, Add Agent, name and role from the file, adapter type `hermes_local`, and the `adapterConfig` block in Adapter Config.

```bash
jq .adapterConfig chapters/10-five-businesses/research-agency/agents/researcher.json
```

| File | Model | Toolsets | Preloads |
|---|---|---|---|
| `research-agency/agents/intake.json` | `anthropic/claude-sonnet-4-5` | file | |
| `research-agency/agents/researcher.json` | `openrouter/qwen/qwen-2.5-72b-instruct` | file, web | research-comparison-table, citation-verification |
| `research-agency/agents/writer.json` | `anthropic/claude-sonnet-4-5` | file | |
| `research-agency/agents/editor.json` | `openrouter/qwen/qwen-2.5-72b-instruct` | file, web | citation-verification, systematic-debugging |
| `research-agency/agents/ops.json` | `ollama/llama3:8b` | file | |
| `content-agency/agents/social.json` | `anthropic/claude-haiku-4-5` | file | social-media-adaptation, headline-writing |
| `lead-gen/agents/qualifier.json` | `anthropic/claude-sonnet-4-5` | file | prospect-qualification |
| `support-copilot/agents/policy-check.json` | `anthropic/claude-sonnet-4-5` | file | policy-check, systematic-debugging |
| `data-pipeline/agents/collector.json` | `openrouter/qwen/qwen-2.5-72b-instruct` | file, web, terminal | jupyter-live-kernel, web-extraction |

Every one has `persistSession: false`, as the build step asks for first runs. If Paperclip can't find `hermes` when it spawns an agent, add `"hermesCommand": "/full/path/to/hermes"` (run `command -v hermes` to get it).

One line differs from the book: the Collector preloads `web-extraction`, not `web-scraping,data-extraction` (proof in [BOOK-FIXES.md](../../BOOK-FIXES.md)). Everything else in every file is as printed.

The Collector is the one agent here with `terminal`. The chapter suggests running its heartbeats on Hermes's `docker` backend. I'd do that before pointing it at pages you don't control.

## 3. Run one job through the Research Agency

![Research Agency, one client job, 8 issues. Parse client brief, owned by Intake, then four issues, research question 1 to 4, owned by Researcher, then write report by Writer, fact-check by Editor, and format plus deliver by Ops. Each arrow between steps is labelled blocked by. The last arrow, labelled you approve with a comment, leads to in_review, owned by you. Note: a blocker stops early checkout; a heartbeat still starts each step. Footer: run.sh creates these issues from your brief and your questions.](../../docs/images/research-agency-issues.png)

`run.sh` follows the chapter's "exact commands to run the Research Agency end to end", with your job in place of Acme's. Two changes: it stops at the first step that isn't done, and the Writer waits on this job's research issues only.

**Write the job down.** First line of the brief is the title, the rest is the client's request as they sent it. One research question per line in the other file. The examples are the book's own Acme job, so you can see the format:

```
$ cat research-agency/example-brief.txt
Acme competitive scan
Raw client request pasted into the description

$ cat research-agency/example-questions.txt
Pricing landscape
Feature matrix
Funding + headcount
GTM motion
```

**Export the ids.** Agent ids come from `npx paperclipai agent list --company-id <company-id>`, the two `PAPERCLIP_*` values from `agent local-cli`. `BOARD_UID` is your own user id, the one the approval stage hands the issue to; the book doesn't say where to read it, so check your install.

```bash
export CID=<company-id>
export INTAKE_AID=<id> RESEARCHER_AID=<id> WRITER_AID=<id> EDITOR_AID=<id> OPS_AID=<id>
export BOARD_UID=<your-board-user-id>
# plus the export lines from: npx paperclipai agent local-cli <agent-ref> -C "$CID" --no-install-skills
```

Miss one and the script lists the missing names and stops.

**Run it.**

```bash
chapters/10-five-businesses/research-agency/run.sh my-brief.txt my-questions.txt
```

It prints the brief, the question count and the most heartbeats it may run (one per question plus four), then waits for you to type `yes`. After that it runs steps 1 to 7:

- Intake: creates the issue from your brief, runs the heartbeat, checks it reads `done`.
- Researcher: one issue per question, each blocked by intake. Up to one heartbeat per question, until all read `done`.
- Writer, then Editor: each issue blocked by the one before. Writer's is blocked by this job's research issues.
- Ops: the delivery issue, blocked by the editor issue, with an `executionPolicy` approval stage for your board user.

The moment a step's issue isn't where it should be, the script stops, prints the issue id and tells you which step to pick up by hand. That way you don't pay the Writer to write from research that never finished. How many heartbeats a step takes on your agents is something you find out by running it.

**Approve.** When it gets through step 7, the delivery issue is in `in_review`, assigned to you, and the script prints the command for step 8:

```bash
chapters/08-compose/approval-gate.sh approve <ops-issue-id> "QA passed. Delivered to client."
```

Read the report before you run it. The script can tell you the issue finished; whether the report is good enough to send is yours to judge. To send it back instead, set the issue to any status except `done`, with a comment. It returns to Ops as `changes_requested`. The book shows this as a PATCH (chapter 8, "Governance"); `approval-gate.sh` only approves.

## 4. The other four businesses

They follow the same pattern with different agents. The chapter's workflow lists give the order; create each issue with the CLI or the `curl` form `run.sh` uses, set `blockedByIssueIds` to the step before, and put the `executionPolicy` approval stage on whichever issue sends something to a client. For the Support Copilot that's every outgoing draft. Chapter 8's `approval-gate.sh create` makes that last issue for you.

When the first test job runs end to end with output you'd send, you've hit the chapter's checkpoint.
