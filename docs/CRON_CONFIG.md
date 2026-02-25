# Cron 任务配置 — 角色扮演每日收尾

## 任务信息

| 项目 | 值 |
|------|-----|
| **任务名称** | 角色扮演收尾 |
| **执行时间** | 每日 23:30 |
| **命令** | `/Users/nn/.openclaw/workspace-role-play/scripts/wrapup.sh` |
| **目标 Agent** | role-play |
| **输出** | `WRAPUP_OK`（成功时）|

## 功能说明

脚本自动完成：
1. 检查当日角色扮演是否有内容需要归档
2. 复制 `roleplay-active.md` 到归档（原文件保留）
3. 移动 `guess-log.md`、图片文件到归档目录
4. 更新 `archive/history.md` 历史索引

## 配置方式

**方式一：系统 crontab**
```bash
30 23 * * * /Users/nn/.openclaw/workspace-role-play/scripts/wrapup.sh >> /tmp/roleplay-wrapup.log 2>&1
```

**方式二：OpenClaw cron**
```
执行时间: 23:30
任务: 执行脚本 /Users/nn/.openclaw/workspace-role-play/scripts/wrapup.sh
agent: role-play
```

## 前置条件

- 脚本已可执行：`chmod +x /Users/nn/.openclaw/workspace-role-play/scripts/wrapup.sh`
- 目录权限正常

## 测试

手动执行测试：
```bash
/Users/nn/.openclaw/workspace-role-play/scripts/wrapup.sh
```

预期输出：
```
[YYYY-MM-DD HH:MM:SS] ...
WRAPUP_OK
```
