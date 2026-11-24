#!/usr/bin/env python3
"""Search across pi session transcripts.

Finds sessions where PATTERN matches user prompts and/or assistant text.
Default scope is both. Use --in to restrict.

Examples:
  python3 search.py "supabase RLS"
  python3 search.py --regex "TODO\\(.+\\)"
  python3 search.py "global instruction" --in user --since 60d
  python3 search.py "rate limit" --context 2 --since 30d
"""

from __future__ import annotations

import argparse
import re
import sys

import sessions as S


def main() -> int:
    p = argparse.ArgumentParser(description="Search across session transcripts.")
    p.add_argument("pattern", help="Search pattern (literal substring by default).")
    p.add_argument("--regex", action="store_true",
                   help="Treat PATTERN as a Python regex (case-insensitive unless it contains uppercase).")
    p.add_argument("--in", dest="scope", choices=["user", "assistant", "both"],
                   default="both",
                   help="Where to search (default: both).")
    p.add_argument("--context", type=int, default=1,
                   help="Lines of surrounding context per match (default: 1).")
    p.add_argument("--max-matches-per-session", type=int, default=5,
                   help="Stop searching a session after this many matches (default: 5).")
    p.add_argument("--snippet-chars", type=int, default=300,
                   help="Max characters per snippet (default: 300).")
    S.add_filter_args(p, subagents_default=False)
    args = p.parse_args()

    # Build a matcher
    if args.regex:
        # Smart case
        flags = 0 if any(ch.isupper() for ch in args.pattern) else re.IGNORECASE
        try:
            rx = re.compile(args.pattern, flags)
        except re.error as e:
            S.stderr(f"invalid regex: {e}")
            return 2
        matcher = rx.search
        finditer = rx.finditer
    else:
        needle = args.pattern.lower()
        def matcher(text: str):  # noqa: E306
            return needle in text.lower()
        def finditer(text: str):  # noqa: E306
            low = text.lower()
            start = 0
            while True:
                i = low.find(needle, start)
                if i < 0:
                    return
                yield _SubMatch(i, i + len(needle))
                start = i + max(1, len(needle))

    filters = S.filters_from_args(args, subagents_default=False)
    summaries = S.load_summaries(filters)

    total_hits = 0
    sessions_with_hits = 0
    for s in summaries:
        hits = _search_session(s, args.scope, matcher, finditer,
                               args.max_matches_per_session, args.context,
                               args.snippet_chars)
        if not hits:
            continue
        sessions_with_hits += 1
        total_hits += len(hits)
        _print_session_hits(s, hits)

    S.stderr(f"# {total_hits} match(es) across {sessions_with_hits} session(s) "
             f"(scanned {len(summaries)}).")
    return 0


class _SubMatch:
    """Tiny stand-in for re.Match so substring search can share the code path."""
    __slots__ = ("_s", "_e")

    def __init__(self, s: int, e: int):
        self._s, self._e = s, e

    def start(self) -> int:
        return self._s

    def end(self) -> int:
        return self._e


def _search_session(s: S.SessionSummary, scope: str, matcher, finditer,
                    cap: int, context_lines: int, snippet_chars: int):
    hits = []
    for rec in S.iter_records(s.path):
        if rec.get("type") != "message":
            continue
        m = rec.get("message") or {}
        role = m.get("role")
        if role == "user" and scope in ("user", "both"):
            text = _join_text(m.get("content"))
            hits.extend(_collect(text, "user", matcher, finditer, context_lines,
                                 snippet_chars))
        elif role == "assistant" and scope in ("assistant", "both"):
            for c in m.get("content") or []:
                if c.get("type") == "text":
                    text = c.get("text") or ""
                    hits.extend(_collect(text, "assistant", matcher, finditer,
                                         context_lines, snippet_chars))
                elif c.get("type") == "thinking":
                    text = c.get("thinking") or ""
                    hits.extend(_collect(text, "thinking", matcher, finditer,
                                         context_lines, snippet_chars))
        if len(hits) >= cap:
            hits = hits[:cap]
            break
    return hits


def _collect(text: str, kind: str, matcher, finditer, context_lines: int,
             snippet_chars: int):
    if not text or not matcher(text):
        return []
    out = []
    lines = text.splitlines()
    # Find which line each match falls in, dedupe by line.
    matched_lines = set()
    for mt in finditer(text):
        # Convert offset to line number
        offset = mt.start()
        line_no = text.count("\n", 0, offset)
        matched_lines.add(line_no)
    for ln in sorted(matched_lines):
        lo = max(0, ln - context_lines)
        hi = min(len(lines), ln + context_lines + 1)
        snippet = "\n".join(lines[lo:hi])
        snippet = S.truncate(snippet, snippet_chars)
        out.append({"kind": kind, "line": ln + 1, "snippet": snippet})
    return out


def _print_session_hits(s: S.SessionSummary, hits) -> None:
    print(f"── {S.fmt_short_ts(s.started_at)}  ·  {s.short_id}  ·  "
          f"{S.fmt_money(s.cost_total)}  ·  {s.cwd}")
    print(f"   view: python3 show_session.py --session {s.short_id}")
    for h in hits:
        print(f"   [{h['kind']} L{h['line']}]")
        for line in h["snippet"].splitlines():
            print(f"     {line}")
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


if __name__ == "__main__":
    sys.exit(main())
