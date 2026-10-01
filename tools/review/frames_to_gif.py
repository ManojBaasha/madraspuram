#!/usr/bin/env python3
"""Build an animated GIF from Movie Maker frame PNGs (ffmpeg alternative)."""
from __future__ import annotations

import argparse
import re
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[2]


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("frames_dir", nargs="?", default=str(ROOT / "review" / "run"))
    ap.add_argument("-o", "--out", default=str(ROOT / "review" / "out.gif"))
    ap.add_argument("--fps", type=int, default=15)
    ap.add_argument("--scale", type=int, default=960)
    args = ap.parse_args()

    d = Path(args.frames_dir)
    frames = sorted(d.glob("frame*.png"), key=lambda p: int(re.findall(r"\d+", p.stem)[-1]))
    if not frames:
        frames = sorted(d.glob("*.png"))
    if not frames:
        raise SystemExit(f"No frames in {d}")

    imgs = []
    for f in frames:
        im = Image.open(f).convert("RGB")
        if args.scale and im.width > args.scale:
            h = int(im.height * (args.scale / im.width))
            im = im.resize((args.scale, h), Image.Resampling.LANCZOS)
        imgs.append(im)

    out = Path(args.out)
    out.parent.mkdir(parents=True, exist_ok=True)
    duration = int(1000 / max(args.fps, 1))
    imgs[0].save(out, save_all=True, append_images=imgs[1:], duration=duration, loop=0)
    print(f"wrote {out} ({len(imgs)} frames)")


if __name__ == "__main__":
    main()
