#!/bin/bash
# sync.command — sync this website (duc-v-le.github.io) with GitHub.
# Order: get GitHub changes -> save (commit) your edits -> push. Double-click in Finder.
cd "$(dirname "$0")" || exit 1
TOP="$(git rev-parse --show-toplevel 2>/dev/null)"
[ -n "$TOP" ] && cd "$TOP" || { echo "Not inside a git repository."; read -r -p "Press Enter..."; exit 1; }
export PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:$PATH"

echo "======================================================"
echo "  Sync website (duc-v-le.github.io)  <->  GitHub"
echo "======================================================"
git fetch origin -q 2>/dev/null

if [ -n "$(git status --porcelain)" ]; then
  echo
  echo "Local changes:"
  git status -s
  echo
  read -r -p "Describe these changes to save them (Enter to skip): " msg
  if [ -n "$msg" ]; then git add -A && git commit -m "$msg" && echo "  ...saved."; fi
fi

echo
echo "--- Getting changes from GitHub ---"
if ! git pull --no-edit origin main; then
  echo; echo "!! Pull stopped (a conflict needs your attention). Fix it, then run this again."
  read -r -p "Press Enter to close..."; exit 1
fi

echo
echo "--- Sending your changes to GitHub ---"
AHEAD="$(git rev-list --count origin/main..main 2>/dev/null || echo 0)"
if [ "$AHEAD" -eq 0 ]; then
  echo "Nothing new to send — GitHub already has everything. Site unchanged."
else
  echo "Sending $AHEAD commit(s)..."
  if ! git push origin main; then
    echo
    echo "!! PUSH FAILED — nothing reached GitHub. Your live site is UNCHANGED."
    echo "   The error above says why. Fix it, then run this again."
    git log --oneline -3
    read -r -p "Press Enter to close..."; exit 1
  fi
  echo
  echo "=== Sent. Your live site updates at https://duc-v-le.github.io in ~1 minute. ==="
fi

git log --oneline -3
read -r -p "Press Enter to close..."
