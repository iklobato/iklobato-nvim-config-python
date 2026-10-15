#!/usr/bin/env bash
# Applies the tuned color profile to the Samsung C49HG9x (needs BetterDisplay). Idempotent.
set -euo pipefail

DISPLAY_NAME="C49HG9x"
CONTRAST=0.3      # range -0.9..0.9
GAMMA=0.25        # range -0.8..0.8
TEMPERATURE=-0.08 # range -0.5..0.5

if ! command -v betterdisplaycli >/dev/null 2>&1; then
  echo "betterdisplaycli not found. Install: brew install --cask betterdisplay" >&2
  exit 1
fi

if ! betterdisplaycli get --name="$DISPLAY_NAME" --identifiers >/dev/null 2>&1; then
  echo "Display '$DISPLAY_NAME' not connected; nothing to do."
  exit 0
fi

betterdisplaycli set --name="$DISPLAY_NAME" --contrast="$CONTRAST"
betterdisplaycli set --name="$DISPLAY_NAME" --gamma="$GAMMA"
betterdisplaycli set --name="$DISPLAY_NAME" --temperature="$TEMPERATURE"
echo "applied color profile to $DISPLAY_NAME (contrast=$CONTRAST gamma=$GAMMA temp=$TEMPERATURE)"
