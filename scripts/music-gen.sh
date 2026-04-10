#!/bin/bash
# music-gen.sh - MiniMax Music Generation (with model selection)
# Usage: ./music-gen.sh --model music-2.6 --prompt "style" --lyrics "lyrics" --out /path/to/song.mp3
#         ./music-gen.sh --stream --prompt "style" --out /path/to/song.mp3  # streaming mode
# API Key: reads from ~/.mmx/config.json

set -e

MODEL="music-2.6"
OUTPUT=""
PROMPT=""
LYRICS=""
STREAM=false

usage() {
    echo "Usage: $0 [--stream] --model MODEL --prompt PROMPT [--lyrics LYRICS] --out OUTPUT"
    echo "  --stream   Enable streaming mode (gets audio in chunks as generation progresses)"
    echo "  --model    Model to use (music-2.6, music-cover)"
    echo "  --prompt   Music style description"
    echo "  --lyrics   Song lyrics (optional)"
    echo "  --out      Output file path (default: ./music_\$(date +%s).mp3)"
    exit 1
}

while [[ $# -gt 0 ]]; do
    case $1 in
        --stream) STREAM=true; shift ;;
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
    echo "Error: Cannot read API key"
    exit 1
}

REGION=$(python3 -c "import json; print(json.load(open('$CONFIG_FILE')).get('region','cn'))")
[ "$REGION" = "global" ] && API_URL="https://api.minimax.io/v1/music_generation" || API_URL="https://api.minimaxi.com/v1/music_generation"

echo "[music-gen] Model: $MODEL"
echo "[music-gen] Style: $PROMPT"
echo "[music-gen] Output: $OUTPUT"

if [ "$STREAM" = true ]; then
    echo "[music-gen] Mode: STREAMING"
    echo "[music-gen] This may take a while... please wait"
    
    # Streaming mode - SSE response
    TMPFILE=$(mktemp)
    
    # Make streaming API call and capture
    curl -s -N -X POST "$API_URL" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $API_KEY" \
        -d "{\"model\":\"$MODEL\",\"prompt\":\"$PROMPT\",\"lyrics\":\"$LYRICS\",\"output_format\":\"hex\",\"stream\":true}" \
        --max-time 600 > "$TMPFILE" 2>&1 || {
        echo "Error: API request failed"
        cat "$TMPFILE"
        rm "$TMPFILE"
        exit 1
    }
    
    # Parse SSE response - extract all data lines and combine hex
    grep "^data:" "$TMPFILE" 2>/dev/null | sed 's/^data: //' | while read -r line; do
        echo "$line"
    done > "${TMPFILE}.lines"
    
    # Check for error in response
    if grep -q '"status_code"' "${TMPFILE}.lines" 2>/dev/null; then
        ERROR=$(cat "${TMPFILE}.lines" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('base_resp',{}).get('status_msg','error'))" 2>/dev/null)
        if [ -n "$ERROR" ]; then
            echo "Error: $ERROR"
            rm -f "$TMPFILE" "${TMPFILE}.lines"
            exit 1
        fi
    fi
    
    # Extract audio hex from last data event (contains the final audio)
    AUDIO_HEX=$(tail -n 1 "${TMPFILE}.lines" 2>/dev/null | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('data',{}).get('audio',''))" 2>/dev/null) || {
        echo "Error: Could not parse streaming response"
        rm -f "$TMPFILE" "${TMPFILE}.lines"
        exit 1
    }
    
    if [ -z "$AUDIO_HEX" ]; then
        echo "Error: No audio data in response"
        rm -f "$TMPFILE" "${TMPFILE}.lines"
        exit 1
    fi
    
    # Save audio
    python3 -c "
with open('$OUTPUT', 'wb') as f:
    f.write(bytes.fromhex('$AUDIO_HEX'))
print(f'[music-gen] Done! -> $OUTPUT')
"
    
    rm -f "$TMPFILE" "${TMPFILE}.lines"
    
else
    # Non-streaming mode
    echo "[music-gen] Calling API (non-streaming)..."
    
    RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_URL" \
        -H "Content-Type: application/json" \
        -H "Authorization: Bearer $API_KEY" \
        -d "{\"model\":\"$MODEL\",\"prompt\":\"$PROMPT\",\"lyrics\":\"$LYRICS\",\"output_format\":\"hex\"}" \
        --max-time 300 \
        --retry 3 \
        --retry-delay 5 \
        2>&1) || {
        echo "Error: API request failed"
        exit 1
    }
    
    HTTP_CODE=$(echo "$RESPONSE" | tail -n1)
    BODY=$(echo "$RESPONSE" | sed '$d')
    
    if [ "$HTTP_CODE" != "200" ]; then
        echo "Error: HTTP $HTTP_CODE"
        echo "$BODY"
        exit 1
    fi
    
    STATUS=$(echo "$BODY" | python3 -c "import sys,json; print(json.load(sys.stdin).get('base_resp',{}).get('status_code',-1))" 2>/dev/null) || {
        echo "Error: Invalid JSON response"
        exit 1
    }
    
    if [ "$STATUS" != "0" ]; then
        ERROR_MSG=$(echo "$BODY" | python3 -c "import sys,json; print(json.load(sys.stdin).get('base_resp',{}).get('status_msg','error'))")
        echo "Error: $ERROR_MSG"
        echo "Hint: Check 'mmx quota show'"
        exit 1
    fi
    
    AUDIO=$(echo "$BODY" | python3 -c "import sys,json; print(json.load(sys.stdin).get('data',{}).get('audio',''))")
    
    python3 -c "
with open('$OUTPUT','wb') as f:
    f.write(bytes.fromhex('$AUDIO'))
print(f'[music-gen] Done! -> $OUTPUT')
"
fi
