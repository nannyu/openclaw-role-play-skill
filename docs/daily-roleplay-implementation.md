# 每日职业角色扮演 - 实现方案 v2

> 状态：已实施
> 绑定渠道：Discord only
> 创建时间：2026-02-19

---

## 架构

```
每天 6:00 (Cron isolated job, Opus 4.6)
    │
    ├── 选职业 + 抽性癖 + 生成设定
    ├── 写入 roleplay-active.md（Discord 专用）
    ├── SOUL.md 不动（其他渠道不受影响）
    ├── 创建存档 roleplay-archive/日期-职业/
    ├── ComfyUI 生成职业自拍
    └── 发送早安到 Discord
    
主模型日常对话
    │
    ├── Discord → 读 roleplay-active.md → 角色扮演
    └── 其他渠道 → 读 SOUL.md → 默认人格
```

## 文件分工

| 文件 | 用途 | 谁写 | 谁读 |
|------|------|------|------|
| SOUL.md | 全局人格（不动） | — | 所有渠道 |
| roleplay-active.md | 当日角色设定 | Cron 子代理 | 仅 Discord |
| AGENTS.md | 渠道路由规则 | 已配置 | 主模型 |
| HEARTBEAT.md | 暗示策略 | Cron 子代理 | 主模型 |
| daily-roleplay-game.md | 完整规则参考 | 手动维护 | Cron 子代理 |
| roleplay-archive/ | 每日存档 | Cron 子代理+主模型 | 复盘用 |

## Cron 任务配置

- 名称：每日职业角色初始化
- 时间：0 6 * * * (Asia/Shanghai)
- 会话：isolated
- 模型：openrouter/anthropic/claude-opus-4.6
- 交付：announce → Discord 1471537939967115548
