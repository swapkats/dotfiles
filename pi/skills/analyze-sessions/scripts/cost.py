#!/usr/bin/env python3
"""Cost rollups across pi sessions.

Examples:
  python3 cost.py                                # last 7d, by day
  python3 cost.py --since 30d --by project
  python3 cost.py --since 30d --by model
  python3 cost.py --cwd /Volumes/T7/code/blanc   # one project, all time
  python3 cost.py --since 30d --by session --limit 10 --show-subagents
"""

from __future__ import annotations

import argparse
import json
import sys
from collections import defaultdict
from datetime import datetime, timezone
from pathlib import Path

import sessions as S


GROUPINGS = ["total", "day", "project", "model", "session"]


def main() -> int:
    p = argparse.ArgumentParser(description="Cost rollups across pi sessions.")
    p.add_argument("--by", choices=GROUPINGS, default="day",
                   help="Grouping for the breakdown table (default: day). "
                        "'total' prints only the grand total.")
    p.add_argument("--show-subagents", action="store_true",
                   help="Also print a row with the subagent share for each group.")
    p.add_argument("--json", action="store_true", help="Emit JSON instead of a table.")
    # Subagents are INCLUDED by default for cost so the totals reflect real spend.
    S.add_filter_args(p, subagents_default=True)
    args = p.parse_args()

    # Default to last 7 days if no date filter given.
    if not args.since and not args.until and not args.session:
        args.since = "7d"

    filters = S.filters_from_args(args, subagents_default=True)
    # For grouped views, --limit caps groups, not sessions. Drop it from the
    # session-level filter so grouping sees every matching session.
    group_limit = args.limit if args.by != "total" else None
    if args.by != "total":
        filters.limit = None

    summaries = S.load_summaries(filters)

    if not summaries:
        S.stderr("No sessions matched.")
        return 0

    if args.json:
        report = build_report(summaries, args.by)
        print(json.dumps(report, indent=2, default=str))
        return 0

    if args.by == "total":
        print_grand_total(summaries)
        return 0

    print_grand_total(summaries)
    print()
    print_grouped(summaries, args.by, show_subagents=args.show_subagents,
                  limit=group_limit)
    return 0


# ---------------------------------------------------------------------------
# Grouping
# ---------------------------------------------------------------------------


def session_keys(s: S.SessionSummary, by: str):
    """Return the group key(s) a session contributes to, and a per-key cost
    override. For 'model' a session can split across multiple keys, and we
    re-scan the file to credit per-message cost. For everything else it's a
    single key with full session cost."""
    if by == "day":
        k = (s.started_at.astimezone().strftime("%Y-%m-%d")
             if s.started_at else "unknown")
        yield k, s.cost_total
    elif by == "project":
        yield (s.cwd or "?"), s.cost_total
    elif by == "session":
        yield s.id, s.cost_total
    elif by == "model":
        # Walk assistant messages to credit each one's cost to its model.
        per_model = defaultdict(float)
        for rec in S.iter_records(s.path):
            if rec.get("type") != "message":
                continue
            m = rec.get("message") or {}
            if m.get("role") != "assistant":
                continue
            model = m.get("model") or "?"
            cost = ((m.get("usage") or {}).get("cost") or {}).get("total") or 0
            per_model[model] += float(cost)
        if not per_model and s.models:
            # Fall back to splitting evenly across the session's models.
            share = s.cost_total / len(s.models)
            for mdl in s.models:
                per_model[mdl] = share
        for k, v in per_model.items():
            yield k, v
    else:
        yield "all", s.cost_total


def build_report(summaries, by: str) -> dict:
    rows = defaultdict(lambda: dict(cost=0.0, sessions=0, messages=0, errors=0,
                                    sub_cost=0.0, sub_sessions=0))
    for s in summaries:
        for k, cost in session_keys(s, by):
            r = rows[k]
            r["cost"] += cost
            r["sessions"] += 1
            r["messages"] += s.message_count
            r["errors"] += s.error_count
            if s.is_subagent:
                r["sub_cost"] += cost
                r["sub_sessions"] += 1
    return {
        "grouping": by,
        "total_cost": sum(s.cost_total for s in summaries),
        "total_sessions": len(summaries),
        "groups": dict(rows),
    }


# ---------------------------------------------------------------------------
# Printing
# ---------------------------------------------------------------------------


def print_grand_total(summaries) -> None:
    total = sum(s.cost_total for s in summaries)
    top_level = [s for s in summaries if not s.is_subagent]
    sub = [s for s in summaries if s.is_subagent]
    tok_in = sum(s.tok_input for s in summaries)
    tok_out = sum(s.tok_output for s in summaries)
    cache_r = sum(s.cost_cache_read for s in summaries)
    cache_w = sum(s.cost_cache_write for s in summaries)

    print(f"Total cost:  {S.fmt_money(total)}")
    print(f"  sessions:  {len(top_level)} top-level"
          + (f"  +  {len(sub)} subagent" if sub else ""))
    print(f"  cache:     read {S.fmt_money(cache_r)}   write {S.fmt_money(cache_w)}")
    print(f"  tokens:    in {tok_in:,}   out {tok_out:,}")
    if summaries:
        first = min((s.started_at for s in summaries if s.started_at), default=None)
        last = max((s.started_at for s in summaries if s.started_at), default=None)
        if first and last:
            print(f"  window:    {S.fmt_short_ts(first)}  →  {S.fmt_short_ts(last)}")


def print_grouped(summaries, by: str, *, show_subagents: bool, limit) -> None:
    report = build_report(summaries, by)
    groups = report["groups"]

    # Sort: day asc (chronological), session desc by cost, others desc by cost
    items = list(groups.items())
    if by == "day":
        items.sort(key=lambda kv: kv[0])
    else:
        items.sort(key=lambda kv: kv[1]["cost"], reverse=True)

    if limit and by != "day":
        items = items[:limit]

    label = {"day": "DATE", "project": "PROJECT", "model": "MODEL",
             "session": "SESSION"}[by]
    # Compute column widths
    keycol = max(len(label), max((len(_render_key(k, by)) for k, _ in items), default=4))
    keycol = min(keycol, 70)

    headers = [label.ljust(keycol), "COST".rjust(10), "SESS".rjust(5),
               "MSGS".rjust(6), "ERR".rjust(5)]
    if show_subagents:
        headers.append("SUB$".rjust(9))
    print("  ".join(headers))
    print("  ".join("-" * len(h) for h in headers))

    for k, r in items:
        key_disp = _render_key(k, by)
        if len(key_disp) > keycol:
            key_disp = "…" + key_disp[-(keycol - 1):]
        row = [
            key_disp.ljust(keycol),
            S.fmt_money(r["cost"]).rjust(10),
            str(r["sessions"]).rjust(5),
            str(r["messages"]).rjust(6),
            str(r["errors"]).rjust(5),
        ]
        if show_subagents:
            row.append(S.fmt_money(r["sub_cost"]).rjust(9))
        print("  ".join(row))


def _render_key(k: str, by: str) -> str:
    if by == "session":
        return k[:8] if k else "?"
    return k or "?"


if __name__ == "__main__":
    sys.exit(main())
