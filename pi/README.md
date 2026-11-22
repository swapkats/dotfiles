# pi config

Pi agent config, stored as code. Machine setup links it into `~/.pi/agent`.
Skills, prompts, extensions, and themes can grow here as sibling folders.

## Layout

- `settings.json` — provider, default model, compaction. Never put keys here.
- `AGENTS.md` — working instructions for Bodmash, applied across directories.
- `setup.sh` — symlinks everything into the agent dir, creates a local-only
  `auth.json` that resolves the key from `$OPENCODE_API_KEY` at runtime, and
  installs a `~/.zshenv` hook that sources `OPENCODE_API_KEY` from the gateway
  dotenv (`OPENCODE_GO_API_KEY`) in every shell.

## Setup on a new machine

```bash
./pi/setup.sh
pi auth check --provider opencode-go
pi --print --no-session --model "opencode-go/muse-spark-1.3-contributor" \
  "Respond with exactly: PI_SMOKE_OK"
```

`setup.sh` handles auth end to end: it exports `OPENCODE_API_KEY` for the
current shell from the gateway dotenv and installs the `~/.zshenv` hook so
future shells resolve it too. On a machine without the gateway dotenv, export
`OPENCODE_API_KEY=<key>` in your shell before running the script.
