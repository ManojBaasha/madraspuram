"""Shared SVG primitives: palette, jittered paths, outlined shapes."""
from __future__ import annotations

import math
import random
from typing import Iterable, Sequence

PALETTE = {
    "outline": "#2B1D14",
    "sky": "#F6E7C1",
    "plaster": "#E9C98B",
    "cobalt": "#3E6FB0",
    "auto_yellow": "#F2C230",
    "auto_trim": "#1F3B2C",
    "ochre": "#C8763A",
    "kolam": "#FBF7EE",
    "betel": "#B23A2E",
    "jasmine": "#FFFDF4",
    "robot": "#7A9BB8",
    "robot_white": "#E8EEF2",
    "robot_screen": "#1A2430",
    "robot_glow": "#A8E6CF",
    "shadow": "#000000",
    "wood": "#8B5A2B",
    "tea": "#C4A35A",
    "banana": "#E8C84A",
    "leaf": "#3F6B3A",
}


def rng(seed: int) -> random.Random:
    return random.Random(seed)


def jitter_polyline(
    points: Sequence[tuple[float, float]],
    seed: int,
    amp: float = 1.5,
) -> list[tuple[float, float]]:
    r = rng(seed)
    out: list[tuple[float, float]] = []
    for i, (x, y) in enumerate(points):
        if i == 0 or i == len(points) - 1:
            out.append((x, y))
            continue
        out.append((x + r.uniform(-amp, amp), y + r.uniform(-amp, amp)))
    return out


def path_d(points: Sequence[tuple[float, float]], closed: bool = False) -> str:
    if not points:
        return ""
    parts = [f"M {points[0][0]:.2f} {points[0][1]:.2f}"]
    for x, y in points[1:]:
        parts.append(f"L {x:.2f} {y:.2f}")
    if closed:
        parts.append("Z")
    return " ".join(parts)


def poly(
    points: Sequence[tuple[float, float]],
    fill: str,
    seed: int,
    stroke: str | None = None,
    stroke_w: float = 6,
    amp: float = 1.4,
    closed: bool = True,
    opacity: float = 1.0,
) -> str:
    stroke = stroke or PALETTE["outline"]
    pts = jitter_polyline(points, seed, amp)
    op = f' opacity="{opacity}"' if opacity < 1 else ""
    return (
        f'<path d="{path_d(pts, closed)}" fill="{fill}" '
        f'stroke="{stroke}" stroke-width="{stroke_w}" '
        f'stroke-linejoin="round" stroke-linecap="round"{op}/>'
    )


def ellipse(
    cx: float,
    cy: float,
    rx: float,
    ry: float,
    fill: str,
    seed: int,
    stroke_w: float = 6,
    n: int = 16,
    stroke: str | None = None,
    opacity: float = 1.0,
) -> str:
    if stroke_w <= 0:
        stroke = "none"
        stroke_w = 0
    pts = []
    for i in range(n):
        a = (2 * math.pi * i) / n
        pts.append((cx + math.cos(a) * rx, cy + math.sin(a) * ry))
    return poly(
        pts,
        fill,
        seed,
        stroke=stroke,
        stroke_w=max(stroke_w, 0),
        amp=1.2,
        opacity=opacity,
    )


def circle_ring(
    cx: float,
    cy: float,
    r: float,
    stroke: str,
    stroke_w: float = 3,
) -> str:
    return (
        f'<circle cx="{cx:.1f}" cy="{cy:.1f}" r="{r:.1f}" fill="none" '
        f'stroke="{stroke}" stroke-width="{stroke_w}"/>'
    )


def rect(
    x: float,
    y: float,
    w: float,
    h: float,
    fill: str,
    seed: int,
    stroke_w: float = 6,
    r: float = 0,
) -> str:
    if r <= 0:
        pts = [(x, y), (x + w, y), (x + w, y + h), (x, y + h)]
        return poly(pts, fill, seed, stroke_w=stroke_w)
    # simple rounded as polygon approx
    return (
        f'<rect x="{x:.1f}" y="{y:.1f}" width="{w:.1f}" height="{h:.1f}" '
        f'rx="{r}" fill="{fill}" stroke="{PALETTE["outline"]}" '
        f'stroke-width="{stroke_w}"/>'
    )


def line(
    x1: float,
    y1: float,
    x2: float,
    y2: float,
    seed: int,
    stroke_w: float = 4,
    color: str | None = None,
) -> str:
    color = color or PALETTE["outline"]
    pts = jitter_polyline([(x1, y1), ((x1 + x2) / 2, (y1 + y2) / 2), (x2, y2)], seed, 1.0)
    return (
        f'<path d="{path_d(pts, False)}" fill="none" stroke="{color}" '
        f'stroke-width="{stroke_w}" stroke-linecap="round"/>'
    )


def svg_doc(w: int, h: int, body: str, bg: str | None = None) -> str:
    bg_rect = ""
    if bg:
        bg_rect = f'<rect width="{w}" height="{h}" fill="{bg}"/>'
    return (
        f'<?xml version="1.0" encoding="UTF-8"?>\n'
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{h}" '
        f'viewBox="0 0 {w} {h}">\n{bg_rect}\n{body}\n</svg>\n'
    )


def group(
    parts: Iterable[str],
    transform: str = "",
    opacity: float | None = None,
) -> str:
    attrs = ""
    if transform:
        attrs += f' transform="{transform}"'
    if opacity is not None:
        attrs += f' opacity="{opacity}"'
    return f"<g{attrs}>\n" + "\n".join(parts) + "\n</g>"
