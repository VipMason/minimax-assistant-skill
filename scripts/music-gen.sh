#!/bin/bash
# music-gen.sh - MiniMax Music Generation (with model selection)
# Usage: ./music-gen.sh --model music-2.6 --prompt "style" --lyrics "lyrics" --out song.mp3
# API Key: reads from ~/.mmx/config.json

set -e

MODEL="music-2.6"
OUTPUT=""
PROMPT=""
LYRICS=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --model) MODEL="$2"; shift 2 ;;
        --prompt) PROMPT="$2"; shift 2 ;;
        --lyrics) LYRICS="$2"; shift 2 ;;
        --out) OUTPUT="$2"; shift 2 ;;
        *) echo "Unknown: $1" && exit 1 ;;
    esac
done

[ -z "$PROMPT" ] && echo "Usage: music-gen.sh --model music-2.6 --prompt 'style' --lyrics 'lyrics' --out song.mp3" && exit 1
[ -z "$OUTPUT" ] && OUTPUT="music_$(date +%s).mp3"

# Read API config
API_KEY=$(python3 -c "import json; print(json.load(open('/root/.mmx/config.json'))['api_key'])")
REGION=$(python3 -c "import json; print(json.load(open('/root/.mmx/config.json')).get('region','cn'))")

[ "$REGION" = "global" ] && API_URL="https://api.minimax.io/v1/music_generation" || API_URL="https://api.minimaxi.com/v1/music_generation"

echo "[music-gen] Model: $MODEL | Style: $PROMPT"

TMPFILE=$(mktemp)
trap "rm -f $TMPFILE" EXIT

# Call API
curl -s -X POST "$API_URL" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_KEY" \
    -d "{\"model\":\"$MODEL\",\"prompt\":\"$PROMPT\",\"lyrics\":\"$LYRICS\",\"output_format\":\"hex\"}" > "$TMPFILE"

# Check status
STATUS=$(python3 -c "import json; print(json.load(open('$TMPFILE')).get('base_resp',{}).get('status_code',-1))")
[ "$STATUS" != "0" ] && echo "[music-gen] Error: $(python3 -c "import json; print(json.load(open('$TMPFILE')).get('base_resp',{}).get('status_msg','error'))")" && exit 1

# Save audio
python3 << PYEOF
import json
with open('$TMPFILE') as f:
    data = json.load(f)
audio_hex = data.get('data', {}).get('audio', '')
extra = data.get('extra_info', {})
dur = extra.get('music_duration', 0)
with open('$OUTPUT', 'wb') as f:
    f.write(bytes.fromhex(audio_hex))
print(f'[music-gen] Done! {dur/1000:.1f}s -> $OUTPUT')
PYEOF
