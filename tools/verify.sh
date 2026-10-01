#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GODOT="${GODOT:-/Applications/Godot.app/Contents/MacOS/Godot}"
cd "$ROOT"

cmd="${1:-help}"

boot() {
  mkdir -p review
  "$GODOT" --headless --path . --import 2>&1 | tee review/import.log || true
  "$GODOT" --headless --path . --quit-after 120 2>&1 | tee review/boot.log
  if grep -E "ERROR|SCRIPT ERROR|Parse Error" review/boot.log; then
    echo "boot dirty"
    exit 1
  fi
  echo "boot clean"
}

tests() {
  "$GODOT" --headless --path . -s res://tests/run_tests.gd
}

art() {
  python3 tools/art/build.py
}

audio() {
  python3 tools/audio/synth.py
}

contact() {
  python3 tools/review/contact_sheet.py
}

gif() {
  python3 tools/review/frames_to_gif.py "$@"
}

case "$cmd" in
  boot) boot ;;
  tests) tests ;;
  art) art ;;
  audio) audio ;;
  contact) contact ;;
  gif) gif "${@:2}" ;;
  help|*)
    echo "Usage: $0 {boot|tests|art|audio|contact|gif}"
    ;;
esac
