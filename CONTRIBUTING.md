# Contributing

Hermes and Paperclip ship often. The most useful thing you can send is a report that a file here stopped matching a tool.

Open an issue with:

- the file, and the chapter it comes from
- the command you ran and what it printed (scrub ids and keys first)
- `hermes --version` and `npx paperclipai --version`

A fix that changes a book file (a skill, an agent config, a memory example) needs a `BOOK-FIXES.md` entry with the output that proves it, the same shape as the ones there now. Keep the book's names: a reader holding the print has to recognize every file.

Before a pull request:

```bash
bash tests/run.sh
```

It needs bash plus the six tools `check-prereqs.sh` looks for (node, python3, curl, git, jq, bc). shellcheck is optional locally; CI always runs it. It runs offline. Point anything that writes to `~` at a throwaway home, the way the tests do: `H=$(mktemp -d); mkdir "$H/.hermes"; env HOME=$H ./install.sh`.

Scripts stay plain bash that runs on macOS's bash 3.2 and on Linux: no associative arrays, no `mapfile`, no `${var,,}`. Anything that runs a heartbeat asks for a typed `yes`, with no flag to skip it.
