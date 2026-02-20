#!/bin/bash

# --- CONFIG ---
WATCH_DIR="/home/kolya/Videos/" # Ensure this folder exists!
OUTPUT_DIR="/home/kolya/Videos/"
TARGET_KBITS=77000               # ~9.5MB
AUDIO_BITRATE=128

# Ensure we are in the right folder
cd "$WATCH_DIR" || exit

# 1. Find the newest replay
INPUT=$(ls -t "$WATCH_DIR"/*.mp4 | grep -v "_compressed.mp4" | head -n 1)

if [ -z "$INPUT" ]; then
    notify-send "Error" "No recent replay found in $WATCH_DIR"
    exit 1
fi

OUTPUT="${INPUT%.*}_compressed.mp4"

# 2. Get Duration and Calculate Bitrate (Robust version)
DURATION_FLOAT=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$INPUT")
DURATION=${DURATION_FLOAT%.*} # Convert to whole number

# If duration is 0 (very short clip), set to 1 to avoid division by zero
if [ -z "$DURATION" ] || [ "$DURATION" -eq 0 ]; then DURATION=1; fi

VIDEO_BITRATE=$(( (TARGET_KBITS / DURATION) - AUDIO_BITRATE ))

# 3. Final Check: If bitrate is negative or crazy, set a floor
if [ "$VIDEO_BITRATE" -lt 150 ]; then VIDEO_BITRATE=150; fi

# 4. Compression (Two-Pass libx265)
# Using nice -n 15 for zero game lag
nice -n 15 ffmpeg -y -i "$INPUT" -c:v libx265 -b:v "${VIDEO_BITRATE}k" -x265-params pass=1 -vf "scale=1280:-2,fps=30" -an -f null /dev/null && \
nice -n 15 ffmpeg -y -i "$INPUT" -c:v libx265 -b:v "${VIDEO_BITRATE}k" -x265-params pass=2 -vf "scale=1280:-2,fps=30" -c:a aac -b:a "${AUDIO_BITRATE}k" -tag:v hvc1 "$OUTPUT"

# 5. Copy to clipboard
wl-copy --type text/uri-list "file://$OUTPUT"

# 6. Cleanup & Notify
rm ffmpeg2pass-0.log*
notify-send -i "video-x-generic""Compressed & Copied to Clipboard!"

echo "stop"
read
