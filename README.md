# MiniMax Assistant Skill for OpenClaw

A comprehensive skill for OpenClaw AI assistants to access MiniMax AI Platform capabilities.

## What This Skill Does

This skill enables OpenClaw AI assistants to use MiniMax services:
- Text chat
- Image generation
- Music generation
- Video generation
- Speech synthesis
- Lyrics generation
- Web search

## Prerequisites

1. **OpenClaw AI Assistant** installed
2. **mmx CLI** installed: `npm install -g mmx-cli`
3. **MiniMax API Key**: https://platform.minimaxi.com (CN) or https://platform.minimax.io (Global)

## Installation

### For AI Agents (OpenClaw)

Place the skill folder in your OpenClaw skills directory:
```
your-openclaw-workspace/skills/minimax-assistant/
├── SKILL.md
├── scripts/
│   ├── music-gen.sh
│   └── lyrics-to-song.sh
└── references/
    └── api-models.md
```

### For Manual Use

```bash
# Install mmx CLI
npm install -g mmx-cli

# Authenticate
mmx auth login --api-key YOUR_API_KEY

# Test
mmx quota show
mmx text chat --message "Hello"
```

## Quick Reference

### Music Generation

```bash
# music-gen.sh - supports model selection
./scripts/music-gen.sh \
  --model music-2.6 \
  --prompt "Jazz, smooth" \
  --lyrics "[verse]\nLa la la" \
  --out song.mp3
```

### Lyrics to Song Pipeline

```bash
./scripts/lyrics-to-song.sh \
  --prompt "Chinese classical style" \
  --title "烟雨江南" \
  --style "Guzheng, Pipa" \
  --out song.mp3
```

### Available Models

| Model | Use Case | Quota |
|-------|----------|-------|
| music-2.6 | Music Gen | 700/week |
| music-cover | Music Cover | 700/week |
| lyrics_generation | Lyrics Gen | 700/week |
| image-01 | Image Gen | 350/week |
| speech-hd | Speech | 28000/week |

## API Reference

See `references/api-models.md` for detailed API documentation.

## License

MIT
