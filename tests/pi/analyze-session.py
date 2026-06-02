#!/usr/bin/env python3
"""
Analyze a Pi session transcript (JSONL) to show token usage,
cost, and subagent breakdown.

Usage:
    python3 tests/pi/analyze-session.py <session-file.jsonl>
"""

import json
import sys
from collections import defaultdict
from pathlib import Path


def analyze_session(session_file: str) -> None:
    if not Path(session_file).exists():
        print(f"Error: File not found: {session_file}")
        sys.exit(1)

    entries = []
    with open(session_file) as f:
        for line in f:
            line = line.strip()
            if line:
                try:
                    entries.append(json.loads(line))
                except json.JSONDecodeError:
                    continue

    total_input = 0
    total_output = 0
    total_cache_read = 0
    total_cache_write = 0
    message_count = 0
    tool_calls = defaultdict(int)

    for entry in entries:
        if entry.get("role") in ("user", "assistant"):
            message_count += 1

        tool_calls_data = entry.get("tool_calls") or []
        for tc in tool_calls_data:
            tool_name = tc.get("function", {}).get("name", "unknown")
            tool_calls[tool_name] += 1

        usage = entry.get("usage")
        if usage:
            total_input += usage.get("input_tokens", 0)
            total_output += usage.get("output_tokens", 0)
            total_cache_read += usage.get("cache_read_input_tokens", 0)
            total_cache_write += usage.get("cache_creation_input_tokens", 0)

    print("=" * 60)
    print(" Pi Session Analysis")
    print("=" * 60)
    print(f"\n  Messages: {message_count}")
    print(f"  Tool calls: {sum(tool_calls.values())}")
    print()

    if tool_calls:
        print("  Tool Usage:")
        print("  " + "-" * 54)
        for name, count in sorted(tool_calls.items()):
            print(f"  {name:<30} {count:>4}")
        print()

    print("  Token Usage:")
    print("  " + "-" * 54)
    print(f"  {'Input tokens:':<30} {total_input:>10,}")
    print(f"  {'Output tokens:':<30} {total_output:>10,}")
    print(f"  {'Cache read tokens:':<30} {total_cache_read:>10,}")
    print(f"  {'Cache write tokens:':<30} {total_cache_write:>10,}")
    print(f"  {'Total tokens:':<30} {total_input + total_output:>10,}")

    cost_input = total_input * 3 / 1_000_000
    cost_output = total_output * 15 / 1_000_000
    cost_cache_read = total_cache_read * 0.30 / 1_000_000
    cost_cache_write = total_cache_write * 3.75 / 1_000_000
    total_cost = cost_input + cost_output + cost_cache_read + cost_cache_write

    print()
    print("  Cost Estimate (Claude Sonnet):")
    print("  " + "-" * 54)
    print(f"  {'Input:':<30} ${cost_input:>9.4f}")
    print(f"  {'Output:':<30} ${cost_output:>9.4f}")
    print(f"  {'Cache read:':<30} ${cost_cache_read:>9.4f}")
    print(f"  {'Cache write:':<30} ${cost_cache_write:>9.4f}")
    print(f"  {'Total:':<30} ${total_cost:>9.4f}")
    print()

    print("=" * 60)


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <session-file.jsonl>")
        sys.exit(1)
    analyze_session(sys.argv[1])
