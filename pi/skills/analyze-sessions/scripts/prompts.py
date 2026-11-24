#!/usr/bin/env python3
"""Dump user prompts across pi sessions for pattern analysis.

By default returns markdown grouped by project (cwd), newest first, with one
section per session containing each user prompt in that session.

Prompts longer than --max-chars are dropped (they're almost always pasted
context, not actual prompting), so the output is suitable for handing to a
model that's looking for prompting patterns.

Examples:
  python3 prompts.py --since 30d
  python3 prompts.py --since 7d --max-chars 1500 --format jsonl
  python3 prompts.py --cwd /Volumes/T7/code/blanc --since 30d
  python3 prompts.py --grep "global instruction"
"""

from __future__ import annotations

import argparse
import json
import sys
from collections import defaultdict

import sessions as S


def main() -> int:
    p = argparse.ArgumentParser(description="Dump user prompts for pattern analysis.")
    p.add_argument("--format", choices=["md", "jsonl"], default="md",
                   help="Output format (default: md).")
    p.add_argument("--max-chars", type=int, default=2000,
                   help="Drop prompts longer than this (default: 2000). 0 = no limit.")
    p.add_argument("--min-chars", type=int, default=1,
                   help="Drop prompts shorter than this (default: 1).")
    # Subagents OFF by default: their "user" messages are agent-authored task
    # descriptions, not your prompts.
    S.add_filter_args(p, subagents_default=False)
    args = p.parse_args()

    filters = S.filters_from_args(args, subagents_default=False)
    summaries = S.load_summaries(filters)

    # Re-scan each matching session and collect its user prompts.
    sess_prompts = []  # list of (summary, [prompts])
    total_prompts = 0
    for s in summaries:
        prompts = _collect_prompts(s.path, args.max_chars, args.min_chars)
        if not prompts:
            continue
        sess_prompts.append((s, prompts))
        total_prompts += len(prompts)

    if not sess_prompts:
        S.stderr("No prompts matched.")
        return 0

    if args.format == "jsonl":
        for s, prompts in sess_prompts:
            for ts_ms, text in prompts:
                out = {
                    "session_id": s.id,
                    "cwd": s.cwd,
                    "timestamp": ts_ms,
                    "text": text,
                }
                print(json.dumps(out, ensure_ascii=False))
        S.stderr(f"# {total_prompts} prompts across {len(sess_prompts)} sessions")
        return 0

    _render_markdown(sess_prompts, total_prompts)
    return 0


def _collect_prompts(path, max_chars: int, min_chars: int):
    """Walk the session JSONL and return [(timestamp_ms, text), ...] for user
    messages within the length window."""
    out = []
    for rec in S.iter_records(path):
        if rec.get("type") != "message":
            continue
        m = rec.get("message") or {}
        if m.get("role") != "user":
            continue
        text = _extract_text(m.get("content"))
        if not text:
            continue
        n = len(text)
        if n < min_chars:
            continue
        if max_chars and n > max_chars:
            continue
        out.append((m.get("timestamp"), text))
    return out


def _extract_text(content) -> str:
    if not isinstance(content, list):
        return ""
    chunks = []
    for c in content:
        if isinstance(c, dict) and c.get("type") == "text":
            t = c.get("text")
            if t:
                chunks.append(t)
    return "\n".join(chunks)


def _render_markdown(sess_prompts, total_prompts: int) -> None:
    # Group by project (cwd), newest first within each group, project order by
    # most recent session.
    by_proj = defaultdict(list)
    for s, prompts in sess_prompts:
        by_proj[s.cwd or "?"].append((s, prompts))

    proj_order = sorted(by_proj.keys(),
                        key=lambda k: max((s.started_at for s, _ in by_proj[k]
                                           if s.started_at), default=None) or 0,
                        reverse=True)

    print(f"# Pi prompts dump")
    print(f"_{total_prompts} prompts across {len(sess_prompts)} sessions, "
          f"{len(by_proj)} projects._")
    print()

    for proj in proj_order:
        print(f"## {proj}")
        print()
        # newest session first
        for s, prompts in sorted(by_proj[proj],
                                 key=lambda x: x[0].started_at or 0,
                                 reverse=True):
            print(f"### {S.fmt_short_ts(s.started_at)}  ·  `{s.short_id}`  "
                  f"·  {len(prompts)} prompt{'s' if len(prompts) != 1 else ''}")
            print()
            for _, text in prompts:
                # Indent as blockquote to keep prompts visually distinct.
                for line in text.splitlines() or [""]:
                    print(f"> {line}")
                print()


if __name__ == "__main__":
    sys.exit(main())
