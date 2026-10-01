"""Tea kadai background slice."""
from __future__ import annotations

from tools.art.primitives import PALETTE as P
from tools.art.primitives import ellipse, group, line, poly, rect, svg_doc


def tea_kadai_bg(seed: int = 500) -> str:
    parts = [
        line(0, 70, 640, 55, seed, stroke_w=3),
        line(40, 90, 600, 72, seed + 1, stroke_w=2),
        # crows on wire
        ellipse(120, 68, 6, 4, P["outline"], seed + 20, stroke_w=2, n=8),
        ellipse(280, 60, 6, 4, P["outline"], seed + 21, stroke_w=2, n=8),
        ellipse(480, 58, 6, 4, P["outline"], seed + 22, stroke_w=2, n=8),
        # building plaster
        rect(30, 110, 440, 270, P["plaster"], seed + 2, stroke_w=6),
        # cobalt fascia
        rect(30, 110, 440, 55, P["cobalt"], seed + 3, stroke_w=5),
        # doorway recess
        rect(70, 200, 70, 120, "#C9B07A", seed + 13, stroke_w=4),
        # counter
        poly([(60, 270), (420, 262), (435, 340), (50, 348)], P["wood"], seed + 4, stroke_w=6),
        # stove glow + tumbler stack hint
        ellipse(150, 295, 34, 14, P["ochre"], seed + 5, stroke_w=3, n=10),
        rect(250, 220, 38, 48, "#D8E8F0", seed + 6, stroke_w=4, r=3),
        rect(300, 215, 38, 53, "#D8E8F0", seed + 7, stroke_w=4, r=3),
        rect(350, 240, 55, 32, P["betel"], seed + 8, stroke_w=4, r=2),
        ellipse(377, 256, 8, 8, P["outline"], seed + 9, stroke_w=2, n=8),
        # bench that blocks
        poly([(470, 290), (630, 282), (635, 330), (465, 338)], P["wood"], seed + 10, stroke_w=6),
        rect(480, 250, 40, 45, P["cobalt"], seed + 14, stroke_w=3),  # regular sitting hint
        # ground + shadow
        f'<rect x="0" y="360" width="640" height="80" fill="#C4A574"/>',
        ellipse(320, 390, 200, 18, P["shadow"], seed + 15, stroke_w=0, n=12, opacity=0.12),
        # shade cloth
        poly([(50, 165), (420, 155), (420, 188), (50, 195)], P["betel"], seed + 12, stroke_w=5, opacity=0.75),
        # hanging bananas hook
        line(200, 165, 200, 200, seed + 16, stroke_w=4, color=P["leaf"]),
    ]
    return svg_doc(640, 440, group(parts), P["sky"])


def all_assets() -> dict[str, str]:
    return {"bg/tea_kadai_slice.svg": tea_kadai_bg()}
