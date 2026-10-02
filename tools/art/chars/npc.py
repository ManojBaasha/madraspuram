"""Street cast — role-readable silhouettes (not recolors).

Each figure must read at postage-stamp size:
  tea master | auto anna | pointing uncle | school kid | cane uncle | flower auntie
"""
from __future__ import annotations

from tools.art.primitives import PALETTE as P
from tools.art.primitives import ellipse, group, line, poly, rect, svg_doc

SKIN = P["plaster"]
HAIR = "#2B1D14"
VESTHI = "#F5F0E6"
SHADOW = P["shadow"]
OUT = P["outline"]


def _ground(cx: float, cy: float, rx: float, seed: int) -> str:
    return ellipse(cx, cy, rx, 10, SHADOW, seed, stroke_w=0, n=10, opacity=0.16)


def _face(
    cx: float,
    cy: float,
    seed: int,
    *,
    brow: bool = True,
    smile: str = "flat",  # flat | grin | soft
) -> list[str]:
    """Eyes + brows + mouth. Keep clear of hair zone (hair must sit above cy-18)."""
    parts = [
        # whites then pupils for readability
        ellipse(cx - 12, cy, 5, 6, "#FFF8F0", seed, stroke_w=2, n=8),
        ellipse(cx + 12, cy, 5, 6, "#FFF8F0", seed + 1, stroke_w=2, n=8),
        ellipse(cx - 12, cy + 1, 2.5, 3, OUT, seed + 2, stroke_w=1, n=6),
        ellipse(cx + 12, cy + 1, 2.5, 3, OUT, seed + 3, stroke_w=1, n=6),
        # tiny nose
        ellipse(cx, cy + 8, 3, 2.5, "#D4A878", seed + 4, stroke_w=1, n=6),
    ]
    if brow:
        parts += [
            line(cx - 20, cy - 12, cx - 6, cy - 10, seed + 5, stroke_w=3),
            line(cx + 6, cy - 10, cx + 20, cy - 12, seed + 6, stroke_w=3),
        ]
    if smile == "grin":
        parts.append(
            f'<path d="M {cx - 10} {cy + 18} Q {cx} {cy + 28} {cx + 10} {cy + 18}" '
            f'fill="none" stroke="{OUT}" stroke-width="3" stroke-linecap="round"/>'
        )
    elif smile == "soft":
        parts.append(
            f'<path d="M {cx - 8} {cy + 18} Q {cx} {cy + 24} {cx + 8} {cy + 18}" '
            f'fill="none" stroke="{OUT}" stroke-width="2.5" stroke-linecap="round"/>'
        )
    else:
        parts.append(line(cx - 8, cy + 18, cx + 8, cy + 18, seed + 7, stroke_w=2, color="#8A6A50"))
    return parts


def _stache(cx: float, cy: float, seed: int, color: str = HAIR, wide: float = 36) -> str:
    """Classic handlebar — two wings, not a triangle goatee."""
    half = wide / 2
    return group(
        [
            # left wing
            poly(
                [
                    (cx - 2, cy + 2),
                    (cx - half * 0.35, cy - 2),
                    (cx - half, cy + 2),
                    (cx - half * 0.9, cy + 10),
                    (cx - half * 0.3, cy + 8),
                    (cx, cy + 6),
                ],
                color,
                seed,
                stroke_w=2,
            ),
            # right wing
            poly(
                [
                    (cx + 2, cy + 2),
                    (cx + half * 0.35, cy - 2),
                    (cx + half, cy + 2),
                    (cx + half * 0.9, cy + 10),
                    (cx + half * 0.3, cy + 8),
                    (cx, cy + 6),
                ],
                color,
                seed + 1,
                stroke_w=2,
            ),
        ]
    )


