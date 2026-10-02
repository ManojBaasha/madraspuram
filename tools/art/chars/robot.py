"""UNIT-07 — bipedal humanoid robot (parts for walk cycle)."""
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


def _face(kind: str, seed: int, ox: float = 0, oy: float = 0) -> str:
    """Screen face at local origin (ox, oy) = top-left of screen."""
    parts = [rect(ox, oy, 44, 28, P["robot_screen"], seed + 1, stroke_w=3, r=4)]
    cx, cy = ox + 22, oy + 14
    if kind == "dots":
        parts += [
            ellipse(cx - 10, cy, 4, 4, P["robot_glow"], seed + 2, stroke_w=2, n=8),
            ellipse(cx + 10, cy, 4, 4, P["robot_glow"], seed + 3, stroke_w=2, n=8),
        ]
    elif kind == "q":
        parts.append(
            f'<text x="{cx}" y="{cy + 8}" text-anchor="middle" font-size="20" '
            f'font-family="sans-serif" fill="{P["robot_glow"]}">?</text>'
        )
    elif kind == "spin":
        parts.append(circle_ring(cx, cy, 9, P["robot_glow"], 3))
        parts.append(line(cx, cy, cx + 7, cy - 7, seed + 5, stroke_w=3, color=P["robot_glow"]))
    elif kind == "heat":
        parts.append(
            f'<text x="{cx}" y="{cy + 8}" text-anchor="middle" font-size="16" '
            f'fill="{P["betel"]}">!!</text>'
        )
    elif kind == "smile":
        parts += [
            ellipse(cx - 10, cy - 2, 3.5, 3.5, P["robot_glow"], seed + 6, stroke_w=2, n=8),
            ellipse(cx + 10, cy - 2, 3.5, 3.5, P["robot_glow"], seed + 7, stroke_w=2, n=8),
            (
                f'<path d="M {cx - 12} {cy + 6} Q {cx} {cy + 16} {cx + 12} {cy + 6}" '
                f'fill="none" stroke="{P["robot_glow"]}" stroke-width="3" stroke-linecap="round"/>'
            ),
        ]
    return group(parts)


def head(expression: str = "neutral", seed: int = 11) -> str:
    kind = EXPRESSIONS.get(expression, "dots")
    # Pivot at bottom-center of neck (~64, 90) — chunkier, more toy-like
    parts = [
        # head shell with cheek bevel
        poly([(18, 24), (110, 24), (106, 84), (22, 84)], P["robot"], seed, stroke_w=7),
        poly([(28, 30), (100, 30), (96, 48), (32, 48)], "#8FB0C8", seed + 1, stroke_w=2),
        _face(kind, seed + 10, 42, 42),
        # ear bolts
        ellipse(18, 54, 7, 9, P["robot_white"], seed + 2, stroke_w=3, n=8),
        ellipse(110, 54, 7, 9, P["robot_white"], seed + 3, stroke_w=3, n=8),
        # antenna with tip glow
        line(64, 24, 64, 6, seed + 20, stroke_w=5, color=P["robot"]),
        ellipse(64, 5, 8, 8, P["betel"], seed + 21, stroke_w=3, n=10),
        ellipse(64, 5, 3, 3, "#F08070", seed + 22, stroke_w=0, n=6),
        # neck stub
        rect(52, 84, 24, 12, P["robot"], seed + 23, stroke_w=3),
    ]
    return svg_doc(128, 100, group(parts), None)


def torso(seed: int = 7) -> str:
    # Pivot at hip center bottom (~60, 100)
    parts = [
        # chest
        poly([(14, 6), (106, 6), (100, 90), (20, 90)], P["robot"], seed, stroke_w=7),
        # highlight bevel
        poly([(24, 12), (70, 12), (66, 40), (28, 40)], "#8FB0C8", seed + 5, stroke_w=2),
        # chest plate
        rect(38, 28, 44, 32, P["robot_white"], seed + 1, stroke_w=4, r=5),
        # PUSH badge
        f'<text x="60" y="50" text-anchor="middle" font-size="12" font-weight="700" '
        f'font-family="sans-serif" fill="{P["outline"]}">PUSH</text>',
        # hip band
        poly([(20, 78), (100, 78), (96, 102), (24, 102)], P["robot_screen"], seed + 2, stroke_w=5),
        # rivets
        ellipse(30, 86, 3, 3, P["robot_white"], seed + 6, stroke_w=1, n=6),
        ellipse(90, 86, 3, 3, P["robot_white"], seed + 7, stroke_w=1, n=6),
        # shoulder nubs
        ellipse(14, 20, 12, 12, P["robot"], seed + 3, stroke_w=4, n=10),
        ellipse(106, 20, 12, 12, P["robot"], seed + 4, stroke_w=4, n=10),
    ]
    return svg_doc(120, 110, group(parts), None)


