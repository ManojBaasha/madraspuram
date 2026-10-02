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


def stray_dog(seed: int = 370) -> str:
    """Chunky Madras street dog — readable silhouette, not stick legs."""
    fur = "#9A7352"
    dark = "#6B4E36"
    belly = "#C9A88A"
    parts = [
        ellipse(85, 118, 48, 12, P["shadow"], seed, stroke_w=0, n=10, opacity=0.16),
        # curly tail up
        f'<path d="M 148 48 Q 175 28 168 55 Q 162 70 150 62" fill="none" stroke="{dark}" '
        f'stroke-width="7" stroke-linecap="round"/>',
        # hind legs (behind)
        poly([(118, 78), (138, 78), (142, 118), (120, 118)], dark, seed + 1, stroke_w=4),
        poly([(100, 80), (118, 80), (120, 118), (98, 118)], dark, seed + 2, stroke_w=4),
        # body sausage
        poly([(40, 48), (145, 42), (152, 88), (38, 92)], fur, seed + 3, stroke_w=6),
        # belly lighter
        poly([(55, 72), (130, 70), (128, 90), (58, 92)], belly, seed + 4, stroke_w=2),
        # ribs hint
        line(70, 58, 70, 78, seed + 5, stroke_w=2, color=dark),
        line(88, 56, 88, 78, seed + 6, stroke_w=2, color=dark),
        line(106, 54, 106, 76, seed + 7, stroke_w=2, color=dark),
        # front legs thick
        poly([(48, 82), (68, 82), (66, 120), (46, 120)], dark, seed + 8, stroke_w=4),
        poly([(68, 84), (86, 84), (88, 120), (70, 120)], dark, seed + 9, stroke_w=4),
        # paws
        ellipse(56, 120, 12, 6, "#5A4030", seed + 10, stroke_w=2, n=8),
        ellipse(78, 120, 12, 6, "#5A4030", seed + 11, stroke_w=2, n=8),
        ellipse(110, 118, 11, 5, "#5A4030", seed + 12, stroke_w=2, n=8),
        ellipse(132, 118, 11, 5, "#5A4030", seed + 13, stroke_w=2, n=8),
        # neck
        poly([(28, 55), (50, 50), (52, 78), (30, 80)], fur, seed + 14, stroke_w=4),
        # head
        ellipse(28, 52, 24, 20, fur, seed + 15, stroke_w=6, n=12),
        # floppy ear
        poly([(18, 30), (36, 36), (28, 58), (12, 50)], dark, seed + 16, stroke_w=4),
        # snout
        poly([(2, 54), (28, 48), (30, 68), (4, 66)], belly, seed + 17, stroke_w=4),
        # nose
        ellipse(4, 58, 5, 4, P["outline"], seed + 18, stroke_w=2, n=6),
        # eye
        ellipse(22, 48, 4, 5, "#FFF8F0", seed + 19, stroke_w=2, n=6),
        ellipse(22, 49, 2, 2.5, P["outline"], seed + 20, stroke_w=1, n=6),
        # tongue pant
        poly([(12, 66), (22, 66), (20, 78), (14, 78)], P["betel"], seed + 21, stroke_w=2),
        # collar scrap
        poly([(34, 62), (52, 58), (54, 68), (36, 72)], P["betel"], seed + 22, stroke_w=2),
    ]
    return svg_doc(190, 140, group(parts), None)


def radio_set(seed: int = 380) -> str:
    parts = [
        rect(10, 30, 110, 70, P["ochre"], seed, stroke_w=5, r=4),
        rect(20, 40, 50, 30, P["robot_screen"], seed + 1, stroke_w=3, r=2),
        ellipse(95, 55, 14, 14, P["robot_white"], seed + 2, stroke_w=3, n=10),
        ellipse(95, 55, 4, 4, P["outline"], seed + 3, stroke_w=2, n=6),
        # speaker grill lines
        line(25, 78, 55, 78, seed + 4, stroke_w=2),
        line(25, 84, 55, 84, seed + 5, stroke_w=2),
        line(25, 90, 55, 90, seed + 6, stroke_w=2),
        # antenna
        line(100, 30, 120, 8, seed + 7, stroke_w=3, color=P["outline"]),
        ellipse(122, 6, 4, 4, P["betel"], seed + 8, stroke_w=2, n=6),
    ]
    return svg_doc(140, 110, group(parts), None)


