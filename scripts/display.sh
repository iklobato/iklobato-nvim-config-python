#!/usr/bin/env bash
#
# Applies the tuned color profile for the Samsung C49HG9x external display.
# Idempotent: safe to re-run. Values chosen for neutral, natural work color
# (counters the limited-range washout of the panel). Adjust and re-run to taste.
#
# Requires BetterDisplay: brew install --cask betterdisplay
#
set -euo pipefail

DISPLAY_NAME="C49HG9x"
CONTRAST=0.3       # -0.9..0.9  lift, un-flattens the limited-range look
GAMMA=0.25         # -0.8..0.8  midtone lift (hardware brightness maxed)
TEMPERATURE=-0.08  # -0.5..0.5  slightly cooler white, kills the yellow cast

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
