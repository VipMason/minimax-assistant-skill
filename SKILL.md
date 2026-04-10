---
name: minimax-assistant
description: >
  MiniMax AI Platform assistant for text, images, video, music, speech, and search.
  Use when user wants to (1) install/setup mmx CLI (from https://github.com/MiniMax-AI/cli),
  (2) generate images, music, or speech, (3) use AI chat or search,
  (4) create songs with AI-generated lyrics, or (5) check/manage MiniMax quota.
  Triggers on: "MiniMax", "mmx", "生成音乐", "生成图片", "AI生成", "音乐生成", "歌词生成".
---

# MiniMax Assistant

## Installation Flow

**IMPORTANT**: Users must install mmx CLI FIRST before using this skill.

### Step 1: Install mmx CLI

```bash
npm install -g mmx-cli
```

Repository: https://github.com/MiniMax-AI/cli

### Step 2: Authenticate

```bash
mmx auth login --api-key <YOUR_API_KEY>
```

Get API key: https://platform.minimaxi.com (CN) or https://platform.minimax.io (Global)

### Step 3: Configure

```bash
mmx config show          # View current config
mmx quota show           # View quota
mmx auth status          # Check auth status
```

## All Capabilities

| Feature | Command | Description |
|---|---|---|
| Text Chat | `mmx text chat --message "hi"` | Multi-turn conversation |
| Image Generation | `mmx image "description"` | Batch with --n, --aspect-ratio |
| Video Generation | `mmx video generate --prompt "description"` | Async with --async |
| Music Generation | `mmx music generate --prompt "style" --lyrics "lyrics"` | CLI uses music-2.5 only |
| Speech Synthesis | `mmx speech synthesize --text "text" --out audio.mp3` | 30+ voices |
| Image Understanding | `mmx vision image.jpg` | Describe images |
| Web Search | `mmx search "query"` | MiniMax search |

## Advanced: Direct API (When CLI Cannot Choose Model)

mmx CLI `music generate` hardcodes music-2.5. For music-2.6 or music-cover, use direct API:

```bash
# Music generation (supports music-2.6, music-cover)
curl -X POST "https://api.minimaxi.com/v1/music_generation" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <API_KEY>" \
  -d '{"model":"music-2.6","prompt":"style","lyrics":"lyrics","output_format":"hex"}'

# Lyrics generation
curl -X POST "https://api.minimaxi.com/v1/lyrics_generation" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <API_KEY>" \
  -d '{"mode":"write_full_song","prompt":"theme or style","title":"song title"}'
```

API Key location: `~/.mmx/config.json` -> `api_key` field

## Workflow: Lyrics to Song (Full Pipeline)

```bash
# 1. Generate lyrics
LYRICS=$(curl -s -X POST "https://api.minimaxi.com/v1/lyrics_generation" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <API_KEY>" \
  -d '{"mode":"write_full_song","prompt":"Chinese classical, melancholic","title":"烟雨江南"}' \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['lyrics'])")

# 2. Generate song with lyrics
curl -s -X POST "https://api.minimaxi.com/v1/music_generation" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <API_KEY>" \
  -d "{\"model\":\"music-2.6\",\"prompt\":\"Chinese classical instruments, Guzheng, Pipa\",\"lyrics\":\"$LYRICS\",\"output_format\":\"hex\"}" \
  > song.json

# 3. Save audio
python3 -c "
import json
d=json.load(open('song.json'))
with open('song.mp3','wb') as f:
    f.write(bytes.fromhex(d['data']['audio']))
print('Done!')
"
```

## Scripts

- `scripts/music-gen.sh` - Music generation wrapper, supports model selection
- `scripts/lyrics-to-song.sh` - Complete lyrics to song pipeline

Usage:
```bash
./scripts/music-gen.sh --model music-2.6 --prompt "style" --lyrics "lyrics" --out song.mp3
./scripts/lyrics-to-song.sh --prompt "theme" --title "song title" --style "instrument style" --out output.mp3
```

## Models Reference

| Model | Use Case | Quota |
|---|---|---|
| MiniMax-M* | Text Chat | Weekly/Daily |
| music-2.5 | Music Gen | Requires Max Plan |
| music-2.6 | Music Gen | 700/week |
| music-cover | Music Cover | 700/week |
| lyrics_generation | Lyrics Gen | 700/week |
| image-01 | Image Gen | 350/week |
| speech-hd | Speech | 28000/week |

## Region Configuration

```bash
mmx config set --key region --value cn    # CN region
mmx config set --key region --value global # Global region
```

API endpoints:
- CN: `https://api.minimaxi.com`
- Global: `https://api.minimax.io`

## API Documentation

See `references/api-models.md` for detailed API reference.
