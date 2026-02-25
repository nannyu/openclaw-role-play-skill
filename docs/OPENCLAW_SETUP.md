# OpenClaw 部署指南

本系统需要作为**独立 agent** 部署（不替换默认 agent），拥有独立 workspace、心跳和定时任务。

---

## 1. 创建独立 Agent

```bash
openclaw agents add role-play
```

这会在 `~/.openclaw/agents/role-play/` 下创建 agent 目录。

## 2. 配置 openclaw.json

将以下内容合并到 `~/.openclaw/openclaw.json`（参考 `openclaw.example.json5`）：

```json5
{
  agents: {
    list: [
      {
        id: "role-play",
        name: "角色扮演",
        workspace: "~/.openclaw/workspace-role-play",
        model: {
          primary: "anthropic/claude-sonnet-4-5",
        },
        heartbeat: {
          every: "30m",
          target: "last",
          activeHours: { start: "06:00", end: "23:59" },
        },
      },
    ],
  },
}
```

**关键配置说明**：

| 字段 | 说明 |
|------|------|
| `workspace` | setup.sh 的部署目标路径，需与下一步一致 |
| `heartbeat.every` | 30 分钟心跳，用于三级暗示系统 |
| `heartbeat.activeHours` | 限制心跳在 6:00-24:00 活跃（角色扮演时段） |
| `model.primary` | 可按需更换模型 |

## 3. 部署文件到 Workspace

```bash
cd /path/to/openclaw-role-play-skill
./scripts/setup.sh ~/.openclaw/workspace-role-play
```

非交互环境下脚本会自动跳过角色设定输入，部署后手动编辑配置文件。

## 4. 编辑必填配置

部署后必须编辑以下文件：

```bash
cd ~/.openclaw/workspace-role-play
```

### MEMORY.md — 消息频道（必填）

```markdown
## 系统配置
- **消息频道**：（填写你的频道标识）
  - 格式：discord:频道ID / telegram:频道ID / feishu:xxx / last
```

ENGINE.md 和 HEARTBEAT.md 中的消息发送会读取此处的频道配置。

### IDENTITY.md — 角色基础信息

```markdown
- **Name:** （角色名称）
- **Timezone:** Asia/Shanghai
```

### USER.md — 主人信息

按提示填写称呼和偏好。

### TOOLS.md — 生图工具

配置生图后端（ComfyUI / SD WebUI / Midjourney / Nano Banana Pro），填写工具类型和接入地址。不使用生图功能可填「无」。

## 5. 配置定时任务

### 每日 6:00 — 自动初始化

```bash
openclaw cron add \
  --agent role-play \
  --name "每日角色生成" \
  --cron "0 6 * * *" \
  --tz "Asia/Shanghai" \
  --session isolated \
  --message "读取 ENGINE.md 并按步骤执行每日初始化（Step 0-8）"
```

### 每日 23:30 — 自动收尾归档

```bash
openclaw cron add \
  --agent role-play \
  --name "每日收尾归档" \
  --cron "30 23 * * *" \
  --tz "Asia/Shanghai" \
  --session isolated \
  --message "读取 docs/WRAPUP.md 按步骤执行收尾归档，完成后回复 WRAPUP_OK"
```

### 验证任务

```bash
openclaw cron list
```

## 6. 频道绑定（可选）

如需将 agent 绑定到特定消息频道，在 `openclaw.json` 中配置 channel routing。以下为各平台示例：

### Discord

```json5
{
  channels: {
    discord: {
      enabled: true,
      groupPolicy: {
        routes: [
          { match: { channelId: "你的频道ID" }, agent: "role-play" },
        ],
      },
    },
  },
}
```

### Telegram

```json5
{
  channels: {
    telegram: {
      enabled: true,
      groupPolicy: {
        routes: [
          { match: { chatId: "你的群组ID" }, agent: "role-play" },
        ],
      },
    },
  },
}
```

### 飞书

```json5
{
  channels: {
    feishu: {
      enabled: true,
      groupPolicy: {
        routes: [
          { match: { chatId: "你的群组ID" }, agent: "role-play" },
        ],
      },
    },
  },
}
```

## 7. 首次运行检查清单

- [ ] `openclaw.json` 中已添加 role-play agent 配置
- [ ] `~/.openclaw/workspace-role-play/` 目录已由 setup.sh 创建
- [ ] `MEMORY.md` 已填入消息频道标识
- [ ] `IDENTITY.md` 已填入角色名称和时区
- [ ] `USER.md` 已填写主人信息
- [ ] `TOOLS.md` 已配置生图工具（或填「无」）
- [ ] cron 任务已添加（`openclaw cron list` 可见）
- [ ] 心跳已生效（agent 每 30 分钟自动执行 HEARTBEAT.md）

## 8. 测试

手动触发一次初始化：

```bash
openclaw cron run <job-id>
```

或直接对 role-play agent 发消息，确认角色已正常进入。

---

## 架构说明

```
~/.openclaw/
├── openclaw.json              ← 全局配置（含 role-play agent）
├── cron/jobs.json             ← 定时任务持久化
├── agents/role-play/          ← agent 运行时数据（自动创建）
└── workspace-role-play/       ← 角色扮演 workspace（setup.sh 部署）
    ├── SOUL.md / ENGINE.md / AGENTS.md / HEARTBEAT.md
    ├── USER.md / MEMORY.md / TOOLS.md / IDENTITY.md
    ├── roleplay-active.md     ← 每日生成
    ├── guess-log.md           ← 当日猜测进度
    ├── data/                  ← 游戏数据库
    ├── scripts/               ← wrapup.sh 等
    └── archive/               ← 历史存档
```
