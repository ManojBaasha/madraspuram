# Decisions

## Scope
- **2026-10-01:** Ship Approach A only — tea-hub “In for a Penny” remap (bus → tea → auto → milk → pour → end). Temple/cinema/office out of scope.
- **2026-10-01:** TGYH-pure UI; heat diegetic only; Tamil bubbles + slightly-wrong English robot subtitles.
- **2026-10-01:** Street cast is role-readable SVGs (not shirt recolors): tea master (pour), auto anna (yellow+keys), directions uncle (point+specs), kids (backpack), bench uncle (cane), flower auntie (sari). Robot parts chunkier with ear bolts / PUSH pad.

## Toolchain
- **Godot binary:** `/Applications/Godot.app/Contents/MacOS/Godot` (4.7.2.stable). `tools/verify.sh` uses `GODOT` env or this path.
- **ffmpeg:** Homebrew ffmpeg broken (missing `libass.9.dylib`); brew reinstall blocked. **Alternative:** Pillow builds GIFs from Movie Maker frames via `tools/review/frames_to_gif.py`.
- **Export templates:** Directory exists; contents checked in Phase 0 PROGRESS. Missing templates = hard stop at Phase 9 only.

## Design picks
- Working title: **Madraspuram**. Street: **George Street**.
- Verb named **push** in code (`pushable`); player-facing slapformer feel identical to TGYH slap.
- **Movement:** TGYH-style free 2D walk on the street plane (WASD / arrows: left-right AND up-down depth), plus hop. Not a pure side-scroller platformer.
- Parody brands: **பாவின் / Paavin** milk; no real star cutouts in this slice.
- **Language surface:** Game UI (title/pause/hints/end) in English. In-world speech = colloquial Tamil. **Street text** = Tamil-first signboards with smaller/imperfect English underneath (phones, Since…, STD ISD PCO, NO PARKING) — like real George Street walls. Robot subtitles stay slightly-wrong English.