def arm(seed: int = 21) -> str:
    """Upper+forearm; pivot at shoulder (top)."""
    parts = [
        # upper arm
        poly([(16, 6), (44, 6), (42, 54), (14, 54)], P["robot"], seed, stroke_w=6),
        # elbow
        ellipse(29, 55, 10, 10, P["robot_white"], seed + 1, stroke_w=3, n=8),
        # forearm
        poly([(14, 58), (44, 58), (40, 102), (12, 102)], P["robot_white"], seed + 2, stroke_w=6),
        # hand / pad with fingers hint
        poly([(8, 98), (46, 98), (44, 120), (10, 120)], P["robot"], seed + 3, stroke_w=5),
        line(18, 108, 18, 118, seed + 4, stroke_w=2, color=P["robot_white"]),
        line(28, 108, 28, 118, seed + 5, stroke_w=2, color=P["robot_white"]),
        line(38, 108, 38, 118, seed + 6, stroke_w=2, color=P["robot_white"]),
    ]
    return svg_doc(56, 128, group(parts), None)


def push_arm(seed: int = 25) -> str:
    """Chunkier spring PUSH arm — right side."""
    parts = [
        poly([(8, 8), (42, 6), (44, 52), (10, 54)], P["robot_white"], seed, stroke_w=6),
        ellipse(26, 52, 11, 11, P["robot"], seed + 1, stroke_w=3, n=8),
        poly([(10, 56), (44, 54), (52, 108), (4, 110)], P["robot"], seed + 2, stroke_w=6),
        # spring coils
        line(14, 68, 44, 66, seed + 3, stroke_w=3, color=P["robot_white"]),
        line(12, 80, 46, 78, seed + 4, stroke_w=3, color=P["robot_white"]),
        line(14, 92, 44, 90, seed + 5, stroke_w=3, color=P["robot_white"]),
        # big PUSH pad
        rect(2, 105, 52, 22, P["robot_white"], seed + 6, stroke_w=5, r=4),
        f'<text x="28" y="121" text-anchor="middle" font-size="9" '
        f'font-family="sans-serif" fill="{P["outline"]}">PUSH</text>',
    ]
    return svg_doc(56, 130, group(parts), None)


def leg(seed: int = 31) -> str:
    """Thigh + shin + foot; pivot at hip (top-center)."""
    parts = [
        # thigh
        poly([(12, 4), (44, 4), (42, 48), (10, 48)], P["robot"], seed, stroke_w=6),
        # knee
        ellipse(27, 50, 11, 11, P["robot_white"], seed + 1, stroke_w=3, n=8),
        # shin
        poly([(10, 54), (44, 54), (40, 96), (12, 96)], P["robot_screen"], seed + 2, stroke_w=6),
        # chunky boot
        poly([(4, 92), (52, 92), (54, 114), (2, 114)], P["robot"], seed + 3, stroke_w=5),
        poly([(4, 108), (54, 108), (54, 114), (4, 114)], P["robot_white"], seed + 4, stroke_w=2),
    ]
    return svg_doc(56, 118, group(parts), None)