def _hair_cap(cx: float, top: float, w: float, seed: int, color: str = HAIR) -> str:
    """Hair sits on crown as a soft dome — not a flat cap."""
    hw = w / 2
    return group(
        [
            ellipse(cx, top + 14, hw - 2, 16, color, seed, stroke_w=3, n=14),
            poly(
                [
                    (cx - hw + 2, top + 16),
                    (cx - hw + 8, top + 6),
                    (cx + hw - 8, top + 6),
                    (cx + hw - 2, top + 16),
                    (cx + hw - 10, top + 20),
                    (cx - hw + 10, top + 20),
                ],
                color,
                seed + 1,
                stroke_w=2,
            ),
        ]
    )


def _mitten(cx: float, cy: float, seed: int, flip: bool = False) -> str:
    """Simple mitten hand."""
    s = -1 if flip else 1
    return poly(
        [
            (cx - 8 * s, cy),
            (cx + 10 * s, cy - 2),
            (cx + 12 * s, cy + 14),
            (cx + 2 * s, cy + 18),
            (cx - 10 * s, cy + 12),
        ],
        SKIN,
        seed,
        stroke_w=3,
    )


def tea_master(seed: int = 200) -> str:
    """Kadai legend — balding fringe, heroic moustache, pouring filter coffee."""
    hx, hy = 104, 58
    parts = [
        _ground(110, 278, 48, seed),
        # legs
        poly([(68, 200), (98, 198), (102, 268), (64, 270)], "#3A2A1A", seed, stroke_w=5),
        poly([(112, 198), (142, 200), (146, 270), (116, 268)], "#3A2A1A", seed + 1, stroke_w=5),
        # slippers with toe strap
        poly([(52, 262), (100, 260), (102, 276), (50, 276)], "#5A4030", seed + 2, stroke_w=3),
        poly([(110, 260), (160, 262), (162, 276), (108, 276)], "#5A4030", seed + 3, stroke_w=3),
        line(60, 268, 92, 268, seed + 4, stroke_w=2, color="#3A2818"),
        line(118, 268, 150, 268, seed + 5, stroke_w=2, color="#3A2818"),
        # veshti with folds
        poly([(50, 150), (160, 146), (166, 216), (44, 220)], VESTHI, seed + 6, stroke_w=6),
        line(68, 162, 148, 176, seed + 7, stroke_w=3, color="#D8D0C0"),
        line(62, 188, 152, 200, seed + 8, stroke_w=2, color="#D8D0C0"),
        # cobalt shirt
        poly([(54, 90), (156, 86), (152, 162), (56, 166)], P["cobalt"], seed + 9, stroke_w=6),
        rect(120, 118, 24, 28, "#2F5A96", seed + 10, stroke_w=2, r=2),
        # left arm down + mitten
        poly([(26, 100), (56, 106), (50, 168), (22, 162)], SKIN, seed + 11, stroke_w=5),
        _mitten(34, 164, seed + 12, flip=True),
        # right arm raised pouring
        poly([(144, 102), (190, 70), (202, 118), (154, 148)], SKIN, seed + 13, stroke_w=5),
        _mitten(196, 108, seed + 14),
        # davara pour + steam + tumbler
        ellipse(204, 68, 24, 17, P["tea"], seed + 15, stroke_w=4, n=12),
        f'<path d="M 204 68 Q 240 48 228 22" fill="none" stroke="{P["tea"]}" '
        f'stroke-width="8" stroke-linecap="round"/>',
        f'<path d="M 216 20 Q 226 4 214 -4" fill="none" stroke="#FFFFFF" '
        f'stroke-width="3" opacity="0.55" stroke-linecap="round"/>',
        f'<path d="M 228 18 Q 238 2 230 -6" fill="none" stroke="#FFFFFF" '
        f'stroke-width="2.5" opacity="0.4" stroke-linecap="round"/>',
        poly([(206, 128), (236, 128), (230, 172), (210, 172)], "#D8E8F0", seed + 16, stroke_w=3),
        # towel on shoulder
        poly([(44, 86), (80, 76), (86, 120), (48, 128)], "#E8DCC8", seed + 17, stroke_w=4),
        line(52, 96, 78, 90, seed + 18, stroke_w=2, color="#D0C4B0"),
        # head
        ellipse(hx, hy, 40, 44, SKIN, seed + 19, stroke_w=6, n=14),
        # bald pate + fringe only at sides/back
        ellipse(hx, hy - 22, 22, 12, "#F2D9B0", seed + 20, stroke_w=0, n=8, opacity=0.55),
        poly(
            [(hx - 36, hy - 18), (hx - 28, hy - 34), (hx - 8, hy - 28), (hx - 30, hy - 8)],
            HAIR,
            seed + 21,
            stroke_w=3,
        ),
        poly(
            [(hx + 8, hy - 28), (hx + 28, hy - 34), (hx + 36, hy - 18), (hx + 30, hy - 8)],
            HAIR,
            seed + 22,
            stroke_w=3,
        ),
        *_face(hx, hy - 2, seed + 30, smile="soft"),
        _stache(hx, hy + 14, seed + 40, wide=44),
    ]
    return svg_doc(260, 290, group(parts), None)


