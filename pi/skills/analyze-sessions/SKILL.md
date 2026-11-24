---
name: analyze-sessions
description: Analyze past pi agent sessions stored under ~/.pi/agent/sessions. Use when the user asks about cost (totals, per project, per model, per day), wants to mine prompting patterns from past prompts, view a specific past session, or search across session transcripts.
---

# Analyze Sessions

Tools for querying past pi sessions. All scripts are stdlib Python 3, no dependencies, and read directly from `~/.pi/agent/sessions/`.

## Data shape (one-liner)

Each session is a JSONL file. Records are `session` (header with `cwd`, `id`, `timestamp`), `model_change`, `thinking_level_change`, and `message` (roles: `user`, `assistant`, `toolResult`). Assistant messages carry `usage.cost` already split into input/output/cacheRead/cacheWrite/total — cost analysis is just summing those. Subagent transcripts live nested inside the parent session's directory.

## Scripts

All scripts share the same filter vocabulary (see "Shared filters" below). Run them with `python3` from anywhere:

```bash
python3 ~/.pi/agent/skills/analyze-sessions/scripts/<script>.py [args]
```

### `cost.py` — cost rollups

Subagent costs are **included by default** so totals reflect actual spend. Pass `--show-subagents` to see the subagent share per row, or `--no-subagents` to exclude.

```bash
# Last 7 days, broken down by day (default)
python3 cost.py

# Last 30 days, top 10 projects by spend
python3 cost.py --since 30d --by project --limit 10

# Cost-per-model (each assistant message credited to its own model)
python3 cost.py --since 30d --by model

# The 10 most expensive sessions of the last month
python3 cost.py --since 30d --by session --limit 10

# Cost of one project, all time
python3 cost.py --cwd /path/to/your/project

# Grand total only
python3 cost.py --since 30d --by total

# Machine-readable
python3 cost.py --since 30d --by day --json
```

Groupings: `total`, `day`, `project`, `model`, `session`. When grouping, `--limit` caps groups, not sessions.

### `prompts.py` — dump user prompts for pattern mining

Output is markdown grouped by project (`--format jsonl` available). Prompts above `--max-chars` are dropped because they're almost always pasted context, not actual prompting.

```bash
# Default: markdown dump, max 2000 chars per prompt
python3 prompts.py --since 30d

# Tighter cap, one prompt per JSONL line
python3 prompts.py --since 7d --max-chars 1500 --format jsonl

# One project's prompts
python3 prompts.py --cwd /path/to/your/project --since 30d

# Prompts that mention a topic
python3 prompts.py --grep "rate limit" --since 60d
```

The typical workflow for "find patterns I could turn into global instructions":
1. Run `prompts.py --since 30d` and read the output.
2. Group by recurring themes (same correction repeated across projects, same setup question, same complaint).
3. Propose additions to global `CLAUDE.md` / project AGENTS.md / pi instructions.

### `show_session.py` — render one session as markdown

```bash
# The most recent session
python3 show_session.py --latest

# A specific session by id prefix (8 chars is enough)
python3 show_session.py --session 019e475b

# The most recent session in a project
python3 show_session.py --latest --cwd /path/to/your/project

# Include subagent transcripts inline below
python3 show_session.py --session 019e475b --include-subagents-content

# Drop thinking entirely / show fewer chars
python3 show_session.py --session 019e475b --max-thinking -1 --max-tool-output 800
```

Each tool result is fenced with `…[N more chars elided]…` if truncated. Default truncations: tool output 2000, assistant text 4000, thinking 600. Pass `0` to a limit to disable it, `-1` to `--max-thinking` to omit thinking entirely.

### `search.py` — search across transcripts

Substring by default, regex with `--regex` (smart-case). Searches both user and assistant text by default.

```bash
# Substring across everything
python3 search.py "supabase RLS"

# Only my prompts, last 60 days
python3 search.py "global instruction" --in user --since 60d

# Regex
python3 search.py --regex "TODO\\(.+\\)"

# More context per match
python3 search.py "rate limit" --context 2
```

Each hit prints the session header plus a `python3 show_session.py --session <id>` line so you can drill in directly.

## Shared filters

Available on **all four scripts**:

| Flag | Meaning |
|---|---|
| `--since WHEN` / `--until WHEN` | `YYYY-MM-DD`, ISO datetime, or relative: `7d`, `2w`, `3h`, `30m` |
| `--cwd SUBSTR` | Substring match on the session's real `cwd`. Repeatable. |
| `--model SUBSTR` | Substring match on model id. Repeatable. |
| `--provider {anthropic,openai,google}` | |
| `--session ID` | Session id or prefix (8 chars usually unique) |
| `--include-subagents` / `--no-subagents` | Override the script default |
| `--limit N` | Cap items returned (caps groups, not sessions, for `cost.py` group views) |
| `--min-cost USD` | Drop sessions below this spend |
| `--min-messages N` | Drop short sessions |
| `--errors-only` | Only sessions with at least one `toolResult.isError` |
| `--grep SUBSTR` | Case-insensitive substring on the session's concatenated user prompts |

### Subagent defaults
- `cost.py`: **included** (totals = real spend)
- `prompts.py`, `show_session.py`, `search.py`: **excluded** (a subagent's "user" message is a task description written by another agent, not your prompt)

## Common queries

| Question | Command |
|---|---|
| Total cost in the last 7 days | `python3 cost.py --since 7d --by total` |
| Daily spend trend, last 30 days | `python3 cost.py --since 30d --by day` |
| Most expensive projects this month | `python3 cost.py --since 30d --by project --limit 10` |
| Most expensive sessions ever | `python3 cost.py --by session --limit 10 --until 1d` |
| Cost of one project | `python3 cost.py --cwd /path/to/proj` |
| Patterns in my prompting | `python3 prompts.py --since 30d --max-chars 1500` → read the output |
| What did I do yesterday | `python3 show_session.py --latest --since 1d` |
| Where did the agent struggle | `python3 cost.py --since 30d --errors-only --by session --limit 10` |
| Find old session about X | `python3 search.py "X"` |

## Notes

- All paths are read-only; the scripts never modify session files.
- The library (`scripts/sessions.py`) is reusable: import it for ad-hoc analysis.
- A full scan over a few hundred sessions takes ~1–2 seconds. No caching.
