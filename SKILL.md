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

| 能力 | 命令 | 说明 |
|---|---|---|
| 文字聊天 | `mmx text chat --message "hi"` | 多轮对话 |
| 图片生成 | `mmx image "描述"` | 支持 --n 批量, --aspect-ratio |
| 视频生成 | `mmx video generate --prompt "描述"` | 支持 --async 异步 |
| 音乐生成 | `mmx music generate --prompt "风格" --lyrics "歌词"` | CLI 只支持 music-2.5 |
| 语音合成 | `mmx speech synthesize --text "文字" --out audio.mp3` | 30+音色 |
| 图像理解 | `mmx vision image.jpg` | 图片描述 |
| 网络搜索 | `mmx search "查询内容"` | MiniMax 搜索 |

## Advanced: Direct API (When CLI Cannot Choose Model)

mmx CLI `music generate` hardcodes music-2.5. For music-2.6 or music-cover, use direct API:

```bash
# 音乐生成 (supports music-2.6, music-cover)
curl -X POST "https://api.minimaxi.com/v1/music_generation" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <API_KEY>" \
  -d '{"model":"music-2.6","prompt":"风格","lyrics":"歌词","output_format":"hex"}'

# 歌词生成
curl -X POST "https://api.minimaxi.com/v1/lyrics_generation" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <API_KEY>" \
  -d '{"mode":"write_full_song","prompt":"主题风格","title":"歌曲名"}'
```

API Key location: `~/.mmx/config.json` -> `api_key` field

## Workflow: Lyrics to Song (Full Pipeline)

```bash
# 1. Generate lyrics
LYRICS=$(curl -s -X POST "https://api.minimaxi.com/v1/lyrics_generation" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <API_KEY>" \
  -d '{"mode":"write_full_song","prompt":"中国风，婉约惆怅","title":"烟雨江南"}' \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['lyrics'])")

# 2. Generate song with lyrics
curl -s -X POST "https://api.minimaxi.com/v1/music_generation" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <API_KEY>" \
  -d "{\"model\":\"music-2.6\",\"prompt\":\"中国古典乐器，古筝琵琶\",\"lyrics\":\"$LYRICS\",\"output_format\":\"hex\"}" \
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
./scripts/music-gen.sh --model music-2.6 --prompt "风格" --lyrics "歌词" --out song.mp3
./scripts/lyrics-to-song.sh --prompt "主题" --title "歌名" --style "伴奏风格" --out output.mp3
```

## Models Reference

| 模型 | 用途 | 额度周期 |
|---|---|---|
| MiniMax-M* | 文字聊天 | 每周/每日 |
| music-2.5 | 音乐生成 | 需Max Plan |
| music-2.6 | 音乐生成 | 每周700 |
| music-cover | 音乐覆盖 | 每周700 |
| lyrics_generation | 歌词生成 | 每周700 |
| image-01 | 图片生成 | 每周350 |
| speech-hd | 高清语音 | 每周28000 |

## Region Configuration

```bash
mmx config set --key region --value cn    # 中国区
mmx config set --key region --value global # 全球区
```

API endpoints:
- CN: `https://api.minimaxi.com`
- Global: `https://api.minimax.io`

## API Documentation

See `references/api-models.md` for detailed API reference.
