# pi config

Pi agent config, stored as code. Machine setup links it into `~/.pi/agent`.
Skills, prompts, extensions, and themes can grow here as sibling folders.

## Layout

- `settings.json` — provider, default model, compaction. Never put keys here.
- `AGENTS.md` — working instructions for Bodmash, applied across directories.
- `setup.sh` — symlinks everything into the agent dir and creates a local-only
  `auth.json` that resolves the key from `$OPENCODE_API_KEY` at runtime.

## Setup on a new machine

```bash
export OPENCODE_API_KEY=<key>
./pi/setup.sh
pi auth check --provider opencode-go
pi --print --no-session --model "opencode-go/muse-spark-1.3-contributor" \
  "Respond with exactly: PI_SMOKE_OK"
```
