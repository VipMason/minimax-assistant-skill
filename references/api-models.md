# MiniMax API 参考

## API 端点

| 服务 | CN 端点 | Global 端点 |
|---|---|---|
| 文字 | `https://api.minimaxi.com/v1/text/chatcompletion_v2` | `https://api.minimax.io/v1/text/chatcompletion_v2` |
| 音乐生成 | `https://api.minimaxi.com/v1/music_generation` | `https://api.minimax.io/v1/music_generation` |
| 歌词生成 | `https://api.minimaxi.com/v1/lyrics_generation` | `https://api.minimax.io/v1/lyrics_generation` |
| 图片生成 | `https://api.minimaxi.com/v1/image_generation` | `https://api.minimax.io/v1/image_generation` |
| 语音合成 | `https://api.minimaxi.com/v1/t2a_v2` | `https://api.minimax.io/v1/t2a_v2` |
| 视频生成 | `https://api.minimaxi.com/v1/video_generation` | `https://api.minimax.io/v1/video_generation` |

## 认证

所有请求需要在 Header 包含:
```
Authorization: Bearer <API_KEY>
Content-Type: application/json
```

API Key 位置: `~/.mmx/config.json` → `api_key`

## 音乐生成 API

**端点**: `POST /v1/music_generation`

**请求体**:
```json
{
    "model": "music-2.6",          // music-2.5, music-2.6, music-cover
    "prompt": "风格描述",           // 1-2000字符
    "lyrics": "歌词内容",           // 结构化歌词，带 [verse], [chorus] 等标签
    "output_format": "hex",        // 或 "url"（24小时过期）
    "audio_setting": {
        "sample_rate": 44100,
        "bitrate": 256000,
        "format": "mp3"
    }
}
```

**响应**:
```json
{
    "data": {
        "audio": "<hex编码的音频>",
        "status": 2               // 1=进行中, 2=完成
    },
    "extra_info": {
        "music_duration": 90017,  // 毫秒
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

## 歌词生成 API

**端点**: `POST /v1/lyrics_generation`

**请求体**:
```json
{
    "mode": "write_full_song",     // write_full_song 或 edit
    "prompt": "主题风格描述",       // 0-2000字符
    "title": "歌曲标题",            // 可选
    "lyrics": "<现有歌词>"         // 仅 edit 模式需要
}
```

**支持的歌词结构标签**:
- `[Intro]`, `[Verse]`, `[Pre-Chorus]`, `[Chorus]`, `[Hook]`, `[Drop]`
- `[Bridge]`, `[Solo]`, `[Build-up]`, `[Instrumental]`
- `[Breakdown]`, `[Break]`, `[Interlude]`, `[Outro]`

**响应**:
```json
{
    "song_title": "歌曲标题",
    "style_tags": "Pop, Summer, Romantic",
    "lyrics": "[Verse]\n歌词内容...",
    "base_resp": {"status_code": 0, "status_msg": "success"}
}
```

## 模型说明

### music-2.5 vs music-2.6 vs music-cover

| 模型 | 说明 | 要求 |
|---|---|---|
| music-2.5 | 基础音乐生成 | 需 Max Plan |
| music-2.6 | 升级版音乐生成 | 标准额度 |
| music-cover | 音乐风格转换/覆盖 | 标准额度 |

### 常见错误码

| 错误码 | 说明 |
|---|---|
| 0 | 成功 |
| 1004 | 认证失败，检查 API Key |
| 1008 | 额度不足 |
| 2013 | 参数错误 |
| 2049 | 无效 API Key |
| 2061 | 模型不支持（Plan 限制） |

## 额度周期

- 大多数额度: **每周一 UTC 0 点重置**
- MiniMax-M*: 每日重置（具体时间见 quota show）