def auto_driver(seed: int = 330) -> str:
    """Yellow-shirt auto anna — towel, squat stance, dangling keys."""
    hx, hy = 95, 52
    parts = [
        _ground(100, 272, 44, seed),
        poly([(56, 190), (90, 188), (98, 262), (52, 264)], "#2A2A2A", seed, stroke_w=5),
        poly([(100, 188), (134, 190), (140, 264), (102, 262)], "#2A2A2A", seed + 1, stroke_w=5),
        poly([(46, 256), (98, 254), (100, 270), (44, 270)], "#4A3020", seed + 2, stroke_w=3),
        poly([(100, 254), (154, 256), (156, 270), (98, 270)], "#4A3020", seed + 3, stroke_w=3),
        # dark green lungi
        poly([(44, 148), (146, 144), (152, 202), (40, 206)], "#1F3B2C", seed + 4, stroke_w=5),
        line(55, 168, 138, 178, seed + 5, stroke_w=2, color="#2F5B4C"),
        line(52, 188, 140, 194, seed + 6, stroke_w=2, color="#2F5B4C"),
        # yellow shirt
        poly([(46, 82), (144, 78), (140, 158), (48, 162)], P["auto_yellow"], seed + 7, stroke_w=6),
        poly([(76, 84), (95, 112), (114, 84)], "#E0A820", seed + 8, stroke_w=2),
        # arms
        poly([(20, 96), (50, 102), (46, 156), (18, 150)], SKIN, seed + 9, stroke_w=5),
        _mitten(28, 152, seed + 10, flip=True),
        poly([(136, 96), (170, 108), (164, 158), (132, 146)], SKIN, seed + 11, stroke_w=5),
        _mitten(162, 152, seed + 12),
        # towel
        poly([(38, 76), (74, 68), (80, 112), (42, 118)], "#F5EDE0", seed + 13, stroke_w=4),
        # keys on ring (clearer)
        ellipse(168, 130, 7, 7, "#C0A060", seed + 14, stroke_w=2, n=8),
        poly([(166, 136), (172, 136), (174, 158), (164, 158)], "#A08040", seed + 15, stroke_w=2),
        poly([(170, 140), (180, 138), (182, 154), (172, 156)], "#A08040", seed + 16, stroke_w=2),
        # head + hair ON crown
        ellipse(hx, hy, 34, 38, SKIN, seed + 17, stroke_w=6, n=14),
        _hair_cap(hx, hy - 36, 68, seed + 18),
        *_face(hx, hy - 2, seed + 30, smile="flat"),
        _stache(hx, hy + 12, seed + 40, wide=34),
    ]
    return svg_doc(200, 280, group(parts), None)


