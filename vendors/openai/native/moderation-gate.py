#!/usr/bin/env python3
"""Runtime guardrail pattern: screen user input with the OpenAI Moderation API
before it reaches a model.  Control: AIG-10 (runtime guardrails & content safety).

Endpoint and model verified 2026-10-13 against
https://developers.openai.com/api/docs/guides/moderation.md :
  POST https://api.openai.com/v1/moderations
  {"model": "omni-moderation-latest", "input": "..."}
  -> {"results": [{"flagged": bool, "categories": {...}, "category_scores": {...}}]}

The Moderation API is free to use and accepts text and images (no audio).
OpenAI notes that scores are signals for *your* policy, not an automatic
blocking decision: this example blocks on `flagged` and on a stricter
category list you can tune.

Standard library only (urllib). Uses a normal project API key from
OPENAI_API_KEY (Admin keys cannot call non-administration endpoints).

Usage (example only; do not wire into production without review):
    echo "text to check" | OPENAI_API_KEY=... python3 moderation-gate.py
Exit code 0 = allowed, 3 = blocked, 1 = error (fail closed).
"""

from __future__ import annotations

import json
import os
import sys
import urllib.error
import urllib.request

MODERATION_URL = os.environ.get("OPENAI_MODERATION_URL", "https://api.openai.com/v1/moderations")
MODEL = "omni-moderation-latest"

# Categories that always block, even below OpenAI's own `flagged` threshold,
# when their score exceeds STRICT_THRESHOLD. Category names are verbatim from
# the moderation guide.
STRICT_CATEGORIES = ("sexual/minors", "self-harm/instructions", "illicit/violent", "hate/threatening")
STRICT_THRESHOLD = float(os.environ.get("MODERATION_STRICT_THRESHOLD", "0.2"))


class ModerationError(RuntimeError):
    """Raised when the moderation call fails. Callers must fail closed."""


def moderate(text: str, api_key: str, timeout: float = 10.0) -> dict:
    body = json.dumps({"model": MODEL, "input": text}).encode("utf-8")
    req = urllib.request.Request(
        MODERATION_URL,
        data=body,
        method="POST",
        headers={"Content-Type": "application/json", "Authorization": f"Bearer {api_key}"},
    )
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            return json.loads(resp.read().decode("utf-8"))
    except (urllib.error.URLError, urllib.error.HTTPError, ValueError) as exc:
        raise ModerationError(str(exc)) from exc


def decide(result: dict) -> tuple[bool, list[str]]:
    """Return (allowed, reasons)."""
    reasons: list[str] = []
    for item in result.get("results", []):
        if item.get("flagged"):
            reasons.extend(k for k, v in item.get("categories", {}).items() if v)
            reasons.append("flagged")
        scores = item.get("category_scores", {})
        for cat in STRICT_CATEGORIES:
            if scores.get(cat, 0.0) >= STRICT_THRESHOLD:
                reasons.append(f"{cat}>={STRICT_THRESHOLD}")
    return (not reasons, sorted(set(reasons)))


def gate(text: str) -> bool:
    api_key = os.environ.get("OPENAI_API_KEY")
    if not api_key:
        raise ModerationError("OPENAI_API_KEY is not set")
    allowed, reasons = decide(moderate(text, api_key))
    # Log the decision (never the raw input) for AIG-13 evidence.
    print(json.dumps({"control": "AIG-10", "model": MODEL, "allowed": allowed, "reasons": reasons}), file=sys.stderr)
    return allowed


def main() -> int:
    text = sys.stdin.read()
    if not text.strip():
        print("no input on stdin", file=sys.stderr)
        return 1
    try:
        return 0 if gate(text) else 3
    except ModerationError as exc:
        # Fail closed: if the guardrail is unavailable, the request does not proceed.
        print(json.dumps({"control": "AIG-10", "allowed": False, "error": str(exc)}), file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
