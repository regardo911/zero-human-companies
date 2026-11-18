#!/usr/bin/env bash
# checks the tools the book needs (chapter 1, reader setup check) and prints each version.
# adds jq (chapters 8, 10, 11) and bc (chapter 11) to the book's four.
# read-only: it installs nothing. exit 1 if a required tool is missing.
set -euo pipefail

if [ "$#" -ne 0 ]; then
  echo "usage: $0   (no arguments)" >&2
  exit 2
fi

missing=0

# print "name  version" or "name  missing  hint". $1 name, $2 hint, rest = version command
show() {
  local name=$1 hint=$2; shift 2
  if command -v "$name" >/dev/null 2>&1; then
    local v
    v=$("$@" 2>&1 | head -1) || v="(installed, version flag failed)"
    printf '  %-8s %s\n' "$name" "$v"
    return 0
  fi
  printf '  %-8s missing  %s\n' "$name" "$hint"
  return 1
}

echo "required"
show node    "install Node 20+ from nodejs.org or: brew install node"        node --version    || missing=1
show python3 "install Python 3.11+ from python.org or your package manager"  python3 --version || missing=1
show curl    "install curl with your package manager"                         curl --version    || missing=1
show git     "install git from git-scm.com or your package manager"           git --version     || missing=1
show jq      "brew install jq   or   sudo apt-get install jq"                 jq --version      || missing=1
# some bc builds have no --version flag; then it just says installed
show bc      "brew install bc   or   sudo apt-get install bc"                 sh -c 'bc --version 2>/dev/null || echo "installed"' || missing=1

echo
echo "later chapters (information only)"
show hermes  "chapter 4 installs it"                     hermes --version || true
show docker  "optional, chapter 9 (external Postgres)"   docker --version || true
# ollama prints a warning instead of a clean line when its server is down; keep just the number
ollama_version() {
  local v
  v=$(ollama --version 2>&1 | grep -Eo '[0-9]+\.[0-9]+\.[0-9]+' | tail -1) || true
  echo "ollama ${v:-installed}"
}
show ollama  "optional, chapter 3 (local models, \$0)"   ollama_version || true

echo
if [ "$missing" -eq 1 ]; then
  echo "install the missing tools above, then run this again."
  exit 1
fi
echo "all six required tools found. next: chapter 4 installs Hermes."