def biscuit_jar(seed: int = 390) -> str:
    """Glass jar stuffed with Britannia-adjacent biscuits — not a tumbler row."""
    parts = [
        ellipse(60, 125, 36, 10, P["shadow"], seed, stroke_w=0, n=10, opacity=0.15),
        # jar body (glass)
        poly([(28, 40), (92, 38), (98, 115), (22, 118)], "#D8E8F0", seed + 1, stroke_w=5, opacity=0.75),
        # biscuits stacked
        rect(36, 55, 48, 12, "#E8C070", seed + 2, stroke_w=2, r=2),
        rect(34, 70, 50, 12, "#D4A858", seed + 3, stroke_w=2, r=2),
        rect(38, 85, 46, 12, "#E8C070", seed + 4, stroke_w=2, r=2),
        rect(36, 98, 48, 10, "#C89040", seed + 5, stroke_w=2, r=2),
        # lid
        ellipse(60, 36, 38, 14, P["betel"], seed + 6, stroke_w=4, n=12),
        rect(30, 28, 60, 12, P["betel"], seed + 7, stroke_w=3),
        # label
        rect(40, 72, 40, 18, P["jasmine"], seed + 8, stroke_w=2),
        f'<text x="60" y="85" text-anchor="middle" font-size="9" fill="{P["outline"]}">பிஸ்கட்</text>',
    ]
    return svg_doc(120, 140, group(parts), None)


def auto_meter(seed: int = 400) -> str:
    """Useless yellow fare meter — the classic auto stand gag."""
    parts = [
        ellipse(55, 95, 40, 10, P["shadow"], seed, stroke_w=0, n=10, opacity=0.15),
        # body
        rect(15, 20, 80, 60, P["auto_yellow"], seed + 1, stroke_w=5, r=4),
        # screen
        rect(25, 30, 60, 28, P["robot_screen"], seed + 2, stroke_w=3, r=2),
        f'<text x="55" y="50" text-anchor="middle" font-size="16" '
        f'font-family="sans-serif" fill="{P["robot_glow"]}">88.80</text>',
        # buttons
        ellipse(35, 70, 6, 6, P["betel"], seed + 3, stroke_w=2, n=8),
        ellipse(55, 70, 6, 6, P["leaf"], seed + 4, stroke_w=2, n=8),
        ellipse(75, 70, 6, 6, P["cobalt"], seed + 5, stroke_w=2, n=8),
        # FOR HIRE flag stub
        poly([(95, 25), (118, 18), (118, 40), (95, 42)], P["betel"], seed + 6, stroke_w=3),
        f'<text x="106" y="34" text-anchor="middle" font-size="7" fill="{P["jasmine"]}">HIRE</text>',
    ]
    return svg_doc(130, 110, group(parts), None)


def coconut_pile(seed: int = 410) -> str:
    """Green tender coconut pile + machete — not a water pot."""
    green = "#3F6B3A"
    husk = "#8B6B3A"
    parts = [
        ellipse(90, 118, 70, 12, P["shadow"], seed, stroke_w=0, n=10, opacity=0.16),
        # pile of coconuts
        ellipse(50, 85, 28, 26, green, seed + 1, stroke_w=5, n=12),
        ellipse(90, 90, 30, 28, green, seed + 2, stroke_w=5, n=12),
        ellipse(130, 82, 26, 24, green, seed + 3, stroke_w=5, n=12),
        ellipse(70, 60, 26, 24, green, seed + 4, stroke_w=5, n=12),
        ellipse(110, 58, 28, 26, green, seed + 5, stroke_w=5, n=12),
        # white cut face on one
        ellipse(90, 88, 12, 12, P["jasmine"], seed + 6, stroke_w=3, n=10),
        ellipse(90, 88, 5, 5, "#E8F0D8", seed + 7, stroke_w=1, n=6),
        # brown mature ones at base
        ellipse(40, 105, 18, 16, husk, seed + 8, stroke_w=4, n=10),
        ellipse(145, 100, 16, 14, husk, seed + 9, stroke_w=4, n=10),
        # machete stuck in pile
        poly([(150, 30), (170, 25), (168, 35), (148, 40)], "#C0C4C8", seed + 10, stroke_w=3),
        poly([(130, 38), (152, 32), (154, 42), (132, 48)], P["wood"], seed + 11, stroke_w=3),
        # leaf fringe
        line(70, 40, 55, 20, seed + 12, stroke_w=4, color=green),
        line(110, 38, 125, 18, seed + 13, stroke_w=4, color=green),
    ]
    return svg_doc(190, 130, group(parts), None)


