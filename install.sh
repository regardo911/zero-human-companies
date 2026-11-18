#!/usr/bin/env bash
# copies the book's 11 skills (chapter 5 and chapter 10) into ~/.hermes/skills/<category>/.
# default category is personal, the one chapter 5's build step uses.
# never overwrites: a skill folder you already have may hold your own edits.
set -euo pipefail

if [ "$#" -gt 1 ]; then
  echo "usage: $0 [category]   (default: personal)" >&2
  exit 2
fi
category=${1:-personal}
case "$category" in
  */*|.*|"") echo "category must be a plain folder name, like personal" >&2; exit 2 ;;
esac

here=$(cd "$(dirname "$0")" && pwd)
hermes_home="$HOME/.hermes"

if [ ! -d "$hermes_home" ]; then
  echo "Hermes is not installed yet: ~/.hermes does not exist."
  echo "Chapter 4 installs it. Check your machine first: ./chapters/01-setup-check/check-prereqs.sh"
  exit 1
fi

dest="$hermes_home/skills/$category"
mkdir -p "$dest"

copied=0 kept=0
for skill in "$here"/chapters/05-skills/*/SKILL.md "$here"/chapters/10-five-businesses/skills/*/SKILL.md; do
  dir=$(dirname "$skill")
  name=$(basename "$dir")
  if [ -e "$dest/$name" ]; then
    printf '  %-26s exists, left alone\n' "$name"
    kept=$((kept + 1))
  else
    cp -R "$dir" "$dest/$name"
    printf '  %-26s copied\n' "$name"
    copied=$((copied + 1))
  fi
done

echo
echo "$copied copied, $kept left alone, into $dest"
echo "next: hermes skills list"
echo "      hermes skills inspect standup-notes"
