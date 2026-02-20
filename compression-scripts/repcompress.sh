#!/bin/bash

# Target: 9.5MB (77824 total kilobits)
TARGET_KBITS=77000
AUDIO_BITRATE=128

INPUT="$1"
DIR=$(dirname "$INPUT")
FILENAME=$(basename "${INPUT%.*}")
OUTPUT="$DIR/${FILENAME}_compressed.mp4"

cd "$DIR" || exit

# 1. Get Duration safely
DURATION_RAW=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$INPUT")
DURATION=$(echo "$DURATION_RAW" | awk '{print ($1 < 1) ? 1 : int($1)}')

# 2. Calculate Video Bitrate
VIDEO_BITRATE=$(( (TARGET_KBITS / DURATION) - AUDIO_BITRATE ))

echo "--- Optimizing for 10MB ---"
echo "Targeting 30 FPS at 720p for max clarity..."

# 3. Two-Pass with Downscaling and FPS reduction
# Pass 1
ffmpeg -y -i "$INPUT" -c:v libx265 -b:v "${VIDEO_BITRATE}k" -x265-params pass=1 -vf "scale=1280:-2,fps=30" -an -f null /dev/null && \

# Pass 2 (The actual encode)
ffmpeg -y -i "$INPUT" -c:v libx265 -b:v "${VIDEO_BITRATE}k" -x265-params pass=2 -vf "scale=1280:-2,fps=30" -c:a aac -b:a "${AUDIO_BITRATE}k" -tag:v hvc1 "$OUTPUT"

# Cleanup
rm ffmpeg2pass-0.log*
#echo "Done! Final file: $OUTPUT"
#read
