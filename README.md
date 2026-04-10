# MiniMax Assistant Skill for OpenClaw

A comprehensive OpenClaw skill for MiniMax AI Platform, supporting text, images, video, music, speech, and lyrics generation.

## Installation

### For OpenClaw Users

```bash
# Install via clawhub
npx skills add minimax-assistant -g

# Or download the .skill file and place in your skills directory
```

### For Individual Use

```bash
# Install mmx CLI
npm install -g mmx-cli

# Authenticate
mmx auth login --api-key <YOUR_API_KEY>
```

Get your API key at: https://platform.minimaxi.com (CN) or https://platform.minimax.io (Global)

## Capabilities

| Feature | Command | Description |
|---------|---------|-------------|
| Text Chat | `mmx text chat --message "hi"` | Multi-turn conversation |
| Image Generation | `mmx image "description"` | Batch support with --n |
| Video Generation | `mmx video generate --prompt "desc"` | Async with --async |
| Music Generation | `mmx music generate --prompt "style" --lyrics "lyrics"` | CLI uses music-2.5 |
| Speech Synthesis | `mmx speech synthesize --text "text" --out audio.mp3"` | 30+ voices |
| Image Understanding | `mmx vision image.jpg` | Describe images |
| Web Search | `mmx search "query"` | MiniMax search |

## Scripts

### music-gen.sh

Music generation with model selection support (bypasses CLI limitation).

```bash
./music-gen.sh --model music-2.6 --prompt "Jazz" --lyrics "la la" --out song.mp3
```

### lyrics-to-song.sh

Complete pipeline: generate lyrics → create song.

```bash
./lyrics-to-song.sh \
  --prompt "Chinese classical style" \
  --title "烟雨江南" \
  --style "Guzheng, Pipa" \
  --out song.mp3
```

## API Reference

See [references/api-models.md](references/api-models.md) for detailed API documentation.

## Models

| Model | Use Case | Quota |
|-------|----------|-------|
| MiniMax-M* | Text Chat | Weekly/Daily |
| music-2.5 | Music Gen | Requires Max Plan |
| music-2.6 | Music Gen | 700/week |
| music-cover | Music Cover | 700/week |
| lyrics_generation | Lyrics Gen | 700/week |
| image-01 | Image Gen | 350/week |
| speech-hd | Speech | 28000/week |

## Privacy

- API keys use placeholder: `<YOUR_API_KEY>`
- Scripts read keys from `~/.mmx/config.json`
- No data exfiltration

## License

MIT
