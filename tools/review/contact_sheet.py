#!/usr/bin/env python3
"""Tile every art/svg/*.svg onto review/contact_sheet.png with labels."""
from __future__ import annotations

import math
import re
import xml.etree.ElementTree as ET
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[2]
SVG_DIR = ROOT / "art" / "svg"
OUT = ROOT / "review" / "contact_sheet.png"
CELL = 280
LABEL_H = 32
PAD = 8
NS = {"s": "http://www.w3.org/2000/svg"}


def _parse_color(c: str | None, default=(43, 29, 20, 255)):
    if not c or c == "none":
        return None
    if c.startswith("#") and len(c) == 7:
        r = int(c[1:3], 16)
        g = int(c[3:5], 16)
        b = int(c[5:7], 16)
        return (r, g, b, 255)
    return default


def _parse_points(d: str) -> list[tuple[float, float]]:
    # Support M/L/Q/Z polyline subset
    tokens = re.findall(r"[MmLlQqZz]|-?\d*\.?\d+", d)
    pts: list[tuple[float, float]] = []
    i = 0
    cx = cy = 0.0
    mode = "L"
    while i < len(tokens):
        t = tokens[i]
        if t.isalpha():
            mode = t
            i += 1
            if mode in "Zz":
                if pts:
                    pts.append(pts[0])
            continue
        if mode in "MmLl":
            x = float(tokens[i])
            y = float(tokens[i + 1])
            i += 2
            if mode in "Mm" and not pts:
                pts.append((x, y))
            else:
                pts.append((x, y))
            cx, cy = x, y
            mode = "L" if mode in "Mm" else mode
        elif mode in "Qq":
            # quadratic — sample
            x1, y1 = float(tokens[i]), float(tokens[i + 1])
            x2, y2 = float(tokens[i + 2]), float(tokens[i + 3])
            i += 4
            for s in range(1, 9):
                t = s / 8
                x = (1 - t) ** 2 * cx + 2 * (1 - t) * t * x1 + t**2 * x2
                y = (1 - t) ** 2 * cy + 2 * (1 - t) * t * y1 + t**2 * y2
                pts.append((x, y))
            cx, cy = x2, y2
        else:
            i += 1
    return pts


