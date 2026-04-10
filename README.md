# MiniMax Assistant Skill for OpenClaw | OpenClaw 智能助手 MiniMax 技能

[English](#english) | [中文](#中文)

---

## English

### Overview

This skill enables OpenClaw AI assistants to access MiniMax AI Platform capabilities.

### Features

- Text chat
- Image generation
- Music generation (with model selection support)
- Lyrics generation → Song pipeline
- Video generation
- Speech synthesis
- Web search

### Prerequisites

1. **OpenClaw AI Assistant** installed
2. **mmx CLI**: `npm install -g mmx-cli`
3. **MiniMax API Key**: https://platform.minimaxi.com (CN) or https://platform.minimax.io (Global)

### Installation

Place this skill folder in your OpenClaw skills directory:

```
your-openclaw-workspace/skills/minimax-assistant/
├── SKILL.md
├── scripts/
│   ├── music-gen.sh          # Music generation (model selectable)
│   └── lyrics-to-song.sh    # Lyrics → Song pipeline
└── references/
    └── api-models.md         # API documentation
```

### Quick Usage

#### Music Generation

```bash
./scripts/music-gen.sh \
  --model music-2.6 \
  --prompt "Jazz, smooth, relaxing" \
  --lyrics "[verse]\nLa la la..." \
  --out song.mp3
```

#### Lyrics → Song (Full Pipeline)

```bash
./scripts/lyrics-to-song.sh \
  --prompt "Chinese classical, melancholic" \
  --title "烟雨江南" \
  --style "Guzheng, Pipa" \
  --out song.mp3
```

#### Direct CLI Usage

```bash
mmx text chat --message "Hello"
mmx image "A cute cat"
mmx speech synthesize --text "Hello!" --out hello.mp3
mmx quota show
```

### Available Models

| Model | Use Case | Weekly Quota |
|-------|----------|--------------|
| MiniMax-M* | Text Chat | 15,000 |
| music-2.6 | Music Gen | 700 |
| music-cover | Music Cover | 700 |
| lyrics_generation | Lyrics Gen | 700 |
| image-01 | Image Gen | 350 |
| speech-hd | Speech | 28,000 |

### API Reference

See `references/api-models.md` for detailed API documentation.

---

## 中文

### 简介

本技能为 OpenClaw AI 助手提供 MiniMax AI 平台能力支持。

### 功能

- 文字聊天
- 图片生成
- 音乐生成（支持选择模型）
- 歌词生成 → 歌曲完整流程
- 视频生成
- 语音合成
- 网络搜索

### 前置条件

1. 已安装 **OpenClaw AI 助手**
2. 安装 **mmx CLI**: `npm install -g mmx-cli`
3. **MiniMax API Key**: https://platform.minimaxi.com (CN) 或 https://platform.minimax.io (Global)

### 安装

将技能文件夹放入 OpenClaw 技能目录：

```
你的-openclaw-工作区/skills/minimax-assistant/
├── SKILL.md
├── scripts/
│   ├── music-gen.sh          # 音乐生成（可选模型）
│   └── lyrics-to-song.sh    # 歌词→歌曲完整流程
└── references/
    └── api-models.md         # API 文档
```

### 快速使用

#### 音乐生成

```bash
./scripts/music-gen.sh \
  --model music-2.6 \
  --prompt "爵士乐，流畅放松" \
  --lyrics "[verse]\n啦啦啦..." \
  --out song.mp3
```

#### 歌词 → 歌曲完整流程

```bash
./scripts/lyrics-to-song.sh \
  --prompt "中国古典风格，婉约惆怅" \
  --title "烟雨江南" \
  --style "古筝，琵琶" \
  --out song.mp3
```

#### 直接使用 mmx CLI

```bash
mmx text chat --message "你好"
mmx image "一只可爱的猫"
mmx speech synthesize --text "你好！" --out hello.mp3
mmx quota show
```

### 可用模型

| 模型 | 用途 | 周额度 |
|------|------|--------|
| MiniMax-M* | 文字聊天 | 15,000 |
| music-2.6 | 音乐生成 | 700 |
| music-cover | 音乐覆盖 | 700 |
| lyrics_generation | 歌词生成 | 700 |
| image-01 | 图片生成 | 350 |
| speech-hd | 语音合成 | 28,000 |

### API 参考

详见 `references/api-models.md`。

---

## License | 许可证

MIT
