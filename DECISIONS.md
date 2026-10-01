# Decisions

## Scope
- **2026-10-01:** Ship Approach A only — tea-hub “In for a Penny” remap (bus → tea → auto → milk → pour → end). Temple/cinema/office out of scope.
- **2026-10-01:** TGYH-pure UI; heat diegetic only; Tamil bubbles + slightly-wrong English robot subtitles.

## Toolchain
- **Godot binary:** `/Applications/Godot.app/Contents/MacOS/Godot` (4.7.2.stable). `tools/verify.sh` uses `GODOT` env or this path.
- **ffmpeg:** Homebrew ffmpeg was broken (missing `libass.9.dylib`). Logged; will reinstall libass or use Pillow/imageio for GIFs if needed.
- **Export templates:** Directory exists; contents checked in Phase 0 PROGRESS. Missing templates = hard stop at Phase 9 only.

## Design picks
- Working title: **Madraspuram**. Street: **George Street**.
- Verb named **push** in code (`pushable`); player-facing slapformer feel identical to TGYH slap.
- Parody brands: **பாவின் / Paavin** milk; no real star cutouts in this slice.
- Subtitle style: faithful enough to progress, slightly flat/literal for outsider comedy.
