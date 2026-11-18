# Chapter 5: skills

Two skills from chapter 5, exactly as printed: `standup-notes` from the build step, and `my-research-workflow` from "Authoring Your Own Skill".

`./install.sh` from the repo root copies both into `~/.hermes/skills/personal/`, along with chapter 10's nine. To do just these two by hand:

```bash
mkdir -p ~/.hermes/skills/personal
cp -R chapters/05-skills/standup-notes chapters/05-skills/my-research-workflow ~/.hermes/skills/personal/
```

## Check it worked

```bash
hermes skills inspect standup-notes
hermes -s standup-notes
```

Describe yesterday's work in the session. You should get three lines back, `Yesterday:`, `Today:` and `Blockers:`, not a paragraph. If you get a paragraph, the frontmatter is the usual suspect: two spaces under `metadata:`, two more under `hermes:`.

For the research one, the book's own test:

```bash
hermes -s my-research-workflow chat -q "Research the top 5 Python web frameworks"
```

A table first, then a recommendation section.

## Make them yours

- Change `author: Your Name`. Both files carry it.
- The folder name and the `name:` line must stay identical, or Hermes skips the skill. `bash tests/run.sh` checks every skill in this repo for that; copy the habit when you write your own.
- The chapter's build step also has you install one hub skill. That one comes from `hermes skills search` on your machine, so it isn't here.
