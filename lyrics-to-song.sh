#!/bin/bash
# lyrics-to-song.sh - 歌词生成 → 歌曲生成完整流程
# 用法: ./lyrics-to-song.sh --prompt "主题风格" --title "歌曲名" --style "伴奏风格" --out song.mp3
# 示例: ./lyrics-to-song.sh --prompt "中国古典，婉约惆怅" --title "烟雨江南" --style "古筝琵琶" --out chinese_song.mp3

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

[ -z "$PROMPT" ] && echo "Usage: lyrics-to-song.sh --prompt '主题' --title '歌名' --style '伴奏风格' --out output.mp3" && exit 1
[ -z "$TITLE" ] && TITLE="AI Generated"
[ -z "$STYLE" ] && STYLE="pop, melodic"
[ -z "$OUTPUT" ] && OUTPUT="song_$(date +%s).mp3"

# 读取API配置
API_KEY=$(python3 -c "import json; print(json.load(open('/root/.mmx/config.json'))['api_key'])")
REGION=$(python3 -c "import json; print(json.load(open('/root/.mmx/config.json')).get('region','cn'))")

[ "$REGION" = "global" ] && API_URL="https://api.minimax.io" || API_URL="https://api.minimaxi.com"

LYRICS_API="$API_URL/v1/lyrics_generation"
MUSIC_API="$API_URL/v1/music_generation"

TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

echo "[lyrics-to-song] Step 1: 生成歌词..."
echo "[lyrics-to-song] Prompt: $PROMPT"

# 1. 生成歌词
curl -s -X POST "$LYRICS_API" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_KEY" \
    -d "{\"mode\":\"write_full_song\",\"prompt\":\"$PROMPT\",\"title\":\"$TITLE\"}" > "$TMPDIR/lyrics.json"

LYRICS_STATUS=$(python3 -c "import json; print(json.load(open('$TMPDIR/lyrics.json')).get('base_resp',{}).get('status_code',-1))")
[ "$LYRICS_STATUS" != "0" ] && echo "[lyrics-to-song] 歌词生成失败" && exit 1

GENERATED_LYRICS=$(python3 -c "import json; print(json.load(open('$TMPDIR/lyrics.json')).get('lyrics',''))")
GENERATED_TITLE=$(python3 -c "import json; print(json.load(open('$TMPDIR/lyrics.json')).get('song_title',''))")
STYLE_TAGS=$(python3 -c "import json; print(json.load(open('$TMPDIR/lyrics.json')).get('style_tags',''))")

echo "[lyrics-to-song] 歌词生成完成: $GENERATED_TITLE"
echo "[lyrics-to-song] 风格标签: $STYLE_TAGS"

# 2. 生成歌曲
echo "[lyrics-to-song] Step 2: 生成歌曲..."
curl -s -X POST "$MUSIC_API" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $API_KEY" \
    -d "{\"model\":\"music-2.6\",\"prompt\":\"$STYLE\",\"lyrics\":\"$GENERATED_LYRICS\",\"output_format\":\"hex\"}" > "$TMPDIR/music.json"

MUSIC_STATUS=$(python3 -c "import json; print(json.load(open('$TMPDIR/music.json')).get('base_resp',{}).get('status_code',-1))")
[ "$MUSIC_STATUS" != "0" ] && echo "[lyrics-to-song] 歌曲生成失败" && exit 1

# 3. 保存音频
python3 << PYEOF
import json, os
with open('$TMPDIR/music.json') as f:
    data = json.load(f)
audio_hex = data.get('data', {}).get('audio', '')
extra = data.get('extra_info', {})
dur = extra.get('music_duration', 0)
with open('$OUTPUT', 'wb') as f:
    f.write(bytes.fromhex(audio_hex))
print(f'[lyrics-to-song] 完成! {dur/1000:.1f}s -> $OUTPUT')
PYEOF

# 保存歌词到同名前缀 .txt
LYRICS_FILE="${OUTPUT%.mp3}.txt"
echo "$GENERATED_LYRICS" > "$LYRICS_FILE"
echo "[lyrics-to-song] 歌词已保存: $LYRICS_FILE"
