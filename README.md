# Zero-Human Companies: the files

**Hermes agents finish the issues in a Paperclip company. Here are the files from the book that build it.**

Companion to the book *Zero-Human Companies* from [youcanbuildthings.com](https://youcanbuildthings.com).

The files the book has you type in, laid out by chapter, so you copy instead of retype. **Hermes** does the work (chapter 4). **Paperclip** hands it issues and tracks the cost (chapter 7). A **skill** is a `SKILL.md` Hermes reads before a task (chapter 5). An **agent config** is the JSON you paste into Paperclip to hire a Hermes agent (chapter 8). Pick a starting point below.

[![CI](https://github.com/regardo911/zero-human-companies/actions/workflows/ci.yml/badge.svg)](https://github.com/regardo911/zero-human-companies/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Educational, not business advice](https://img.shields.io/badge/read-disclaimer-orange.svg)](DISCLAIMER.md)

![Poster. A Paperclip company where Hermes agents finish the issues. Left, what you build in chapters 8, 10 and 11. Right, the files: 11 skills, 11 agent configs, SOUL.md and memory examples, 4 scripts, monthly-report.sh and revenue.csv. Bottom: run ./chapters/01-setup-check/check-prereqs.sh first.](docs/images/hero.png)

## Start here

```bash
git clone https://github.com/regardo911/zero-human-companies.git
cd zero-human-companies
```

### "I'm starting the book and have nothing installed"

```bash
./chapters/01-setup-check/check-prereqs.sh
```

It prints the version of node, python3, curl, git, jq and bc, or `missing` plus the install line. Read-only. Then turn to chapter 4.

### "Hermes is installed"

```bash
./install.sh
```

Copies the book's 11 skills into `~/.hermes/skills/personal/`. A skill folder you already have is left alone, so your own edits survive. Then `hermes skills list` shows them.

### "My Paperclip company is running"

```bash
chapters/10-five-businesses/research-agency/run.sh my-brief.txt my-questions.txt
```

Write your brief and questions first: copy `example-brief.txt` and `example-questions.txt` from that folder and change them. Export your agent ids as the [chapter 10 README](chapters/10-five-businesses/) shows. The script creates the Research Agency's issues from your files, runs each agent's heartbeat, and stops with the delivery issue waiting for your approval. It asks you to type `yes` before it spends anything. Want something smaller first? The [chapter 8 scripts](chapters/08-compose/) run a two-issue chain on one agent.

### "I finished the book, I just want the files"

Use the table below.

## Where each file goes

| Chapter | In this repo | Where it goes |
|---|---|---|
| 5 | `chapters/05-skills/standup-notes/`, `my-research-workflow/` | `~/.hermes/skills/personal/<name>/` (`./install.sh` does it) |
| 6 | `chapters/06-memory/SOUL.example.md` | `~/.hermes/SOUL.md`, after you rewrite it for yourself |
| 6 | `chapters/06-memory/memories/USER.md` | `~/.hermes/memories/USER.md` |
| 6 | `chapters/06-memory/memories/projects/research-agency.md` | `~/.hermes/memories/projects/research-agency.md` |
| 8 | `chapters/08-compose/agents/*.json` | Paperclip dashboard: Agents, Add Agent. The `adapterConfig` block goes in Adapter Config |
| 10 | `chapters/10-five-businesses/<business>/agents/*.json` | Same place, one agent per file |
| 10 | `chapters/10-five-businesses/skills/<name>/` | `~/.hermes/skills/personal/<name>/` (`./install.sh` does it) |
| 11 | `chapters/11-revenue/monthly-report.sh` | `~/bin/monthly-report.sh` |
| 11 | `chapters/11-revenue/revenue.csv` | Wherever you keep your books. One row per payment |

To print just the part that goes in Adapter Config: `jq .adapterConfig chapters/08-compose/agents/research-worker.json`.

## Chapter map

| Folder | What you build | The command | What success looks like |
|---|---|---|---|
| [01-setup-check](chapters/01-setup-check/) | A checked machine | `./chapters/01-setup-check/check-prereqs.sh` | Six version lines, exit 0 |
| [05-skills](chapters/05-skills/) | Your first hand-written skill | `hermes -s standup-notes` | A three-line Yesterday / Today / Blockers note |
| [06-memory](chapters/06-memory/) | An agent that knows who you are, and a backup | `chapters/06-memory/backup.sh` | `wrote ./hermes-knowledge-<date>.tar.gz` |
| [08-compose](chapters/08-compose/) | One Hermes agent finishing Paperclip issues in order | `chapters/08-compose/chain-path-b.sh <company-id> <agent-id> "<title>" "<title>"` | Both issues print `done` |
| [10-five-businesses](chapters/10-five-businesses/) | One of five business teams | `chapters/10-five-businesses/research-agency/run.sh <brief> <questions>` | The delivery issue sits in `in_review`, waiting for you |
| [11-revenue](chapters/11-revenue/) | Your monthly numbers | `monthly-report.sh <YYYY-MM> <company-id>` | Issues completed, agent cost, revision rate |

Chapters 2, 3, 4, 7, 9 and 12 are explanation, or commands you type straight from the book, so they get no folder. Where the book and the tools have drifted apart, [BOOK-FIXES.md](BOOK-FIXES.md) has the working version and the output that proves it.

## How it fits together

Paperclip runs the company: issues, heartbeats, costs, approvals. Hermes does the work, with its skills and memory. The `hermes_local` adapter that ships inside Paperclip joins them, so a heartbeat starts a Hermes run on an issue and the result lands back in Paperclip. The skills and memory files here go to Hermes; the agent configs go to Paperclip.

## What it needs

- node, python3, curl, git, jq and bc, the six `check-prereqs.sh` checks. `install.sh`, `backup.sh` and the tests run on those alone, offline.
- `bash tests/run.sh` runs offline in a throwaway home. It parses every agent config, matches each skill's `name:` to its folder, and checks each `--skills` name against this repo plus the two Hermes ones it assumes (`systematic-debugging`, `jupyter-live-kernel`). It runs `install.sh`, `backup.sh` and `monthly-report.sh` on made-up data and confirms the paid scripts stop without a typed `yes`.
- The chapter 8, 10 and 11 scripts need your own Paperclip server (chapter 7), Hermes (chapter 4), and a funded model provider or Ollama. Heartbeats cost real money, so those scripts ask first. They pass `bash -n` and shellcheck here. Your server is their first real run.

## Configuration

`chain-path-b.sh`, `approval-gate.sh`, `run.sh` and `monthly-report.sh` read `PAPERCLIP_API_URL` and `PAPERCLIP_API_KEY` from your shell. Chapter 8 shows where they come from:

```bash
npx paperclipai agent local-cli <agent-ref> -C <company-id> --no-install-skills
```

It prints four `export` lines. Paste them into the shell you run the scripts from. Your provider keys stay in `~/.hermes/.env`, where chapter 4 put them.

## Contributing

Found a command that no longer matches the tool's `--help`? See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT. See [LICENSE](LICENSE).

Educational software, provided as is, with no warranty.
