#!/usr/bin/env bash
# Links this repo's pi/ config into the Pi agent directory.
# Secrets are never stored here. Auth is resolved at runtime from $OPENCODE_API_KEY.
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
AGENT_DIR="${PI_CODING_AGENT_DIR:-$HOME/.pi/agent}"
mkdir -p "$AGENT_DIR"

link_file() {
  local src="$1" dest="$2"
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    mv "$dest" "$dest.bak.$(date '+%Y%m%d_%H%M%S')"
    echo "backed up $dest"
  fi
  ln -sfn "$src" "$dest"
  echo "linked $dest -> $src"
}

link_file "$REPO_DIR/pi/settings.json" "$AGENT_DIR/settings.json"
link_file "$REPO_DIR/pi/AGENTS.md" "$AGENT_DIR/AGENTS.md"
for d in skills prompts extensions themes models.json; do
  if [ -e "$REPO_DIR/pi/$d" ]; then
    link_file "$REPO_DIR/pi/$d" "$AGENT_DIR/$d"
  fi
done

if [ ! -f "$AGENT_DIR/auth.json" ]; then
  printf '%s' '{"opencode-go": {"type": "api_key", "key": "!printenv OPENCODE_API_KEY"}}' > "$AGENT_DIR/auth.json"
  chmod 600 "$AGENT_DIR/auth.json"
  echo "created $AGENT_DIR/auth.json (set OPENCODE_API_KEY in your shell)"
else
  echo "kept existing $AGENT_DIR/auth.json"
fi

pi auth check --provider opencode-go