def directions_man(seed: int = 310) -> str:
    """Red-shirt uncle pointing the wrong way with confidence."""
    hx, hy = 95, 52
    parts = [
        _ground(100, 272, 42, seed),
        poly([(58, 194), (88, 192), (90, 262), (54, 264)], "#3A2A1A", seed, stroke_w=5),
        poly([(100, 192), (130, 194), (134, 264), (102, 262)], "#3A2A1A", seed + 1, stroke_w=5),
        poly([(46, 252), (92, 250), (94, 266), (44, 266)], "#5A4030", seed + 2, stroke_w=3),
        poly([(100, 250), (150, 252), (152, 266), (98, 266)], "#5A4030", seed + 3, stroke_w=3),
        # checkered lungi
        poly([(42, 150), (146, 146), (152, 206), (38, 210)], "#8B4513", seed + 4, stroke_w=5),
        line(50, 170, 142, 170, seed + 5, stroke_w=2, color="#6A3410"),
        line(50, 190, 142, 190, seed + 6, stroke_w=2, color="#6A3410"),
        line(72, 152, 72, 204, seed + 7, stroke_w=2, color="#6A3410"),
        line(112, 150, 112, 204, seed + 8, stroke_w=2, color="#6A3410"),
        # red shirt
        poly([(48, 86), (142, 82), (140, 158), (50, 162)], P["betel"], seed + 9, stroke_w=6),
        poly([(22, 98), (52, 104), (48, 158), (20, 152)], SKIN, seed + 10, stroke_w=5),
        _mitten(30, 154, seed + 11, flip=True),
        # pointing arm
        poly([(134, 96), (192, 74), (204, 108), (146, 128)], SKIN, seed + 12, stroke_w=5),
        # pointing finger
        poly([(198, 78), (228, 72), (230, 86), (200, 92)], SKIN, seed + 13, stroke_w=3),
        # head
        ellipse(hx, hy, 36, 38, SKIN, seed + 14, stroke_w=6, n=14),
        _hair_cap(hx, hy - 34, 66, seed + 15),
        # spectacles
        f'<circle cx="{hx - 12}" cy="{hy}" r="11" fill="none" stroke="{OUT}" stroke-width="3"/>',
        f'<circle cx="{hx + 12}" cy="{hy}" r="11" fill="none" stroke="{OUT}" stroke-width="3"/>',
        line(hx - 1, hy, hx + 1, hy, seed + 16, stroke_w=2),
        line(hx - 23, hy - 2, hx - 30, hy - 6, seed + 17, stroke_w=2),
        line(hx + 23, hy - 2, hx + 30, hy - 6, seed + 18, stroke_w=2),
        *_face(hx, hy, seed + 30, brow=False, smile="flat"),
        _stache(hx, hy + 14, seed + 40, color="#5A4A3A", wide=36),
    ]
    return svg_doc(240, 280, group(parts), None)


