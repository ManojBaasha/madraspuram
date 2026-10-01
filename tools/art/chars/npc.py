"""Adult NPC — tea master."""
from __future__ import annotations

from tools.art.primitives import PALETTE as P
from tools.art.primitives import ellipse, group, line, poly, rect, svg_doc


def tea_master(seed: int = 200) -> str:
    parts = [
        poly([(70, 200), (98, 200), (94, 265), (66, 265)], "#3A2A1A", seed, stroke_w=5),
        poly([(108, 200), (136, 200), (140, 265), (112, 265)], "#3A2A1A", seed + 1, stroke_w=5),
        # veshti
        poly([(55, 155), (150, 150), (155, 215), (50, 220)], P["plaster"], seed + 2, stroke_w=6),
        # blue shirt
        poly([(58, 95), (148, 92), (145, 165), (60, 168)], P["cobalt"], seed + 3, stroke_w=6),
        # arms
        poly([(30, 105), (60, 110), (55, 175), (28, 170)], P["plaster"], seed + 4, stroke_w=5),
        poly([(140, 108), (185, 85), (190, 130), (148, 155)], P["plaster"], seed + 5, stroke_w=5),
        # pot
        ellipse(195, 78, 20, 15, P["tea"], seed + 6, stroke_w=4, n=12),
        f'<path d="M 195 78 Q 225 65 215 40" fill="none" stroke="{P["tea"]}" '
        f'stroke-width="6" stroke-linecap="round"/>',
        # tumbler catching pour
        poly([(200, 130), (225, 130), (220, 165), (205, 165)], "#D8E8F0", seed + 7, stroke_w=3),
        # head
        ellipse(102, 62, 38, 42, P["plaster"], seed + 8, stroke_w=6, n=14),
        # big moustache
        poly([(68, 78), (102, 92), (136, 78), (102, 84)], "#2B1D14", seed + 9, stroke_w=2),
        ellipse(88, 60, 5, 6, P["outline"], seed + 10, stroke_w=2, n=8),
        ellipse(116, 60, 5, 6, P["outline"], seed + 11, stroke_w=2, n=8),
        # balding fringe
        poly([(68, 35), (136, 32), (128, 48), (75, 50)], "#2B1D14", seed + 12, stroke_w=3),
        # brows
        line(78, 48, 95, 50, seed + 13, stroke_w=3),
        line(110, 50, 128, 48, seed + 14, stroke_w=3),
    ]
    return svg_doc(250, 290, group(parts), None)


def all_assets() -> dict[str, str]:
    return {"chars/tea_master.svg": tea_master()}
