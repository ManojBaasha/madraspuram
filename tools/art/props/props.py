"""Prop SVG generators."""
from __future__ import annotations

from tools.art.primitives import PALETTE as P
from tools.art.primitives import ellipse, group, line, poly, rect, svg_doc


def auto_rickshaw(seed: int = 300) -> str:
    parts = [
        # rear cabin
        poly([(15, 75), (95, 55), (110, 125), (10, 130)], P["auto_yellow"], seed, stroke_w=6),
        # front nose
        poly([(95, 70), (175, 85), (170, 130), (100, 125)], P["auto_yellow"], seed + 1, stroke_w=6),
        # canopy bars
        poly([(25, 40), (100, 30), (115, 75), (20, 80)], P["auto_yellow"], seed + 2, stroke_w=5),
        line(40, 45, 40, 75, seed + 20, stroke_w=4),
        line(75, 38, 75, 72, seed + 21, stroke_w=4),
        # green-black trim stripe
        poly([(12, 118), (172, 112), (172, 128), (10, 132)], P["auto_trim"], seed + 3, stroke_w=4),
        # wheels
        ellipse(48, 145, 24, 24, P["outline"], seed + 4, stroke_w=5, n=12),
        ellipse(48, 145, 10, 10, P["plaster"], seed + 5, stroke_w=3, n=10),
        ellipse(150, 142, 24, 24, P["outline"], seed + 6, stroke_w=5, n=12),
        ellipse(150, 142, 10, 10, P["plaster"], seed + 7, stroke_w=3, n=10),
        # decorative meter (clearly useless)
        rect(100, 88, 32, 26, P["robot_white"], seed + 8, stroke_w=4, r=2),
        f'<text x="116" y="106" text-anchor="middle" font-size="10" fill="{P["outline"]}">88</text>',
        # horn
        ellipse(20, 95, 12, 9, P["betel"], seed + 9, stroke_w=3, n=10),
        # headlight
        ellipse(170, 105, 8, 8, P["jasmine"], seed + 10, stroke_w=3, n=8),
    ]
    return svg_doc(200, 180, group(parts), None)


def tea_glasses(seed: int = 310) -> str:
    parts = []
    for i, x in enumerate((20, 55, 90, 125)):
        parts.append(poly(
            [(x, 30), (x + 24, 30), (x + 20, 80), (x + 4, 80)],
            "#D8E8F0",
            seed + i,
            stroke_w=4,
            opacity=0.85,
        ))
        parts.append(poly(
            [(x + 6, 50), (x + 18, 50), (x + 16, 78), (x + 8, 78)],
            P["tea"],
            seed + 10 + i,
            stroke_w=2,
        ))
    return svg_doc(170, 100, group(parts), None)


def banana_bunch(seed: int = 320) -> str:
    parts = [
        line(80, 10, 80, 40, seed, stroke_w=5, color=P["leaf"]),
        ellipse(55, 70, 22, 40, P["banana"], seed + 1, stroke_w=4, n=12),
        ellipse(80, 75, 22, 42, P["banana"], seed + 2, stroke_w=4, n=12),
        ellipse(105, 70, 22, 40, P["banana"], seed + 3, stroke_w=4, n=12),
        ellipse(70, 55, 18, 28, P["banana"], seed + 4, stroke_w=4, n=12),
        ellipse(90, 55, 18, 28, P["banana"], seed + 5, stroke_w=4, n=12),
    ]
    return svg_doc(160, 130, group(parts), None)


def signboard(seed: int = 330) -> str:
    # Tamil-first sign (text as paths approximation via font text for contact sheet)
    parts = [
        rect(10, 20, 220, 100, P["cobalt"], seed, stroke_w=6, r=4),
        rect(18, 28, 204, 84, P["plaster"], seed + 1, stroke_w=3, r=2),
        f'<text x="120" y="70" text-anchor="middle" font-size="28" '
        f'font-family="Noto Sans Tamil, sans-serif" fill="{P["outline"]}" '
        f'transform="rotate(-2 120 70)">டீ கடை</text>',
        f'<text x="120" y="98" text-anchor="middle" font-size="14" '
        f'font-family="sans-serif" fill="{P["betel"]}" '
        f'transform="rotate(-1 120 98)">TEA SHOP · Since 1987</text>',
        # pole
        rect(110, 120, 12, 50, P["wood"], seed + 2, stroke_w=4),
    ]
    return svg_doc(240, 180, group(parts), None)


def water_pot(seed: int = 340) -> str:
    parts = [
        ellipse(60, 70, 40, 48, P["cobalt"], seed, stroke_w=6, n=14),
        ellipse(60, 35, 18, 12, P["cobalt"], seed + 1, stroke_w=4, n=10),
        ellipse(60, 55, 12, 6, P["robot_white"], seed + 2, stroke_w=2, n=8),
    ]
    return svg_doc(120, 130, group(parts), None)


def hero_cutout(seed: int = 350) -> str:
    # Parody mass-hero silhouette cutout (not a real star)
    parts = [
        # board
        rect(10, 10, 140, 220, P["betel"], seed, stroke_w=6),
        # body silhouette
        poly([(40, 80), (120, 70), (130, 200), (30, 210)], P["auto_yellow"], seed + 1, stroke_w=5),
        ellipse(80, 55, 32, 36, P["plaster"], seed + 2, stroke_w=5, n=12),
        # shades
        poly([(58, 50), (102, 48), (100, 60), (56, 62)], P["outline"], seed + 3, stroke_w=2),
        # pose arm
        poly([(120, 100), (160, 70), (155, 90), (125, 120)], P["plaster"], seed + 4, stroke_w=4),
        f'<text x="80" y="235" text-anchor="middle" font-size="12" '
        f'fill="{P["outline"]}">மாஸ் ஹீரோ சுந்தர்</text>',
    ]
    return svg_doc(180, 260, group(parts), None)


def milk_packet(seed: int = 360) -> str:
    parts = [
        poly([(20, 20), (90, 15), (95, 110), (15, 115)], P["robot_white"], seed, stroke_w=5),
        rect(30, 35, 50, 30, P["betel"], seed + 1, stroke_w=3),
        f'<text x="55" y="55" text-anchor="middle" font-size="14" fill="{P["kolam"]}">பாவின்</text>',
        f'<text x="55" y="85" text-anchor="middle" font-size="11" fill="{P["outline"]}">MILK</text>',
    ]
    return svg_doc(110, 130, group(parts), None)


def all_assets() -> dict[str, str]:
    return {
        "props/auto.svg": auto_rickshaw(),
        "props/tea_glasses.svg": tea_glasses(),
        "props/banana_bunch.svg": banana_bunch(),
        "props/signboard.svg": signboard(),
        "props/water_pot.svg": water_pot(),
        "props/cutout.svg": hero_cutout(),
        "props/milk_packet.svg": milk_packet(),
    }
