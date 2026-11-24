#!/usr/bin/env python3
"""Render a single pi session as readable markdown.

Picks a session via --session ID/prefix, --latest, or applies the standard
filters and renders the most recent match. Long tool outputs and assistant
content are truncated so the output stays digestible.

Examples:
  python3 show_session.py --latest
  python3 show_session.py --session 019e475b
  python3 show_session.py --cwd /Volumes/T7/code/blanc --latest
  python3 show_session.py --session 019e475b --max-tool-output 4000
  python3 show_session.py --latest --include-subagents-content
"""

from __future__ import annotations

import argparse
import sys
from datetime import datetime, timezone

import sessions as S


def main() -> int:
    p = argparse.ArgumentParser(description="Render a single session as markdown.")
    p.add_argument("--latest", action="store_true",
                   help="Render the most recent matching session (default if no --session).")
    p.add_argument("--max-tool-output", type=int, default=2000,
                   help="Truncate tool result text to this many chars (default: 2000). "
                        "0 = no truncation.")
    p.add_argument("--max-thinking", type=int, default=600,
                   help="Truncate assistant thinking to this many chars (default: 600). "
                        "0 = no truncation. Set to -1 to omit thinking entirely.")
    p.add_argument("--max-assistant-text", type=int, default=4000,
                   help="Truncate assistant text to this many chars (default: 4000).")
    p.add_argument("--include-subagents-content", action="store_true",
                   help="After the main transcript, also append each subagent's "
                        "transcript inline (can be long).")
    # show_session generally targets a single top-level session. Subagents are
    # off in the *picker* by default; --include-subagents-content controls
    # whether nested transcripts get appended below.
    S.add_filter_args(p, subagents_default=False)
    args = p.parse_args()

    filters = S.filters_from_args(args, subagents_default=False)
    summaries = S.load_summaries(filters)

    if not summaries:
        S.stderr("No matching session.")
        return 1

    target = summaries[0]  # newest first
    if not args.latest and not args.session and len(summaries) > 1:
        S.stderr(f"# {len(summaries)} sessions matched; rendering newest "
                 f"({target.short_id}). Use --session to pick another, or --latest "
                 f"to suppress this warning.")

    _render(target, args)

    if args.include_subagents_content:
        subs = _find_subagents(target.id)
        for sub in subs:
            print()
            print("---")
            print()
            print(f"# Subagent transcript: {sub.path.parent.parent.name}")
            print()
            _render(sub, args)

    return 0


# ---------------------------------------------------------------------------
# Subagent discovery
# ---------------------------------------------------------------------------


def _find_subagents(parent_id: str) -> list:
    out = []
    for path in S.iter_session_files(include_subagents=True):
        if not S.is_subagent_path(path):
            continue
        if S.parent_session_id_from_path(path) == parent_id:
            s = S.summarize_session(path)
            if s:
                out.append(s)
    out.sort(key=lambda s: s.started_at or datetime.min.replace(tzinfo=timezone.utc))
    return out


# ---------------------------------------------------------------------------
# Rendering
# ---------------------------------------------------------------------------


def _render(s: S.SessionSummary, args) -> None:
    # Header block
    print(f"# Session {s.short_id}")
    print()
    print(f"- **cwd**: `{s.cwd}`")
    print(f"- **started**: {S.fmt_short_ts(s.started_at)}")
    if s.last_at and s.started_at:
        dur = s.last_at - s.started_at
        print(f"- **duration**: {_fmt_duration(dur.total_seconds())}")
    print(f"- **models**: {', '.join(sorted(s.models)) or '?'}")
    print(f"- **messages**: {s.message_count} "
          f"({s.user_count} user / {s.assistant_count} assistant / "
          f"{s.tool_result_count} tool)")
    print(f"- **cost**: {S.fmt_money(s.cost_total)} "
          f"(in {S.fmt_money(s.cost_input)} / out {S.fmt_money(s.cost_output)} / "
          f"cacheR {S.fmt_money(s.cost_cache_read)} / cacheW {S.fmt_money(s.cost_cache_write)})")
    print(f"- **tokens**: in {s.tok_input:,} / out {s.tok_output:,} / "
          f"cacheR {s.tok_cache_read:,} / cacheW {s.tok_cache_write:,}")
    if s.error_count:
        print(f"- **errors**: {s.error_count} tool result(s) marked isError")
    print()
    print("---")
    print()

    # Conversation
    last_model = None
    for rec in S.iter_records(s.path):
        t = rec.get("type")
        if t == "model_change":
            last_model = rec.get("modelId")
            print(f"_(model → {last_model})_")
            print()
            continue
        if t != "message":
            continue
        m = rec.get("message") or {}
        role = m.get("role")
        ts = _msg_ts(m)
        if role == "user":
            _render_user(m, ts)
        elif role == "assistant":
            _render_assistant(m, ts, args)
        elif role == "toolResult":
            _render_tool_result(m, ts, args.max_tool_output)


