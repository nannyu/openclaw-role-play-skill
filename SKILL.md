---
name: daily-roleplay-game
description: Daily profession roleplay game engine with hidden kink guessing, AI-driven personality generation, achievement tracking, and multi-backend image generation (ComfyUI/SD WebUI/Midjourney/Nano Banana Pro). Use when setting up or running the daily roleplay system, generating daily characters, managing guess-log, or handling roleplay archives.
---

# Daily Profession Roleplay Game

AI 驱动的每日职业角色扮演系统。每天自动抽取职业、年龄、性格（五维）、隐藏性癖（4~6 个），通过三级暗示系统引导猜测，支持多种生图后端（ComfyUI / SD WebUI / Midjourney / Nano Banana Pro）。

## Quick Setup

运行一键部署脚本将系统安装到指定 workspace：

```bash
./scripts/setup.sh /path/to/target-workspace
```

脚本会：
1. 复制引擎文件（ENGINE.md, AGENTS.md, HEARTBEAT.md, SOUL.md）
2. 复制数据目录（professions, kinks, themes, personality, weights, templates）
3. 从模板初始化运行时文件（history_tracker.json, achievement_tracker.json 等）
4. 创建 archive/ 和 memory/ 目录
5. 设置脚本可执行权限

## System Architecture

```
target-workspace/
├── SOUL.md / ENGINE.md / AGENTS.md / HEARTBEAT.md  ← 核心（静态）
├── USER.md / MEMORY.md / TOOLS.md / IDENTITY.md    ← 用户信息（手动维护）
├── roleplay-active.md      ← 每日生成（YAML front-matter + 强制模板）
├── guess-log.md             ← 当日猜测进度
├── kink_game_enabled.json   ← 玩法开关
├── data/                    ← 数据库
│   ├── professions/*.yaml   ← 13 类 ~138 个职业
│   ├── kinks/category_[a-f].yaml ← 6 类 131 个性癖
│   ├── themes/              ← 主题日配置
│   ├── personality/         ← 五维性格生成
│   ├── weights/             ← 职业+年龄性癖加权
│   └── templates/           ← 早安模板 + 生图配置
├── scripts/
│   ├── wrapup.sh            ← 23:30 收尾归档
│   └── validate-generation.sh ← 生成器输出验证
└── archive/                 ← 历史存档
```

## Daily Flow

### 6:00 — 自动初始化（ENGINE.md Step 0-8）

1. 前置检查（生图工具、残留清理、re-roll 规则）
2. 抽取职业 → 主题日 → 年龄 → 性癖（3~5+1，含职业+年龄加权）→ 稀有替换
3. 生成五维性格（职业维度/自我/本我/超我/NSFW性格）
4. 写入 roleplay-active.md（强制模板，含 YAML front-matter）
5. 生成 bio.md (~800字) + personality.md (~500字) 到存档
6. 创建 guess-log.md + kink_game_enabled.json
7. 发送早安消息 + 生图自拍
8. 更新 history_tracker.json（全部四项追踪）
9. 执行 validate-generation.sh 验证输出

### 运行时 — Agent 行为

- 按 AGENTS.md 启动顺序读取文件，进入角色
- 猜性癖玩法默认隐藏，用户发送口令解锁
- 三级暗示：6-12 Lv.1 / 12-18 Lv.2 / 18-24 Lv.3
- 猜对脱衣+拍照，猜错3次穿回，通关全脱+惩罚照
- 禁止性癖信息泄漏

### 23:30 — 自动收尾（wrapup.sh）

归档 roleplay-active.md + guess-log.md + 图片 → archive/YYYY-MM-DD-职业名/

## Key Files Reference

| File | Purpose | Update |
|------|---------|--------|
| [engine/ENGINE.md](engine/ENGINE.md) | 运行时规则唯一权威 + 生成器操作手册 | 静态 |
| [engine/AGENTS.md](engine/AGENTS.md) | 启动顺序与行为规范 | 静态 |
| [engine/HEARTBEAT.md](engine/HEARTBEAT.md) | 心跳规则 | 静态 |
| [engine/SOUL.md](engine/SOUL.md) | 角色人格核心 | 可自定义 |
| [data/index.yaml](data/index.yaml) | 数据索引与生成逻辑 | 扩展时修改 |
| [data/achievements.yaml](data/achievements.yaml) | 成就系统配置 | 可自定义 |

## Customization

- **角色人格**：编辑 `engine/SOUL.md`
- **添加职业**：在 `data/professions/` 对应分类 YAML 中追加
- **添加性癖**：在 `data/kinks/category_*.yaml` 中追加，更新 `data/index.yaml` count
- **添加主题日**：编辑 `data/themes/daily_themes.yaml`
- **生图工具配置**：编辑 `templates/TOOLS.md`（ComfyUI 详细配置见 `data/templates/comfyui/README.md`）

## OpenClaw Deployment

本系统需要作为独立 agent 部署，配置心跳（30 分钟）和定时任务（6:00 + 23:30）。

- **配置参考**：[openclaw.example.json5](openclaw.example.json5)
- **完整部署指南**：[docs/OPENCLAW_SETUP.md](docs/OPENCLAW_SETUP.md)
- **Cron 配置**：[docs/CRON_CONFIG.md](docs/CRON_CONFIG.md)

## Design Documents

详细设计文档见 [docs/daily-roleplay-game.md](docs/daily-roleplay-game.md)
