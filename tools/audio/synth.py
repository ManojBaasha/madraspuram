#!/usr/bin/env python3
"""Procedural SFX → audio/sfx/*.wav"""
from __future__ import annotations

import math
import struct
import wave
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parents[2]
OUT = ROOT / "audio" / "sfx"
SR = 44100


def write_wav(name: str, samples: np.ndarray) -> None:
    samples = np.clip(samples, -1, 1)
    data = (samples * 32767).astype(np.int16)
    path = OUT / name
    path.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(path), "w") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(SR)
        w.writeframes(data.tobytes())
    print("wrote", path.relative_to(ROOT))


def noise_burst(dur=0.08, cutoff=0.3):
    n = int(SR * dur)
    x = np.random.randn(n)
    # simple lowpass
    out = np.zeros_like(x)
    a = cutoff
    for i in range(1, n):
        out[i] = out[i - 1] + a * (x[i] - out[i - 1])
    env = np.linspace(1, 0, n) ** 2
    return out * env * 0.6


def square_beep(freq=440, dur=0.1, detune=0.0):
    n = int(SR * dur)
    t = np.arange(n) / SR
    sig = np.sign(np.sin(2 * math.pi * (freq + detune) * t))
    env = np.minimum(1, np.linspace(0, 8, n)) * np.linspace(1, 0, n)
    return sig * env * 0.25


def horn(freq=180, dur=0.35):
    n = int(SR * dur)
    t = np.arange(n) / SR
    sig = 0.5 * np.sign(np.sin(2 * math.pi * freq * t))
    sig += 0.35 * np.sign(np.sin(2 * math.pi * (freq * 1.01) * t))
    env = np.ones(n)
    env[: int(0.02 * SR)] = np.linspace(0, 1, int(0.02 * SR))
    env[-int(0.08 * SR) :] *= np.linspace(1, 0, int(0.08 * SR))
    return sig * env * 0.3


def crow():
    n = int(SR * 0.25)
    t = np.arange(n) / SR
    f = 900 + 400 * np.sin(2 * math.pi * 6 * t)
    # FM chirp
    phase = np.cumsum(f) / SR * 2 * math.pi
    sig = np.sin(phase + 2 * np.sin(phase * 0.3))
    env = np.linspace(0, 1, n // 5).tolist() + [1] * (n - 2 * (n // 5)) + np.linspace(1, 0, n // 5).tolist()
    env = np.array(env[:n])
    return sig * env * 0.35


def clink(freq=1200):
    n = int(SR * 0.15)
    t = np.arange(n) / SR
    sig = np.sin(2 * math.pi * freq * t) * np.exp(-12 * t)
    sig += 0.4 * np.sin(2 * math.pi * freq * 1.5 * t) * np.exp(-15 * t)
    return sig * 0.5


def jingle(seed=1):
    rng = np.random.default_rng(seed)
    notes = [523, 659, 784, 880]
    parts = []
    for i, f in enumerate(notes):
        f2 = f * (1 + rng.uniform(-0.01, 0.01))
        parts.append(square_beep(f2, 0.12))
        parts.append(np.zeros(int(0.03 * SR)))
    return np.concatenate(parts) * 0.8


def ambient():
    n = SR * 4
    t = np.arange(n) / SR
    sig = 0.02 * np.sin(2 * math.pi * 80 * t)
    sig += 0.01 * np.random.randn(n)
    return sig


def main():
    write_wav("push.wav", noise_burst())
    write_wav("beep.wav", square_beep(660, 0.08))
    write_wav("horn.wav", horn())
    write_wav("crow.wav", crow())
    write_wav("clink.wav", clink())
    write_wav("clink2.wav", clink(1400))
    write_wav("clink3.wav", clink(1600))
    write_wav("jingle1.wav", jingle(1))
    write_wav("jingle2.wav", jingle(2))
    write_wav("jingle3.wav", jingle(3))
    write_wav("ambient_street.wav", ambient())
    print("OK audio")


if __name__ == "__main__":
    main()
