# Chapter 6: memory

**Three files to start from, and the backup.** `SOUL.example.md` is the identity file from "SOUL.md: The Identity File". `memories/USER.md` and `memories/projects/research-agency.md` are the two memory files the chapter prints. All three are word for word from the book, so they describe J, the book's example operator. Rewrite them first: a SOUL.md that says "You work for a solo developer (J)" makes your agent work for J.

| File | Goes to |
|---|---|
| `SOUL.example.md` | `~/.hermes/SOUL.md` (it replaces the default; keep a copy of yours first) |
| `memories/USER.md` | `~/.hermes/memories/USER.md` |
| `memories/projects/research-agency.md` | `~/.hermes/memories/projects/research-agency.md`, or rename it for your own project, as build step 3 asks |

It's named `SOUL.example.md` so nothing mistakes the repo's copy for a live identity file.

Check: `hermes chat -q "Briefly describe who I am and what I'm working on."` should answer with what you wrote.

## The backup

```bash
chapters/06-memory/backup.sh            # writes into the current folder
chapters/06-memory/backup.sh ~/backups  # or into a folder you pick
```

It tars `SOUL.md`, `memories/`, `skills/personal/` and `config.yaml` from `~/.hermes`: the knowledge-only backup from build step 8. Run against a test home that had no `skills/personal` or `config.yaml` yet, it printed:

```
  skipped (not there): ~/.hermes/skills/personal
  skipped (not there): ~/.hermes/config.yaml
wrote ./hermes-knowledge-20261118.tar.gz (4.0K)
```

The file name carries today's date. Paths inside are relative, so you restore with `tar xzf hermes-knowledge-<date>.tar.gz -C ~/.hermes`. Why it differs from the printed command: [BOOK-FIXES.md](../../BOOK-FIXES.md#chapter-6-the-knowledge-backup-exits-1-when-a-path-is-missing).
