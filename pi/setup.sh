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

# Every shell must export OPENCODE_API_KEY for the `!printenv` in auth.json
# to resolve. Install a ~/.zshenv hook that sources the live key from the
# gateway dotenv at runtime; the key itself is never written anywhere.
ZSHENV="$HOME/.zshenv"
if ! grep -qF "# pi agent (swapkats/dotfiles)" "$ZSHENV" 2>/dev/null; then
  cat >> "$ZSHENV" <<'EOF'

# pi agent (swapkats/dotfiles): resolve OPENCODE_API_KEY from the gateway
# dotenv at runtime. The key itself is never stored in this file or any repo.
_pi_oc_key="$(sed -n 's/^OPENCODE_GO_API_KEY=//p' "$HOME/.hermes/.env" 2>/dev/null | tail -n 1)"
case "$_pi_oc_key" in \"*\") _pi_oc_key="${_pi_oc_key#\"}"; _pi_oc_key="${_pi_oc_key%\"}";; esac
case "$_pi_oc_key" in \'*\') _pi_oc_key="${_pi_oc_key#\'}"; _pi_oc_key="${_pi_oc_key%\'}";; esac
[ -n "$_pi_oc_key" ] && export OPENCODE_API_KEY="$_pi_oc_key"
unset _pi_oc_key
EOF
  echo "added OPENCODE_API_KEY resolver hook to $ZSHENV"
else
  echo "kept existing $ZSHENV resolver"
fi

# The shell that launched this script predates the hook; export the key now
# so the auth check below works on first run. On machines without the gateway
# dotenv, `export OPENCODE_API_KEY=<key>` manually instead.
if [ -z "${OPENCODE_API_KEY:-}" ] && [ -f "$HOME/.hermes/.env" ]; then
  _oc="$(sed -n 's/^OPENCODE_GO_API_KEY=//p' "$HOME/.hermes/.env" | tail -n 1)"
  _oc="${_oc%\"}"; _oc="${_oc#\"}"; _oc="${_oc%\'}"; _oc="${_oc#\'}"
  if [ -n "$_oc" ]; then
    export OPENCODE_API_KEY="$_oc"
  fi
  unset _oc
fi

pi auth check --provider opencode-go
