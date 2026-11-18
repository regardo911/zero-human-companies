#!/usr/bin/env bash
# backs up the hermes knowledge layer: chapter 6, build step 8 (ch06.md fence 321-327 naming).
# changed from the book: a path you don't have is skipped by name (the printed 2>/dev/null
# hides the warning but tar still exits 1), and paths are stored relative to ~/.hermes.
set -euo pipefail

if [ "$#" -gt 1 ]; then
  echo "usage: $0 [output-dir]   (default: current folder)" >&2
  exit 2
fi
outdir=${1:-.}
[ -d "$outdir" ] || { echo "no such folder: $outdir" >&2; exit 2; }

h="$HOME/.hermes"
[ -d "$h" ] || { echo "nothing to back up: $h does not exist (chapter 4 installs Hermes)"; exit 1; }

items=""
for p in SOUL.md memories skills/personal config.yaml; do
  if [ -e "$h/$p" ]; then
    items="$items $p"
  else
    echo "  skipped (not there): ~/.hermes/$p"
  fi
done
[ -n "$items" ] || { echo "none of SOUL.md, memories, skills/personal, config.yaml exist yet"; exit 1; }

out="$outdir/hermes-knowledge-$(date +%Y%m%d).tar.gz"
# relative paths inside the archive, so it restores with: tar xzf <file> -C ~/.hermes
# shellcheck disable=SC2086
tar czf "$out" -C "$h" $items
echo "wrote $out ($(du -h "$out" | cut -f1 | tr -d ' '))"
