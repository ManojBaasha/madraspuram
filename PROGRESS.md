# Progress

## Status: Phases 0–9 complete (capability demo shipped)

### Verification evidence

**Toolchain:** Godot 4.7.2 · Python 3.11.13 · numpy · xmllint · Pillow GIF fallback (ffmpeg/libass broken)

**Tests:**
```
9 passed, 0 failed, 9 total
```

**Reactions:** 22 pushables, all reacted within 100ms (`review/reactions.log`)

**Quest bot:**
```
QUEST BOT OK ["auto_moved", "has_milk", "tea_done"]
```

**Web export:** `build/web` **39MB**; HTTP 200 for index.html / .wasm / .pck

**Desktop export:** `build/desktop/Madraspuram.app` (after enabling ETC2 ASTC)

**Art:** 24 SVGs xmllint-clean; contact sheet generated

**Tamil checkpoint:** `review/dialogue_review.md` ready for Manoj

### Checkpoints for Manoj
1. Art contact sheet — `review/contact_sheet.png` (regenerate via `.venv/bin/python tools/review/contact_sheet.py`)
2. Graybox/quest GIF — `review/phase4_quest.gif`
3. Tamil — `review/dialogue_review.md`
4. Final — `review/final/highlight.gif` + web/desktop builds

### Known issues
- ffmpeg still broken → no MP4 (see `review/final/MP4_NOTE.txt`); GIF present
- Highlight reel short (bot-length), not full 60s hand-authored trailer
- Some NPC art reused placeholders

### How to run
```
/Applications/Godot.app/Contents/MacOS/Godot --path .
# or open build/desktop/Madraspuram.app
# web: cd build/web && python3 -m http.server 8080
```
