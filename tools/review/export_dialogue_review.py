#!/usr/bin/env python3
"""Export review/dialogue_review.md from data/dialogue.json."""
from __future__ import annotations
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
data = json.loads((ROOT / "data/dialogue.json").read_text(encoding="utf-8"))
lines = ["# Dialogue review (generated)", ""]
for npc, body in data.get("npcs", {}).items():
    for key, line in body.get("lines", {}).items():
        lines.append(
            f"- **{npc}.{key}** [{line.get('confidence','?')}]  \n"
            f"  TA: {line.get('ta','')}  \n"
            f"  EN: {line.get('en_subtitle','')}"
        )
out = ROOT / "review" / "dialogue_review_generated.md"
out.write_text("\n".join(lines) + "\n", encoding="utf-8")
print("wrote", out)
