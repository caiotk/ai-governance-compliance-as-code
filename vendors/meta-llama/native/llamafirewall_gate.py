#!/usr/bin/env python3
"""LlamaFirewall input gate for self-hosted Llama.  Controls: AIG-10 (runtime
guardrails), AIG-13 (decision logging).

API verified 2026-10-13 from the LlamaFirewall README:
https://github.com/meta-llama/PurpleLlama/blob/main/LlamaFirewall/README.md

    from llamafirewall import LlamaFirewall, UserMessage, Role, ScannerType
    llamafirewall = LlamaFirewall(scanners={Role.USER: [ScannerType.PROMPT_GUARD]})
    result = llamafirewall.scan(UserMessage(content="..."))
    # ScanResult(decision=<ScanDecision.BLOCK: 'block'>, reason='prompt_guard', score=0.95)

Install: pip install llamafirewall  (Prompt Guard 2 weights come from Hugging Face;
see the README "First Time Setup Tips").

This is an example; it is not executed by CI. Exit code 0 = allow, 3 = block,
1 = error (fail closed).

Usage:
    echo "user text" | python3 llamafirewall_gate.py
"""

from __future__ import annotations

import json
import sys

try:
    from llamafirewall import LlamaFirewall, Role, ScannerType, UserMessage
except ImportError:  # pragma: no cover - dependency is optional for repo validation
    LlamaFirewall = None  # type: ignore[assignment]


def build_firewall() -> "LlamaFirewall":
    if LlamaFirewall is None:
        raise RuntimeError("llamafirewall is not installed (pip install llamafirewall)")
    return LlamaFirewall(
        scanners={
            # Verified: PromptGuard 2 scanner for prompt-injection / jailbreak detection.
            Role.USER: [ScannerType.PROMPT_GUARD],
            # UNVERIFIED (not in the research verification set): the README's Trace
            # example uses ScannerType.AGENT_ALIGNMENT on Role.ASSISTANT (AlignmentCheck,
            # which needs an LLM backend), and the package source defines
            # ScannerType.CODE_SHIELD. Confirm against your installed version before enabling:
            # Role.ASSISTANT: [ScannerType.AGENT_ALIGNMENT, ScannerType.CODE_SHIELD],
        }
    )


def decision_value(result: object) -> str:
    """Return the scan decision as a lowercase string ('allow', 'block', ...)."""
    decision = getattr(result, "decision", None)
    return str(getattr(decision, "value", decision)).lower()


def gate(text: str, firewall: "LlamaFirewall | None" = None) -> bool:
    firewall = firewall or build_firewall()
    result = firewall.scan(UserMessage(content=text))
    decision = decision_value(result)
    # Anything other than an explicit allow (block, human review, unknown) is not allowed.
    allowed = decision == "allow"
    print(
        json.dumps(
            {
                "control": "AIG-10",
                "scanner": "llamafirewall",
                "decision": decision,
                "reason": getattr(result, "reason", None),
                "score": getattr(result, "score", None),
                "allowed": allowed,
            }
        ),
        file=sys.stderr,
    )
    return allowed


def main() -> int:
    text = sys.stdin.read()
    if not text.strip():
        print("no input on stdin", file=sys.stderr)
        return 1
    try:
        return 0 if gate(text) else 3
    except Exception as exc:  # fail closed on any scanner error
        print(json.dumps({"control": "AIG-10", "allowed": False, "error": str(exc)}), file=sys.stderr)
        return 1


if __name__ == "__main__":
    sys.exit(main())