def kids(seed: int = 420) -> str:
    """School kid — short body, big head, backpack, bowl cut ABOVE eyes."""
    hx, hy = 88, 48
    parts = [
        _ground(90, 218, 34, seed),
        # short legs
        poly([(56, 148), (80, 146), (82, 204), (52, 206)], SKIN, seed, stroke_w=4),
        poly([(92, 146), (116, 148), (118, 206), (94, 204)], SKIN, seed + 1, stroke_w=4),
        poly([(46, 200), (84, 198), (86, 214), (44, 214)], "#6A4A30", seed + 2, stroke_w=2),
        poly([(90, 198), (128, 200), (130, 214), (88, 214)], "#6A4A30", seed + 3, stroke_w=2),
        # shorts
        poly([(48, 120), (124, 118), (128, 154), (44, 156)], P["cobalt"], seed + 4, stroke_w=5),
        # white shirt
        poly([(52, 72), (120, 70), (118, 126), (54, 128)], P["jasmine"], seed + 5, stroke_w=5),
        # backpack behind left
        poly([(28, 74), (56, 72), (54, 132), (26, 134)], P["betel"], seed + 6, stroke_w=4),
        ellipse(40, 98, 7, 9, P["auto_yellow"], seed + 7, stroke_w=2, n=8),
        # strap
        line(56, 78, 72, 88, seed + 8, stroke_w=3, color=P["betel"]),
        # arms
        poly([(114, 80), (142, 90), (136, 128), (110, 118)], SKIN, seed + 9, stroke_w=4),
        _mitten(134, 120, seed + 10),
        poly([(40, 82), (56, 86), (52, 118), (38, 114)], SKIN, seed + 11, stroke_w=4),
        # BIG head
        ellipse(hx, hy, 34, 36, SKIN, seed + 12, stroke_w=5, n=14),
        # soft bowl cut following skull (not a floating cap)
        ellipse(hx, hy - 18, 32, 22, HAIR, seed + 13, stroke_w=3, n=14),
        # short bangs just above brows
        poly(
            [
                (hx - 28, hy - 8),
                (hx - 18, hy - 14),
                (hx - 6, hy - 10),
                (hx + 6, hy - 14),
                (hx + 18, hy - 10),
                (hx + 28, hy - 8),
                (hx + 22, hy - 4),
                (hx - 22, hy - 4),
            ],
            HAIR,
            seed + 14,
            stroke_w=2,
        ),
        *_face(hx, hy + 2, seed + 30, smile="grin"),
    ]
    return svg_doc(170, 230, group(parts), None)


def bench_uncle(seed: int = 340) -> str:
    """Green-shirt bench regular — balding, cane, heavy grey stache."""
    hx, hy = 95, 54
    parts = [
        _ground(100, 272, 44, seed),
        poly([(56, 196), (86, 194), (88, 262), (52, 264)], "#3A2A1A", seed, stroke_w=5),
        poly([(100, 194), (130, 196), (134, 264), (102, 262)], "#3A2A1A", seed + 1, stroke_w=5),
        poly([(46, 254), (92, 252), (94, 268), (44, 268)], "#5A4030", seed + 2, stroke_w=3),
        poly([(98, 252), (148, 254), (150, 268), (96, 268)], "#5A4030", seed + 3, stroke_w=3),
        poly([(42, 152), (148, 148), (154, 210), (38, 214)], VESTHI, seed + 4, stroke_w=5),
        poly([(48, 88), (142, 84), (140, 162), (50, 166)], P["leaf"], seed + 5, stroke_w=6),
        # cane arm
        poly([(20, 100), (52, 106), (48, 168), (18, 162)], SKIN, seed + 6, stroke_w=5),
        _mitten(28, 164, seed + 7, flip=True),
        line(16, 110, 16, 258, seed + 8, stroke_w=6, color=P["wood"]),
        ellipse(16, 104, 10, 6, P["wood"], seed + 9, stroke_w=3, n=8),
        poly([(132, 100), (164, 112), (158, 158), (128, 148)], SKIN, seed + 10, stroke_w=5),
        _mitten(156, 150, seed + 11),
        # balding head
        ellipse(hx, hy, 36, 40, SKIN, seed + 12, stroke_w=6, n=14),
        ellipse(hx, hy - 18, 18, 10, "#F2D9B0", seed + 13, stroke_w=0, n=8, opacity=0.55),
        # grey side fringe only
        poly(
            [(hx - 34, hy - 8), (hx - 28, hy - 28), (hx - 10, hy - 22), (hx - 30, hy + 2)],
            "#6A5A4A",
            seed + 14,
            stroke_w=3,
        ),
        poly(
            [(hx + 10, hy - 22), (hx + 28, hy - 28), (hx + 34, hy - 8), (hx + 30, hy + 2)],
            "#6A5A4A",
            seed + 15,
            stroke_w=3,
        ),
        *_face(hx, hy - 2, seed + 30, smile="flat"),
        _stache(hx, hy + 14, seed + 40, color="#6A5A4A", wide=42),
    ]
    return svg_doc(180, 280, group(parts), None)


