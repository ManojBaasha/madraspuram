"""UNIT-07 robot part SVGs."""
from __future__ import annotations

from tools.art.primitives import PALETTE as P
from tools.art.primitives import circle_ring, ellipse, group, line, poly, rect, svg_doc


EXPRESSIONS = {
    "neutral": "dots",
    "confused": "q",
    "loading": "spin",
    "overheated": "heat",
    "delighted": "smile",
}


def _face(kind: str, seed: int) -> str:
    parts = [rect(40, 48, 48, 28, P["robot_screen"], seed + 1, stroke_w=3, r=4)]
    if kind == "dots":
        parts += [
            ellipse(52, 62, 4, 4, P["robot_glow"], seed + 2, stroke_w=2, n=8),
            ellipse(76, 62, 4, 4, P["robot_glow"], seed + 3, stroke_w=2, n=8),
        ]
    elif kind == "q":
        parts.append(
            f'<text x="64" y="70" text-anchor="middle" font-size="22" '
            f'font-family="sans-serif" fill="{P["robot_glow"]}">?</text>'
        )
    elif kind == "spin":
        parts.append(circle_ring(64, 62, 10, P["robot_glow"], 3))
        parts.append(line(64, 62, 72, 54, seed + 5, stroke_w=3, color=P["robot_glow"]))
    elif kind == "heat":
        parts.append(
            f'<text x="64" y="70" text-anchor="middle" font-size="18" '
            f'fill="{P["betel"]}">!!</text>'
        )
    elif kind == "smile":
        parts += [
            ellipse(52, 60, 3.5, 3.5, P["robot_glow"], seed + 6, stroke_w=2, n=8),
            ellipse(76, 60, 3.5, 3.5, P["robot_glow"], seed + 7, stroke_w=2, n=8),
            (
                f'<path d="M 52 68 Q 64 78 76 68" fill="none" stroke="{P["robot_glow"]}" '
                f'stroke-width="3" stroke-linecap="round"/>'
            ),
        ]
    return group(parts)


def body(seed: int = 7) -> str:
    parts = [
        # treads
        poly([(30, 100), (98, 100), (92, 118), (36, 118)], P["robot_screen"], seed, stroke_w=5),
        rect(34, 102, 12, 14, P["robot"], seed + 1, stroke_w=3),
        rect(82, 102, 12, 14, P["robot"], seed + 2, stroke_w=3),
        # torso
        poly([(28, 40), (100, 40), (96, 100), (32, 100)], P["robot"], seed + 3, stroke_w=6),
        # chest plate
        rect(48, 78, 32, 16, P["robot_white"], seed + 4, stroke_w=3, r=3),
        # antenna
        line(64, 40, 64, 18, seed + 5, stroke_w=4, color=P["robot"]),
        ellipse(64, 14, 7, 7, P["betel"], seed + 6, stroke_w=3, n=10),
        # push arm (right)
        poly([(100, 70), (128, 66), (130, 78), (100, 82)], P["robot_white"], seed + 7, stroke_w=4),
        poly([(128, 60), (148, 70), (128, 84)], P["robot"], seed + 8, stroke_w=4),
    ]
    return svg_doc(160, 140, group(parts), None)


def head(expression: str = "neutral", seed: int = 11) -> str:
    kind = EXPRESSIONS.get(expression, "dots")
    parts = [
        poly([(24, 28), (104, 28), (100, 88), (28, 88)], P["robot"], seed, stroke_w=6),
        _face(kind, seed + 10),
        line(64, 28, 64, 10, seed + 20, stroke_w=4, color=P["robot"]),
        ellipse(64, 8, 6, 6, P["betel"], seed + 21, stroke_w=3, n=10),
    ]
    return svg_doc(128, 100, group(parts), None)


def arm(seed: int = 21) -> str:
    parts = [
        poly([(10, 20), (70, 14), (74, 34), (10, 40)], P["robot_white"], seed, stroke_w=5),
        poly([(70, 8), (100, 26), (70, 44)], P["robot"], seed + 1, stroke_w=5),
    ]
    return svg_doc(110, 56, group(parts), None)


def leg(seed: int = 31) -> str:
    parts = [
        poly([(8, 8), (40, 8), (36, 40), (12, 40)], P["robot_screen"], seed, stroke_w=5),
        rect(10, 12, 10, 12, P["robot"], seed + 1, stroke_w=3),
    ]
    return svg_doc(48, 48, group(parts), None)


def full(expression: str = "neutral", heat: float = 0.0, seed: int = 1) -> str:
    """Composite preview of robot."""
    kind = EXPRESSIONS.get(expression, "dots")
    droop = 8 * heat
    steam = None
    if heat > 0.4:
        steam = group(
            [
                ellipse(50, 20, 6, 10, "#FFFFFF", seed + 90, stroke_w=2, n=8),
                ellipse(70, 12, 5, 9, "#FFFFFF", seed + 91, stroke_w=2, n=8),
            ],
            opacity=0.5,
        )
    parts = [
        ellipse(90, 168, 40, 8, P["shadow"], seed, stroke_w=0, n=12, opacity=0.15),
        poly([(50, 90), (130, 90), (124, 155), (56, 155)], P["robot"], seed + 1, stroke_w=6),
        rect(74, 128, 32, 16, P["robot_white"], seed + 2, stroke_w=3, r=3),
        poly([(52, 150), (128, 150), (120, 168), (60, 168)], P["robot_screen"], seed + 3, stroke_w=5),
        poly([(40, 50), (120, 50), (116, 95), (44, 95)], P["robot"], seed + 4, stroke_w=6),
        _face(kind, seed + 10),
        line(80, 50, 80, 28 + droop, seed + 5, stroke_w=4, color=P["robot"]),
        ellipse(80, 22 + droop, 7, 7, P["betel"], seed + 6, stroke_w=3, n=10),
        poly([(120, 100), (158, 94), (160, 110), (120, 114)], P["robot_white"], seed + 7, stroke_w=4),
        poly([(158, 86), (182, 100), (158, 116)], P["robot"], seed + 8, stroke_w=4),
    ]
    if steam:
        parts.append(steam)
    return svg_doc(200, 180, group(parts), P["sky"])


def all_assets() -> dict[str, str]:
    out = {
        "chars/robot_body.svg": body(),
        "chars/robot_arm.svg": arm(),
        "chars/robot_leg.svg": leg(),
        "chars/robot_full_neutral.svg": full("neutral", 0.0),
        "chars/robot_full_confused.svg": full("confused", 0.0),
        "chars/robot_full_loading.svg": full("loading", 0.0),
        "chars/robot_full_overheated.svg": full("overheated", 0.8),
        "chars/robot_full_delighted.svg": full("delighted", 0.0),
    }
    for expr in EXPRESSIONS:
        out[f"chars/robot_head_{expr}.svg"] = head(expr)
    return out
