"""Tea kadai background slice — richer stall façade."""
from __future__ import annotations

from tools.art.primitives import PALETTE as P
from tools.art.primitives import ellipse, group, line, poly, rect, svg_doc


def tea_kadai_bg(seed: int = 500) -> str:
    plaster = P["plaster"]
    parts = [
        # wires behind
        line(0, 70, 640, 55, seed, stroke_w=3),
        line(40, 90, 600, 72, seed + 1, stroke_w=2),
        ellipse(120, 68, 6, 4, P["outline"], seed + 20, stroke_w=2, n=8),
        ellipse(280, 60, 6, 4, P["outline"], seed + 21, stroke_w=2, n=8),
        ellipse(480, 58, 6, 4, P["outline"], seed + 22, stroke_w=2, n=8),
        # building plaster body
        rect(30, 110, 440, 270, plaster, seed + 2, stroke_w=6),
        # peeling patches
        rect(60, 180, 40, 55, "#D4B070", seed + 30, stroke_w=2),
        rect(320, 200, 55, 40, "#C9A868", seed + 31, stroke_w=2),
        # drain pipe
        rect(450, 130, 8, 230, "#7A6A58", seed + 32, stroke_w=3),
        rect(444, 350, 20, 8, "#6A5A48", seed + 33, stroke_w=2),
        # cobalt fascia
        rect(30, 110, 440, 55, P["cobalt"], seed + 3, stroke_w=5),
        rect(30, 158, 440, 6, "#5A8AC0", seed + 34, stroke_w=2),
        # roof coping
        rect(22, 100, 456, 12, "#C9A878", seed + 35, stroke_w=4),
        # doorway recess left
        rect(70, 200, 70, 120, "#C9B07A", seed + 13, stroke_w=4),
        rect(78, 210, 54, 100, "#3A2A1A", seed + 36, stroke_w=3),
        # window with frame right of door
        rect(160, 200, 50, 55, "#2B1D14", seed + 37, stroke_w=3),
        rect(166, 206, 38, 43, "#6A90A8", seed + 38, stroke_w=2),
        line(185, 206, 185, 249, seed + 39, stroke_w=2),
        # roll shutter partially visible above counter mouth
        rect(55, 165, 390, 28, "#8A9098", seed + 40, stroke_w=4),
        line(55, 172, 445, 172, seed + 41, stroke_w=2, color="#5A6068"),
        line(55, 180, 445, 180, seed + 42, stroke_w=2, color="#5A6068"),
        # striped shade cloth
        poly([(50, 165), (420, 155), (420, 188), (50, 195)], P["betel"], seed + 12, stroke_w=5, opacity=0.85),
        poly([(50, 170), (90, 168), (90, 192), (50, 194)], "#FBF7EE", seed + 43, stroke_w=2, opacity=0.7),
        poly([(130, 167), (170, 164), (170, 190), (130, 192)], "#FBF7EE", seed + 44, stroke_w=2, opacity=0.7),
        poly([(210, 163), (250, 160), (250, 188), (210, 190)], "#FBF7EE", seed + 45, stroke_w=2, opacity=0.7),
        # hanging bananas hook
        line(200, 165, 200, 200, seed + 16, stroke_w=4, color=P["leaf"]),
        # counter
        poly([(60, 270), (420, 262), (435, 340), (50, 348)], P["wood"], seed + 4, stroke_w=6),
        # counter edge highlight
        poly([(60, 270), (420, 262), (418, 275), (62, 282)], "#A07040", seed + 46, stroke_w=3),
        # stove glow + tumbler stack
        ellipse(150, 295, 34, 14, P["ochre"], seed + 5, stroke_w=3, n=10),
        rect(250, 220, 38, 48, "#D8E8F0", seed + 6, stroke_w=4, r=3),
        rect(300, 215, 38, 53, "#D8E8F0", seed + 7, stroke_w=4, r=3),
        rect(350, 240, 55, 32, P["betel"], seed + 8, stroke_w=4, r=2),
        ellipse(377, 256, 8, 8, P["outline"], seed + 9, stroke_w=2, n=8),
        # shelf bottles hint
        rect(280, 195, 12, 22, P["cobalt"], seed + 47, stroke_w=2),
        rect(298, 198, 12, 19, P["leaf"], seed + 48, stroke_w=2),
        rect(316, 196, 12, 21, P["betel"], seed + 49, stroke_w=2),
        # bench
        poly([(470, 290), (630, 282), (635, 330), (465, 338)], P["wood"], seed + 10, stroke_w=6),
        rect(480, 250, 40, 45, P["cobalt"], seed + 14, stroke_w=3),
        # hanging bulb
        line(240, 188, 240, 210, seed + 50, stroke_w=2),
        ellipse(240, 216, 7, 8, "#F2E8A0", seed + 51, stroke_w=2, n=8),
        # damp skirting
        rect(30, 360, 440, 20, "#B89868", seed + 52, stroke_w=3),
        # soft contact shadow
        ellipse(320, 390, 200, 18, P["shadow"], seed + 15, stroke_w=0, n=12, opacity=0.12),
    ]
    return svg_doc(640, 440, group(parts), None)


def all_assets() -> dict[str, str]:
    return {"bg/tea_kadai_slice.svg": tea_kadai_bg()}
