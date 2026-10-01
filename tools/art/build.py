#!/usr/bin/env python3
"""Regenerate all SVGs deterministically into art/svg/."""
from __future__ import annotations

import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT))

from tools.art.chars import npc, robot  # noqa: E402
from tools.art import kolam  # noqa: E402
from tools.art.props import backgrounds, props  # noqa: E402

OUT = ROOT / "art" / "svg"


def main() -> None:
    assets: dict[str, str] = {}
    for mod in (robot, npc, props, kolam, backgrounds):
        assets.update(mod.all_assets())

    written = []
    for rel, content in sorted(assets.items()):
        path = OUT / rel
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8")
        written.append(path)
        print(f"wrote {path.relative_to(ROOT)}")

    print(f"OK {len(written)} SVGs")


if __name__ == "__main__":
    main()
