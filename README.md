# MiniMax Assistant Skill for OpenClaw

Enables OpenClaw AI assistants to access MiniMax AI Platform.

## Quick Start

### Step 1: Install mmx CLI

First, install the MiniMax CLI from the official repository:

```bash
npm install -g mmx-cli
```

Repository: https://github.com/MiniMax-AI/cli

### Step 2: Authenticate

```bash
mmx auth login --api-key YOUR_API_KEY
```

Get your API key at: https://platform.minimaxi.com (CN) or https://platform.minimax.io (Global)

### Step 3: Install This Skill (for OpenClaw agents)

Place the skill folder in your OpenClaw skills directory:

```
your-openclaw-workspace/skills/minimax-assistant/
├── SKILL.md
├── scripts/
│   ├── music-gen.sh          # Music generation (model selectable)
│   └── lyrics-to-song.sh    # Lyrics → Song pipeline
└── references/
    └── api-models.md         # API documentation
```

## Capabilities

| Feature | Command | Description |
|---------|---------|-------------|
| Text Chat | `mmx text chat --message "hi"` | Multi-turn conversation |
| Image Generation | `mmx image "description"` | Batch with --n |
| Video Generation | `mmx video generate --prompt "desc"` | Async with --async |
| Music Generation | `mmx music generate --prompt "style" --lyrics "lyrics"` | CLI uses music-2.5 by default |
| Speech Synthesis | `mmx speech synthesize --text "text" --out audio.mp3"` | 30+ voices |
| Image Understanding | `mmx vision image.jpg` | Describe images |
| Web Search | `mmx search "query"` | MiniMax search |

## Scripts

### music-gen.sh

Music generation with model selection support (bypasses CLI limitation).

```bash
./scripts/music-gen.sh \
  --model music-2.6 \
  --prompt "Jazz, smooth, relaxing" \
  --lyrics "[verse]\nLa la la..." \
  --out song.mp3
```

### lyrics-to-song.sh

Complete lyrics → song generation pipeline.

```bash
./scripts/lyrics-to-song.sh \
  --prompt "Chinese classical, melancholic" \
  --title "烟雨江南" \
  --style "Guzheng, Pipa" \
  --out song.mp3
```

## Available Models

| Model | Use Case | Notes |
|-------|----------|-------|
| MiniMax-M* | Text Chat | Check `mmx quota show` |
| music-2.5 | Music Gen | Requires Max Plan |
| music-2.6 | Music Gen | Quota-based |
| music-cover | Music Cover | Quota-based |
| lyrics_generation | Lyrics Gen | Quota-based |
| image-01 | Image Gen | Quota-based |
| speech-hd | Speech | Quota-based |

Run `mmx quota show` to check your specific quota limits.

## API Reference

See `references/api-models.md` for detailed API documentation.

## License

MIT
