"""Algorithmic kolam from a dot grid with loop-around-dot rules."""
from __future__ import annotations

from tools.art.primitives import PALETTE as P
from tools.art.primitives import svg_doc


def kolam(n: int = 5, spacing: float = 28.0, seed: int = 400) -> str:
    margin = 40.0
    size = margin * 2 + spacing * (n - 1)
    dots = []
    for r in range(n):
        for c in range(n):
            x = margin + c * spacing
            y = margin + r * spacing
            dots.append(
                f'<circle cx="{x:.1f}" cy="{y:.1f}" r="3.2" fill="{P["outline"]}"/>'
            )

    # loop curves around each interior edge (simplified diamond loops)
    loops = []
    for r in range(n - 1):
        for c in range(n - 1):
            x = margin + (c + 0.5) * spacing
            y = margin + (r + 0.5) * spacing
            rad = spacing * 0.38
            # slight wobble via seed
            wob = ((seed + r * 7 + c * 13) % 5) - 2
            loops.append(
                f'<ellipse cx="{x + wob * 0.3:.1f}" cy="{y - wob * 0.2:.1f}" '
                f'rx="{rad:.1f}" ry="{rad * 0.92:.1f}" fill="none" '
                f'stroke="{P["kolam"]}" stroke-width="5" '
                f'stroke-linecap="round"/>'
            )
            loops.append(
                f'<ellipse cx="{x + wob * 0.3:.1f}" cy="{y - wob * 0.2:.1f}" '
                f'rx="{rad:.1f}" ry="{rad * 0.92:.1f}" fill="none" '
                f'stroke="{P["outline"]}" stroke-width="2.5"/>'
            )

    # outer diamond border
    cx = size / 2
    cy = size / 2
    outer = (
        f'<path d="M {cx:.1f} {margin - 12:.1f} L {size - margin + 12:.1f} {cy:.1f} '
        f'L {cx:.1f} {size - margin + 12:.1f} L {margin - 12:.1f} {cy:.1f} Z" '
        f'fill="none" stroke="{P["kolam"]}" stroke-width="6"/>'
        f'<path d="M {cx:.1f} {margin - 12:.1f} L {size - margin + 12:.1f} {cy:.1f} '
        f'L {cx:.1f} {size - margin + 12:.1f} L {margin - 12:.1f} {cy:.1f} Z" '
        f'fill="none" stroke="{P["outline"]}" stroke-width="2.5"/>'
    )
    body = f'<rect width="{size}" height="{size}" fill="{P["ochre"]}"/>\n' + outer + "\n".join(loops + dots)
    return svg_doc(int(size), int(size), body, None)


def all_assets() -> dict[str, str]:
    return {
        "props/kolam.svg": kolam(5),
        "props/kolam_7.svg": kolam(7, spacing=22.0, seed=411),
    }
