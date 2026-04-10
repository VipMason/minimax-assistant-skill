# MiniMax API Reference

## API Endpoints

| Service | CN Endpoint | Global Endpoint |
|---------|-------------|-----------------|
| Text | `https://api.minimaxi.com/v1/text/chatcompletion_v2` | `https://api.minimax.io/v1/text/chatcompletion_v2` |
| Music Gen | `https://api.minimaxi.com/v1/music_generation` | `https://api.minimax.io/v1/music_generation` |
| Lyrics Gen | `https://api.minimaxi.com/v1/lyrics_generation` | `https://api.minimax.io/v1/lyrics_generation` |
| Image Gen | `https://api.minimaxi.com/v1/image_generation` | `https://api.minimax.io/v1/image_generation` |
| Speech | `https://api.minimaxi.com/v1/t2a_v2` | `https://api.minimax.io/v1/t2a_v2` |
| Video Gen | `https://api.minimaxi.com/v1/video_generation` | `https://api.minimax.io/v1/video_generation` |

## Authentication

All requests require Header:
```
Authorization: Bearer <API_KEY>
Content-Type: application/json
```

API Key location: `~/.mmx/config.json` -> `api_key`

## Music Generation API

**Endpoint**: `POST /v1/music_generation`

**Request Body**:
```json
{
    "model": "music-2.6",          // music-2.5, music-2.6, music-cover
    "prompt": "Style description", // 1-2000 chars
    "lyrics": "Lyrics content",    // Structured lyrics with [verse], [chorus] tags
    "output_format": "hex",        // or "url" (expires in 24h)
    "audio_setting": {
        "sample_rate": 44100,
        "bitrate": 256000,
        "format": "mp3"
    }
}
```

**Response**:
```json
{
    "data": {
        "audio": "<hex-encoded audio>",
        "status": 2               // 1=in progress, 2=completed
    },
    "extra_info": {
        "music_duration": 90017,  // milliseconds
        "music_sample_rate": 44100,
        "bitrate": 256000,
        "music_size": 3666641
    },
    "base_resp": {
        "status_code": 0,
        "status_msg": "success"
    }
}
```

## Lyrics Generation API

**Endpoint**: `POST /v1/lyrics_generation`

**Request Body**:
```json
{
    "mode": "write_full_song",     // write_full_song or edit
    "prompt": "Theme/style description", // 0-2000 chars
    "title": "Song title",        // optional
    "lyrics": "<existing lyrics>"  // only for edit mode
}
```

**Supported lyrics structure tags**:
- `[Intro]`, `[Verse]`, `[Pre-Chorus]`, `[Chorus]`, `[Hook]`, `[Drop]`
- `[Bridge]`, `[Solo]`, `[Build-up]`, `[Instrumental]`
- `[Breakdown]`, `[Break]`, `[Interlude]`, `[Outro]`

**Response**:
```json
{
    "song_title": "Song Title",
    "style_tags": "Pop, Summer, Romantic",
    "lyrics": "[Verse]\nLyrics content...",
    "base_resp": {"status_code": 0, "status_msg": "success"}
}
```

## Model Comparison

| Model | Description | Requirement |
|-------|-------------|-------------|
| music-2.5 | Basic music generation | Requires Max Plan |
| music-2.6 | Enhanced music generation | Standard quota |
| music-cover | Music style transfer/cover | Standard quota |

## Common Error Codes

| Code | Description |
|------|-------------|
| 0 | Success |
| 1004 | Auth failed, check API Key |
| 1008 | Insufficient quota |
| 2013 | Invalid parameters |
| 2049 | Invalid API Key |
| 2061 | Model not supported (Plan limit) |

## Quota Reset

- Most quotas: **Weekly reset (Monday UTC 00:00)**
- MiniMax-M*: Daily reset (see quota show for time)