def _render_user(m: dict, ts: str) -> None:
    text = _join_text(m.get("content"))
    print(f"## 👤 User  ·  {ts}")
    print()
    print(text or "_(empty)_")
    print()


def _render_assistant(m: dict, ts: str, args) -> None:
    model = m.get("model") or "?"
    usage = m.get("usage") or {}
    cost = (usage.get("cost") or {}).get("total")
    cost_str = f"  ·  {S.fmt_money(cost)}" if cost else ""
    print(f"## 🤖 Assistant ({model})  ·  {ts}{cost_str}")
    print()
    for c in m.get("content") or []:
        ct = c.get("type")
        if ct == "thinking":
            if args.max_thinking < 0:
                continue
            think = c.get("thinking") or ""
            if args.max_thinking:
                think = S.truncate(think, args.max_thinking)
            print("<details><summary>thinking</summary>")
            print()
            print(think)
            print()
            print("</details>")
            print()
        elif ct == "text":
            text = c.get("text") or ""
            if args.max_assistant_text:
                text = S.truncate(text, args.max_assistant_text)
            if text:
                print(text)
                print()
        elif ct == "toolCall":
            name = c.get("name") or "?"
            args_str = _summarize_tool_args(c.get("arguments") or c.get("input"))
            print(f"**🔧 {name}**  `{args_str}`")
            print()


def _render_tool_result(m: dict, ts: str, max_chars: int) -> None:
    name = m.get("toolName") or "?"
    is_err = m.get("isError")
    badge = " ❌ ERROR" if is_err else ""
    text = _join_text(m.get("content"))
    if max_chars and len(text) > max_chars:
        text = S.truncate(text, max_chars,
                          suffix=f"\n…[{len(text) - max_chars} more chars elided]…")
    print(f"### ↳ {name}{badge}  ·  {ts}")
    print()
    if text:
        # Use a fenced block to preserve indentation.
        print("```")
        print(text)
        print("```")
        print()


def _join_text(content) -> str:
    if not isinstance(content, list):
        return ""
    parts = []
    for c in content:
        if isinstance(c, dict) and c.get("type") == "text":
            t = c.get("text")
            if t:
                parts.append(t)
    return "\n".join(parts)


def _msg_ts(m: dict) -> str:
    ts = m.get("timestamp")
    if isinstance(ts, (int, float)):
        return S.ts_from_ms(int(ts)).astimezone().strftime("%H:%M:%S")
    return "?"


def _summarize_tool_args(arguments) -> str:
    if arguments is None:
        return ""
    if isinstance(arguments, dict):
        # Show first 2-3 args, truncated
        parts = []
        for i, (k, v) in enumerate(arguments.items()):
            if i >= 3:
                parts.append("…")
                break
            v_str = repr(v) if not isinstance(v, str) else v
            parts.append(f"{k}={S.truncate(v_str, 80)}")
        return "  ".join(parts)
    return S.truncate(str(arguments), 120)


def _fmt_duration(secs: float) -> str:
    secs = int(secs)
    if secs < 60:
        return f"{secs}s"
    if secs < 3600:
        return f"{secs // 60}m {secs % 60}s"
    return f"{secs // 3600}h {(secs % 3600) // 60}m"


if __name__ == "__main__":
    sys.exit(main())