def full(expression: str = "neutral", heat: float = 0.0, seed: int = 1) -> str:
    """Idle humanoid composite (preview / fallback sprite)."""
    kind = EXPRESSIONS.get(expression, "dots")
    droop = 8 * heat
    steam = None
    if heat > 0.4:
        steam = group(
            [
                ellipse(70, 18, 6, 10, "#FFFFFF", seed + 90, stroke_w=2, n=8),
                ellipse(95, 10, 5, 9, "#FFFFFF", seed + 91, stroke_w=2, n=8),
                ellipse(120, 16, 5, 8, "#FFFFFF", seed + 92, stroke_w=2, n=8),
            ],
            opacity=0.5,
        )
    # Canvas ~210x240, feet at y~220, center x~100
    parts = [
        ellipse(100, 228, 48, 11, P["shadow"], seed, stroke_w=0, n=12, opacity=0.18),
        # left leg (back)
        poly([(60, 138), (90, 138), (86, 188), (56, 188)], P["robot"], seed + 1, stroke_w=6),
        ellipse(73, 190, 10, 10, P["robot_white"], seed + 2, stroke_w=3, n=8),
        poly([(56, 194), (88, 194), (84, 220), (52, 220)], P["robot_screen"], seed + 3, stroke_w=6),
        poly([(46, 214), (94, 214), (96, 232), (44, 232)], P["robot"], seed + 4, stroke_w=5),
        # right leg (front)
        poly([(110, 138), (140, 138), (144, 188), (114, 188)], P["robot"], seed + 5, stroke_w=6),
        ellipse(127, 190, 10, 10, P["robot_white"], seed + 6, stroke_w=3, n=8),
        poly([(112, 194), (146, 194), (150, 220), (116, 220)], P["robot_screen"], seed + 7, stroke_w=6),
        poly([(108, 214), (160, 214), (162, 232), (106, 232)], P["robot"], seed + 8, stroke_w=5),
        # torso
        poly([(54, 66), (146, 66), (140, 148), (60, 148)], P["robot"], seed + 9, stroke_w=7),
        poly([(62, 72), (110, 72), (106, 100), (66, 100)], "#8FB0C8", seed + 25, stroke_w=2),
        rect(78, 88, 44, 32, P["robot_white"], seed + 10, stroke_w=4, r=5),
        f'<text x="100" y="110" text-anchor="middle" font-size="12" font-weight="700" '
        f'font-family="sans-serif" fill="{P["outline"]}">PUSH</text>',
        poly([(58, 136), (142, 136), (138, 154), (62, 154)], P["robot_screen"], seed + 11, stroke_w=5),
        # left arm
        poly([(36, 76), (60, 80), (54, 132), (30, 128)], P["robot"], seed + 12, stroke_w=6),
        poly([(28, 130), (56, 134), (50, 164), (24, 160)], P["robot_white"], seed + 13, stroke_w=5),
        # right PUSH arm
        poly([(140, 78), (174, 72), (180, 120), (146, 124)], P["robot_white"], seed + 14, stroke_w=6),
        poly([(170, 116), (196, 112), (200, 140), (168, 142)], P["robot"], seed + 15, stroke_w=5),
        rect(160, 134, 42, 18, P["robot_white"], seed + 16, stroke_w=4, r=3),
        # head
        poly([(58, 18), (142, 18), (138, 68), (62, 68)], P["robot"], seed + 17, stroke_w=7),
        poly([(68, 24), (132, 24), (128, 40), (72, 40)], "#8FB0C8", seed + 26, stroke_w=2),
        _face(kind, seed + 20, 78, 30),
        ellipse(58, 44, 7, 9, P["robot_white"], seed + 27, stroke_w=2, n=8),
        ellipse(142, 44, 7, 9, P["robot_white"], seed + 28, stroke_w=2, n=8),
        line(100, 18, 100, 4 + droop, seed + 18, stroke_w=5, color=P["robot"]),
        ellipse(100, 2 + droop, 8, 8, P["betel"], seed + 19, stroke_w=3, n=10),
    ]
    if steam:
        parts.append(steam)
    return svg_doc(210, 240, group(parts), None)