def street_auntie(seed: int = 360) -> str:
    """Sari auntie with flower basket — distinct from all the shirt-men."""
    hx, hy = 98, 56
    parts = [
        _ground(100, 272, 46, seed),
        poly([(56, 255), (90, 254), (92, 270), (54, 270)], SKIN, seed, stroke_w=3),
        poly([(108, 254), (142, 255), (144, 270), (106, 270)], SKIN, seed + 1, stroke_w=3),
        ellipse(72, 264, 5, 3, P["auto_yellow"], seed + 2, stroke_w=1, n=6),
        # sari skirt
        poly([(40, 152), (160, 150), (168, 264), (32, 266)], "#9B2D5A", seed + 3, stroke_w=6),
        line(55, 182, 152, 192, seed + 4, stroke_w=4, color="#C45A80"),
        line(48, 222, 158, 230, seed + 5, stroke_w=4, color="#C45A80"),
        # blouse
        poly([(56, 96), (140, 92), (136, 156), (58, 160)], "#E8A0B8", seed + 6, stroke_w=5),
        # pallu
        poly([(122, 92), (172, 102), (164, 214), (116, 202)], "#7A2048", seed + 7, stroke_w=5),
        # arms + basket
        poly([(26, 110), (58, 114), (54, 158), (24, 152)], SKIN, seed + 8, stroke_w=5),
        _mitten(34, 152, seed + 9, flip=True),
        poly([(130, 112), (160, 120), (154, 158), (128, 150)], SKIN, seed + 10, stroke_w=5),
        _mitten(150, 150, seed + 11),
        # basket of flowers
        poly([(54, 150), (128, 148), (124, 182), (56, 184)], P["wood"], seed + 12, stroke_w=4),
        ellipse(70, 158, 8, 8, "#F2C230", seed + 13, stroke_w=2, n=8),
        ellipse(90, 154, 8, 8, "#E87090", seed + 14, stroke_w=2, n=8),
        ellipse(110, 160, 8, 8, P["jasmine"], seed + 15, stroke_w=2, n=8),
        ellipse(80, 168, 6, 6, "#FFFFFF", seed + 16, stroke_w=1, n=8),
        # head
        ellipse(hx, hy, 34, 38, SKIN, seed + 17, stroke_w=6, n=14),
        # hair + bun (bun clearly behind/above, not over eyes)
        poly(
            [
                (hx - 32, hy - 8),
                (hx - 28, hy - 32),
                (hx + 8, hy - 36),
                (hx + 28, hy - 28),
                (hx + 30, hy - 8),
                (hx + 18, hy - 4),
                (hx - 18, hy - 4),
            ],
            HAIR,
            seed + 18,
            stroke_w=3,
        ),
        ellipse(hx + 28, hy - 18, 16, 18, HAIR, seed + 19, stroke_w=4, n=10),
        # jasmine cluster ON the bun (not on face)
        ellipse(hx + 30, hy - 28, 5, 5, P["jasmine"], seed + 20, stroke_w=1, n=8),
        ellipse(hx + 38, hy - 22, 4, 4, P["jasmine"], seed + 21, stroke_w=1, n=8),
        ellipse(hx + 24, hy - 20, 4, 4, P["jasmine"], seed + 22, stroke_w=1, n=8),
        # bindi
        ellipse(hx, hy - 8, 3.5, 3.5, P["betel"], seed + 23, stroke_w=1, n=6),
        *_face(hx, hy + 2, seed + 30, smile="soft"),
    ]
    return svg_doc(200, 280, group(parts), None)


def all_assets() -> dict[str, str]:
    return {
        "chars/tea_master.svg": tea_master(),
        "chars/local_yellow.svg": auto_driver(),
        "chars/local_red.svg": directions_man(),
        "chars/kids.svg": kids(),
        "chars/local_green.svg": bench_uncle(),
        "chars/local_blue.svg": street_auntie(),
        "chars/local_auntie.svg": street_auntie(361),
    }
