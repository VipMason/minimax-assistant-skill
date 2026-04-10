#!/bin/bash
# music-gen.sh - MiniMax Music Generation (with model selection)
# Usage: ./music-gen.sh --model music-2.6 --prompt "style" --lyrics "lyrics" --out /path/to/song.mp3
# API Key: reads from ~/.mmx/config.json
# Output: customizable via --out flag (default: ./music_<timestamp>.mp3)

set -e

MODEL="music-2.6"
OUTPUT=""
PROMPT=""
LYRICS=""

usage() {
    echo "Usage: $0 --model MODEL --prompt PROMPT [--lyrics LYRICS] --out OUTPUT"
    echo "  --model   Model to use (music-2.6, music-cover)"
    echo "  --prompt  Music style description"
    echo "  --lyrics  Song lyrics (optional for instrumental)"
    echo "  --out     Output file path (default: ./music_\$(date +%s).mp3)"
    exit 1
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --model) MODEL="$2"; shift 2 ;;
        --prompt) PROMPT="$2"; shift 2 ;;
        --lyrics) LYRICS="$2"; shift 2 ;;
        --out) OUTPUT="$2"; shift 2 ;;
        --help) usage ;;
        *) echo "Unknown: $1"; usage ;;
    esac
done

[ -z "$PROMPT" ] && echo "Error: --prompt is required" && usage
[ -z "$OUTPUT" ] && OUTPUT="music_$(date +%s).mp3"

# Read API config
CONFIG_FILE="${HOME}/.mmx/config.json"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: mmx config not found at $CONFIG_FILE"
    echo "Run 'mmx auth login' first"
    exit 1
fi

API_KEY=$(python3 -c "import json; print(json.load(open('$CONFIG_FILE'))['api_key'])" 2>/dev/null) || {
    echo "Error: Cannot read API key from $CONFIG_FILE"
    exit 1
}

REGION=$(python3 -c "import json; print(json.load(open('$CONFIG_FILE')).get('region','cn'))")

[ "$REGION" = "global" ] && API_URL="https://api.minimax.io/v1/music_generation" || API_URL="https://api.minimaxi.com/v1/music_generation"

echo "[music-gen] Model: $MODEL"
echo "[music-gen] Style: $PROMPT"
echo "[music-gen] Output: $OUTPUT"

TMPFILE=$(mktemp)
trap "rm -f $TMPFILE" EXIT

# Call API with timeout
echo "[music-gen] Calling API..."
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_URL" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_KEY" \
    -d "{\"model\":\"$MODEL\",\"prompt\":\"$PROMPT\",\"lyrics\":\"$LYRICS\",\"output_format\":\"hex\"}" \
    --max-time 300 \
    --retry 3 \
    --retry-delay 5 \
    2>&1) || {
    echo "Error: API request failed"
    echo "$RESPONSE"
    exit 1
}

HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
BODY=$(echo "$RESPONSE" | sed '$d')

# Check HTTP status
if [ "$HTTP_CODE" != "200" ]; then
    echo "Error: HTTP $HTTP_CODE"
    echo "$BODY"
    exit 1
fi

# Parse response
STATUS=$(echo "$BODY" | python3 -c "import sys,json; print(json.load(sys.stdin).get('base_resp',{}).get('status_code',-1))" 2>/dev/null) || {
    echo "Error: Invalid JSON response"
    exit 1
}

if [ "$STATUS" != "0" ]; then
    ERROR_MSG=$(echo "$BODY" | python3 -c "import sys,json; print(json.load(sys.load(sys.stdin)).get('base_resp',{}).get('status_msg','error'))" 2>/dev/null)
    echo "Error: $ERROR_MSG"
    echo "Hint: Check 'mmx quota show' for usage"
    exit 1
fi

# Save audio
AUDIO=$(echo "$BODY" | python3 -c "import sys,json; print(json.load(sys.stdin).get('data',{}).get('audio',''))" 2>/dev/null) || {
    echo "Error: Cannot extract audio from response"
    exit 1
}

python3 -c "
import os
with open('$OUTPUT', 'wb') as f:
    f.write(bytes.fromhex('$AUDIO'))
print(f'[music-gen] Done! -> $OUTPUT')
" || {
    echo "Error: Failed to write file"
    exit 1
}