def walk_frame(frame: int, seed: int = 400) -> str:
    """4-frame walk cycle composite for simple sprite swap fallback."""
    # Leg angles via x offsets
    phases = [
        # L forward, R back — exaggerated for readable cycle
        {"lx": -30, "rx": 30, "ly": -2, "ry": -12, "ax": 20},
        {"lx": -10, "rx": 10, "ly": -16, "ry": -2, "ax": 6},
        {"lx": 30, "rx": -30, "ly": -2, "ry": -12, "ax": -20},
        {"lx": 10, "rx": -10, "ly": -16, "ry": -2, "ax": -6},
    ]
    p = phases[frame % 4]
    s = seed + frame * 17
    parts = [
        ellipse(100, 228, 42, 10, P["shadow"], s, stroke_w=0, n=12, opacity=0.18),
        # left leg
        poly(
            [
                (70 + p["lx"], 140 + p["ly"]),
                (96 + p["lx"], 140 + p["ly"]),
                (92 + p["lx"], 190),
                (66 + p["lx"], 190),
            ],
            P["robot"],
            s + 1,
            stroke_w=5,
        ),
        poly(
            [
                (64 + p["lx"], 192),
                (94 + p["lx"], 192),
                (90 + p["lx"], 220),
                (60 + p["lx"], 220),
            ],
            P["robot_screen"],
            s + 2,
            stroke_w=5,
        ),
        poly(
            [
                (52 + p["lx"], 216),
                (98 + p["lx"], 216),
                (96 + p["lx"], 230),
                (50 + p["lx"], 230),
            ],
            P["robot"],
            s + 3,
            stroke_w=4,
        ),
        # right leg
        poly(
            [
                (104 + p["rx"], 140 + p["ry"]),
                (130 + p["rx"], 140 + p["ry"]),
                (134 + p["rx"], 190),
                (108 + p["rx"], 190),
            ],
            P["robot"],
            s + 4,
            stroke_w=5,
        ),
        poly(
            [
                (106 + p["rx"], 192),
                (136 + p["rx"], 192),
                (140 + p["rx"], 220),
                (110 + p["rx"], 220),
            ],
            P["robot_screen"],
            s + 5,
            stroke_w=5,
        ),
        poly(
            [
                (102 + p["rx"], 216),
                (148 + p["rx"], 216),
                (146 + p["rx"], 230),
                (100 + p["rx"], 230),
            ],
            P["robot"],
            s + 6,
            stroke_w=4,
        ),
        # torso bob
        poly([(58, 68), (142, 68), (136, 143), (64, 143)], P["robot"], s + 7, stroke_w=6),
        rect(80, 88, 40, 28, P["robot_white"], s + 8, stroke_w=3, r=4),
        # arms opposite to legs
        poly(
            [
                (38 - p["ax"], 76),
                (60 - p["ax"], 80),
                (54 - p["ax"], 128),
                (32 - p["ax"], 124),
            ],
            P["robot"],
            s + 9,
            stroke_w=5,
        ),
        poly(
            [
                (138 + p["ax"], 78),
                (168 + p["ax"], 74),
                (172 + p["ax"], 116),
                (142 + p["ax"], 120),
            ],
            P["robot_white"],
            s + 10,
            stroke_w=5,
        ),
        rect(164 + p["ax"], 128, 34, 16, P["robot_white"], s + 11, stroke_w=3, r=3),
        # head
        poly([(62, 20), (138, 20), (134, 66), (66, 66)], P["robot"], s + 12, stroke_w=6),
        _face("dots", s + 20, 78, 30),
        line(100, 20, 100, 6, s + 13, stroke_w=4, color=P["robot"]),
        ellipse(100, 4, 7, 7, P["betel"], s + 14, stroke_w=3, n=10),
    ]
    return svg_doc(210, 240, group(parts), None)


def all_assets() -> dict[str, str]:
    out = {
        "chars/robot_body.svg": torso(),
        "chars/robot_arm.svg": arm(),
        "chars/robot_push_arm.svg": push_arm(),
        "chars/robot_leg.svg": leg(),
        "chars/robot_full_neutral.svg": full("neutral", 0.0),
        "chars/robot_full_confused.svg": full("confused", 0.0),
        "chars/robot_full_loading.svg": full("loading", 0.0),
        "chars/robot_full_overheated.svg": full("overheated", 0.8),
        "chars/robot_full_delighted.svg": full("delighted", 0.0),
        "chars/robot_walk_0.svg": walk_frame(0),
        "chars/robot_walk_1.svg": walk_frame(1),
        "chars/robot_walk_2.svg": walk_frame(2),
        "chars/robot_walk_3.svg": walk_frame(3),
    }
    for expr in EXPRESSIONS:
        out[f"chars/robot_head_{expr}.svg"] = head(expr)
    return out
