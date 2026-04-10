#!/bin/bash
# lyrics-to-song.sh - Lyrics Generation to Song Generation Pipeline
# Usage: ./lyrics-to-song.sh --prompt "theme" --title "song title" --style "style" --out song.mp3
# Example: ./lyrics-to-song.sh --prompt "Chinese classical, melancholic" --title "烟雨江南" --style "Guzheng, Pipa" --out chinese_song.mp3

set -e

PROMPT=""
TITLE=""
STYLE=""
OUTPUT=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --prompt) PROMPT="$2"; shift 2 ;;
        --title) TITLE="$2"; shift 2 ;;
        --style) STYLE="$2"; shift 2 ;;
        --out) OUTPUT="$2"; shift 2 ;;
        *) echo "Unknown: $1" && exit 1 ;;
    esac
done

[ -z "$PROMPT" ] && echo "Usage: lyrics-to-song.sh --prompt 'theme' --title 'title' --style 'style' --out output.mp3" && exit 1
[ -z "$TITLE" ] && TITLE="AI Generated"
[ -z "$STYLE" ] && STYLE="pop, melodic"
[ -z "$OUTPUT" ] && OUTPUT="song_$(date +%s).mp3"

# Read API config
API_KEY=$(python3 -c "import json; print(json.load(open('/root/.mmx/config.json'))['api_key'])")
REGION=$(python3 -c "import json; print(json.load(open('/root/.mmx/config.json')).get('region','cn'))")

[ "$REGION" = "global" ] && API_URL="https://api.minimax.io" || API_URL="https://api.minimaxi.com"

LYRICS_API="$API_URL/v1/lyrics_generation"
MUSIC_API="$API_URL/v1/music_generation"

TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

echo "[lyrics-to-song] Step 1: Generating lyrics..."
echo "[lyrics-to-song] Prompt: $PROMPT"

# 1. Generate lyrics
curl -s -X POST "$LYRICS_API" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_KEY" \
    -d "{\"mode\":\"write_full_song\",\"prompt\":\"$PROMPT\",\"title\":\"$TITLE\"}" > "$TMPDIR/lyrics.json"

LYRICS_STATUS=$(python3 -c "import json; print(json.load(open('$TMPDIR/lyrics.json')).get('base_resp',{}).get('status_code',-1))")
[ "$LYRICS_STATUS" != "0" ] && echo "[lyrics-to-song] Lyrics generation failed" && exit 1

GENERATED_LYRICS=$(python3 -c "import json; print(json.load(open('$TMPDIR/lyrics.json')).get('lyrics',''))")
GENERATED_TITLE=$(python3 -c "import json; print(json.load(open('$TMPDIR/lyrics.json')).get('song_title',''))")
STYLE_TAGS=$(python3 -c "import json; print(json.load(open('$TMPDIR/lyrics.json')).get('style_tags',''))")

echo "[lyrics-to-song] Lyrics generated: $GENERATED_TITLE"
echo "[lyrics-to-song] Style tags: $STYLE_TAGS"

# 2. Generate song
echo "[lyrics-to-song] Step 2: Generating song..."
curl -s -X POST "$MUSIC_API" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_KEY" \
    -d "{\"model\":\"music-2.6\",\"prompt\":\"$STYLE\",\"lyrics\":\"$GENERATED_LYRICS\",\"output_format\":\"hex\"}" > "$TMPDIR/music.json"

MUSIC_STATUS=$(python3 -c "import json; print(json.load(open('$TMPDIR/music.json')).get('base_resp',{}).get('status_code',-1))")
[ "$MUSIC_STATUS" != "0" ] && echo "[lyrics-to-song] Song generation failed" && exit 1

# 3. Save audio
python3 << PYEOF
import json, os
with open('$TMPDIR/music.json') as f:
    data = json.load(f)
audio_hex = data.get('data', {}).get('audio', '')
extra = data.get('extra_info', {})
dur = extra.get('music_duration', 0)
with open('$OUTPUT', 'wb') as f:
    f.write(bytes.fromhex(audio_hex))
print(f'[lyrics-to-song] Done! {dur/1000:.1f}s -> $OUTPUT')
PYEOF

# Save lyrics to .txt file
LYRICS_FILE="${OUTPUT%.mp3}.txt"
echo "$GENERATED_LYRICS" > "$LYRICS_FILE"
echo "[lyrics-to-song] Lyrics saved: $LYRICS_FILE"