def auto_horn(seed: int = 420) -> str:
    """Rubber bulb horn — the peep peep prop, not a tiny auto."""
    parts = [
        ellipse(70, 85, 40, 10, P["shadow"], seed, stroke_w=0, n=10, opacity=0.14),
        # bulb
        ellipse(45, 50, 32, 28, P["betel"], seed + 1, stroke_w=5, n=12),
        ellipse(38, 42, 8, 6, "#D06050", seed + 2, stroke_w=0, n=8, opacity=0.5),
        # metal horn tube
        poly([(70, 45), (130, 30), (135, 50), (75, 58)], "#C0C4C8", seed + 3, stroke_w=4),
        # flare
        poly([(125, 28), (155, 18), (158, 55), (128, 52)], "#A8ACB0", seed + 4, stroke_w=4),
        # ring detail
        ellipse(78, 50, 6, 8, P["auto_yellow"], seed + 5, stroke_w=2, n=8),
    ]
    return svg_doc(170, 100, group(parts), None)


def steam_pot(seed: int = 430) -> str:
    """Brass filter-coffee davara stack with steam — distinct from blue plastic pot."""
    brass = "#C4A35A"
    parts = [
        ellipse(70, 120, 45, 10, P["shadow"], seed, stroke_w=0, n=10, opacity=0.15),
        # lower tumbler
        poly([(45, 70), (95, 68), (100, 110), (40, 112)], "#D8E8F0", seed + 1, stroke_w=4),
        poly([(52, 85), (88, 84), (90, 108), (50, 110)], P["tea"], seed + 2, stroke_w=2),
        # upper davara
        ellipse(70, 55, 38, 20, brass, seed + 3, stroke_w=5, n=12),
        rect(40, 48, 60, 22, brass, seed + 4, stroke_w=4),
        # handle
        f'<path d="M 108 55 Q 130 45 125 70" fill="none" stroke="{brass}" '
        f'stroke-width="6" stroke-linecap="round"/>',
        # steam curls
        f'<path d="M 55 40 Q 50 20 60 10" fill="none" stroke="#FFFFFF" '
        f'stroke-width="3" opacity="0.55" stroke-linecap="round"/>',
        f'<path d="M 75 38 Q 78 15 70 5" fill="none" stroke="#FFFFFF" '
        f'stroke-width="3" opacity="0.5" stroke-linecap="round"/>',
        f'<path d="M 90 42 Q 100 22 95 8" fill="none" stroke="#FFFFFF" '
        f'stroke-width="2.5" opacity="0.45" stroke-linecap="round"/>',
    ]
    return svg_doc(145, 135, group(parts), None)


def water_can(seed: int = 440) -> str:
    """Blue plastic 20L water can — the real Chennai sidewalk icon."""
    parts = [
        ellipse(55, 125, 40, 10, P["shadow"], seed, stroke_w=0, n=10, opacity=0.15),
        # body
        poly([(20, 35), (90, 32), (95, 115), (15, 118)], P["cobalt"], seed + 1, stroke_w=6),
        # ridge rings
        line(22, 55, 92, 52, seed + 2, stroke_w=3, color="#2F5A96"),
        line(20, 80, 94, 78, seed + 3, stroke_w=3, color="#2F5A96"),
        # neck + cap
        rect(42, 18, 26, 22, P["cobalt"], seed + 4, stroke_w=4),
        rect(38, 12, 34, 12, "#F2C230", seed + 5, stroke_w=3),
        # handle
        f'<path d="M 90 50 Q 115 55 95 85" fill="none" stroke="#2F5A96" '
        f'stroke-width="7" stroke-linecap="round"/>',
        # Aquafina-adjacent sticker
        rect(35, 60, 40, 22, P["jasmine"], seed + 6, stroke_w=2),
        f'<text x="55" y="75" text-anchor="middle" font-size="10" fill="{P["cobalt"]}">WATER</text>',
    ]
    return svg_doc(125, 140, group(parts), None)


def all_assets() -> dict[str, str]:
    return {
        "props/auto.svg": auto_rickshaw(),
        "props/tea_glasses.svg": tea_glasses(),
        "props/banana_bunch.svg": banana_bunch(),
        "props/signboard.svg": signboard(),
        "props/water_pot.svg": water_can(),  # upgrade: plastic can, keep path for existing refs
        "props/cutout.svg": hero_cutout(),
        "props/milk_packet.svg": milk_packet(),
        "props/dog.svg": stray_dog(),
        "props/radio.svg": radio_set(),
        "props/biscuit_jar.svg": biscuit_jar(),
        "props/auto_meter.svg": auto_meter(),
        "props/coconut_pile.svg": coconut_pile(),
        "props/horn.svg": auto_horn(),
        "props/steam_pot.svg": steam_pot(),
    }
