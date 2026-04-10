#!/bin/bash
# lyrics-to-song.sh - Lyrics Generation to Song Generation Pipeline
# Usage: ./lyrics-to-song.sh --prompt "theme" --title "song title" --style "style" --out /path/to/song.mp3
# API Key: reads from ~/.mmx/config.json
# Output: customizable via --out flag (default: ./song_<timestamp>.mp3)

set -e

PROMPT=""
TITLE=""
STYLE=""
OUTPUT=""

usage() {
    echo "Usage: $0 --prompt PROMPT [--title TITLE] [--style STYLE] --out OUTPUT"
    echo "  --prompt  Theme/style description for lyrics"
    echo "  --title   Song title (optional, default: AI Generated)"
    echo "  --style   Music style/instruments (optional, default: pop, melodic)"
    echo "  --out     Output file path (default: ./song_\$(date +%s).mp3)"
    exit 1
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --prompt) PROMPT="$2"; shift 2 ;;
        --title) TITLE="$2"; shift 2 ;;
        --style) STYLE="$2"; shift 2 ;;
        --out) OUTPUT="$2"; shift 2 ;;
        --help) usage ;;
        *) echo "Unknown: $1"; usage ;;
    esac
done

[ -z "$PROMPT" ] && echo "Error: --prompt is required" && usage
[ -z "$TITLE" ] && TITLE="AI Generated"
[ -z "$STYLE" ] && STYLE="pop, melodic"
[ -z "$OUTPUT" ] && OUTPUT="song_$(date +%s).mp3"

# Read API config
CONFIG_FILE="${HOME}/.mmx/config.json"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: mmx config not found at $CONFIG_FILE"
    echo "Run 'mmx auth login' first"
    exit 1
fi

API_KEY=$(python3 -c "import json; print(json.load(open('$CONFIG_FILE'))['api_key'])" 2>/dev/null) || {
    echo "Error: Cannot read API key"
    exit 1
}

REGION=$(python3 -c "import json; print(json.load(open('$CONFIG_FILE')).get('region','cn'))")

[ "$REGION" = "global" ] && API_URL="https://api.minimax.io" || API_URL="https://api.minimaxi.com"

LYRICS_API="$API_URL/v1/lyrics_generation"
MUSIC_API="$API_URL/v1/music_generation"

TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

echo "[lyrics-to-song] Step 1: Generating lyrics..."
echo "[lyrics-to-song] Prompt: $PROMPT"

# 1. Generate lyrics with retry
LYRICS_RESPONSE=$(curl -s -X POST "$LYRICS_API" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_KEY" \
    -d "{\"mode\":\"write_full_song\",\"prompt\":\"$PROMPT\",\"title\":\"$TITLE\"}" \
    --max-time 60 \
    --retry 2 \
    2>&1) || {
    echo "Error: Lyrics API request failed"
    exit 1
}

LYRICS_STATUS=$(echo "$LYRICS_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin).get('base_resp',{}).get('status_code',-1))" 2>/dev/null) || {
    echo "Error: Invalid lyrics response"
    exit 1
}

if [ "$LYRICS_STATUS" != "0" ]; then
    echo "Error: Lyrics generation failed (code: $LYRICS_STATUS)"
    exit 1
fi

GENERATED_LYRICS=$(echo "$LYRICS_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin).get('lyrics',''))" 2>/dev/null)
GENERATED_TITLE=$(echo "$LYRICS_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin).get('song_title',''))" 2>/dev/null)
STYLE_TAGS=$(echo "$LYRICS_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin).get('style_tags',''))" 2>/dev/null)

echo "[lyrics-to-song] Title: $GENERATED_TITLE"
echo "[lyrics-to-song] Style: $STYLE_TAGS"

# Save intermediate lyrics
LYRICS_FILE="${OUTPUT%.mp3}.txt"
echo "$GENERATED_LYRICS" > "$LYRICS_FILE"
echo "[lyrics-to-song] Lyrics saved: $LYRICS_FILE"

# 2. Generate song with retry
echo "[lyrics-to-song] Step 2: Generating song..."
echo "[lyrics-to-song] Style prompt: $STYLE"

MUSIC_RESPONSE=$(curl -s -X POST "$MUSIC_API" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_KEY" \
    -d "{\"model\":\"music-2.6\",\"prompt\":\"$STYLE\",\"lyrics\":\"$GENERATED_LYRICS\",\"output_format\":\"hex\"}" \
    --max-time 300 \
    --retry 2 \
    2>&1) || {
    echo "Error: Music API request failed"
    exit 1
}

MUSIC_STATUS=$(echo "$MUSIC_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin).get('base_resp',{}).get('status_code',-1))" 2>/dev/null) || {
    echo "Error: Invalid music response"
    exit 1
}

if [ "$MUSIC_STATUS" != "0" ]; then
    echo "Error: Music generation failed (code: $MUSIC_STATUS)"
    exit 1
fi

# 3. Save audio
AUDIO=$(echo "$MUSIC_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin).get('data',{}).get('audio',''))" 2>/dev/null) || {
    echo "Error: Cannot extract audio"
    exit 1
}

python3 -c "
with open('$OUTPUT', 'wb') as f:
    f.write(bytes.fromhex('$AUDIO'))
print(f'[lyrics-to-song] Done! -> $OUTPUT')
" || {
    echo "Error: Failed to write file"
    exit 1
}