def render_svg(path: Path, size: int = CELL - 24) -> Image.Image:
    tree = ET.parse(path)
    root = tree.getroot()
    vb = root.get("viewBox")
    if vb:
        _, _, vw, vh = [float(x) for x in vb.split()]
    else:
        vw = float(root.get("width", size))
        vh = float(root.get("height", size))
    scale = min(size / max(vw, 1), size / max(vh, 1))
    w, h = int(vw * scale), int(vh * scale)
    img = Image.new("RGBA", (max(w, 1), max(h, 1)), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    def xf(x: float, y: float) -> tuple[float, float]:
        return x * scale, y * scale

    def draw_el(el, opacity=1.0):
        tag = el.tag.split("}")[-1]
        if tag == "g":
            op = float(el.get("opacity", opacity))
            for child in el:
                draw_el(child, op)
            return
        if tag == "rect":
            x = float(el.get("x", 0)) * scale
            y = float(el.get("y", 0)) * scale
            rw = float(el.get("width", 0)) * scale
            rh = float(el.get("height", 0)) * scale
            fill = _parse_color(el.get("fill"))
            stroke = _parse_color(el.get("stroke"))
            sw = max(1, int(float(el.get("stroke-width", 1)) * scale * 0.5))
            if fill:
                f = (*fill[:3], int(255 * opacity))
                draw.rectangle([x, y, x + rw, y + rh], fill=f)
            if stroke:
                s = (*stroke[:3], int(255 * opacity))
                draw.rectangle([x, y, x + rw, y + rh], outline=s, width=sw)
        elif tag == "circle":
            cx = float(el.get("cx", 0)) * scale
            cy = float(el.get("cy", 0)) * scale
            r = float(el.get("r", 0)) * scale
            fill = _parse_color(el.get("fill"), None)
            stroke = _parse_color(el.get("stroke"))
            sw = max(1, int(float(el.get("stroke-width", 1)) * scale * 0.5))
            bbox = [cx - r, cy - r, cx + r, cy + r]
            if fill:
                draw.ellipse(bbox, fill=(*fill[:3], int(255 * opacity)))
            if stroke:
                draw.ellipse(bbox, outline=(*stroke[:3], int(255 * opacity)), width=sw)
        elif tag == "ellipse":
            cx = float(el.get("cx", 0)) * scale
            cy = float(el.get("cy", 0)) * scale
            rx = float(el.get("rx", 0)) * scale
            ry = float(el.get("ry", 0)) * scale
            fill = _parse_color(el.get("fill"), None)
            stroke = _parse_color(el.get("stroke"))
            sw = max(1, int(float(el.get("stroke-width", 1)) * scale * 0.5))
            bbox = [cx - rx, cy - ry, cx + rx, cy + ry]
            if fill:
                draw.ellipse(bbox, fill=(*fill[:3], int(255 * opacity)))
            if stroke:
                draw.ellipse(bbox, outline=(*stroke[:3], int(255 * opacity)), width=sw)
        elif tag == "path":
            d = el.get("d", "")
            pts = [xf(x, y) for x, y in _parse_points(d)]
            if len(pts) < 2:
                return
            fill = _parse_color(el.get("fill"), None)
            stroke = _parse_color(el.get("stroke"))
            sw = max(1, int(float(el.get("stroke-width", 4)) * scale * 0.45))
            if fill and el.get("fill") != "none":
                draw.polygon(pts, fill=(*fill[:3], int(255 * opacity)))
            if stroke or el.get("fill") == "none":
                col = stroke or (43, 29, 20, 255)
                draw.line(pts, fill=(*col[:3], int(255 * opacity)), width=sw, joint="curve")
        elif tag == "text":
            x = float(el.get("x", 0)) * scale
            y = float(el.get("y", 0)) * scale
            fill = _parse_color(el.get("fill")) or (43, 29, 20, 255)
            text = (el.text or "").strip()
            fs = max(8, int(float(el.get("font-size", 14)) * scale * 0.7))
            try:
                font = ImageFont.truetype(
                    "/System/Library/Fonts/Supplemental/Arial Unicode.ttf", fs
                )
            except Exception:
                font = ImageFont.load_default()
            anchor = el.get("text-anchor", "start")
            if anchor == "middle":
                bbox = draw.textbbox((0, 0), text, font=font)
                x -= (bbox[2] - bbox[0]) / 2
            draw.text((x, y - fs), text, fill=(*fill[:3], int(255 * opacity)), font=font)

    for child in root:
        draw_el(child)
    return img


def main() -> None:
    files = sorted(SVG_DIR.rglob("*.svg"))
    if not files:
        raise SystemExit("No SVGs — run tools/art/build.py first")

    cols = 5
    rows = int(math.ceil(len(files) / cols))
    sheet = Image.new("RGB", (cols * CELL, rows * (CELL + LABEL_H)), (246, 231, 193))
    draw = ImageDraw.Draw(sheet)
    try:
        font = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial Unicode.ttf", 11)
    except Exception:
        font = ImageFont.load_default()

    for i, path in enumerate(files):
        r, c = divmod(i, cols)
        x, y = c * CELL, r * (CELL + LABEL_H)
        thumb = render_svg(path)
        tx = x + (CELL - thumb.width) // 2
        ty = y + (CELL - thumb.height) // 2
        # cell bg
        draw.rectangle([x + 2, y + 2, x + CELL - 3, y + CELL - 3], outline=(43, 29, 20), width=2)
        sheet.paste(thumb, (tx, ty), thumb)
        draw.text((x + PAD, y + CELL + 6), str(path.relative_to(SVG_DIR))[:42], fill=(43, 29, 20), font=font)

    OUT.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(OUT)
    print(f"wrote {OUT} ({len(files)} tiles)")


if __name__ == "__main__":
    main()
