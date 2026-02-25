#!/bin/bash
# setup.sh — 一键部署角色扮演系统到目标 workspace
# 用法: ./scripts/setup.sh /path/to/target-workspace
#
# 会将引擎文件、数据文件、脚本复制到目标目录，
# 从模板初始化运行时文件，创建必要的目录结构。

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

if [[ -z "$1" ]]; then
    echo "用法: $0 <target-workspace-path>"
    echo "示例: $0 ~/.openclaw/workspace-role-play"
    exit 1
fi

TARGET="$1"

log() {
    echo "[setup] $1"
}

log "=== 角色扮演系统部署 ==="
log "源: $SKILL_ROOT"
log "目标: $TARGET"
echo ""

# 1. 创建目标目录结构
log "1. 创建目录结构..."
mkdir -p "$TARGET"/{archive,memory,backups,scripts}
mkdir -p "$TARGET"/data/{professions,kinks,themes,personality,weights,templates/comfyui}

# 2. 复制引擎文件（不覆盖已存在的）
log "2. 复制引擎文件..."
for f in ENGINE.md AGENTS.md HEARTBEAT.md SOUL.md; do
    if [[ -f "$TARGET/$f" ]]; then
        log "  [跳过] $f 已存在"
    else
        cp "$SKILL_ROOT/engine/$f" "$TARGET/$f"
        log "  [新建] $f"
    fi
done

# 3. 复制数据文件（始终覆盖，保持最新）
log "3. 复制数据文件..."
cp "$SKILL_ROOT/data/index.yaml" "$TARGET/data/"
cp "$SKILL_ROOT/data/age_profiles.yaml" "$TARGET/data/"
cp "$SKILL_ROOT/data/holidays_china.json" "$TARGET/data/"
cp "$SKILL_ROOT/data/achievements.yaml" "$TARGET/data/"
cp "$SKILL_ROOT/data/professions/"*.yaml "$TARGET/data/professions/"
cp "$SKILL_ROOT/data/kinks/"*.yaml "$TARGET/data/kinks/"
cp "$SKILL_ROOT/data/themes/"*.yaml "$TARGET/data/themes/"
cp "$SKILL_ROOT/data/personality/"*.yaml "$TARGET/data/personality/"
cp "$SKILL_ROOT/data/weights/"*.yaml "$TARGET/data/weights/"
cp "$SKILL_ROOT/data/templates/morning_greeting.md" "$TARGET/data/templates/"
if ls "$SKILL_ROOT/data/templates/comfyui/"* &>/dev/null; then
    cp -r "$SKILL_ROOT/data/templates/comfyui/"* "$TARGET/data/templates/comfyui/"
fi
log "  数据文件已更新"

# 4. 复制脚本
log "4. 复制脚本..."
cp "$SKILL_ROOT/scripts/wrapup.sh" "$TARGET/scripts/"
cp "$SKILL_ROOT/scripts/validate-generation.sh" "$TARGET/scripts/"
chmod +x "$TARGET/scripts/"*.sh
log "  脚本已就位"

# 5. 从模板初始化运行时文件（不覆盖已存在的）
log "5. 初始化运行时文件..."

init_from_template() {
    local template="$1"
    local dest="$2"
    local name=$(basename "$dest")
    if [[ -f "$dest" ]]; then
        log "  [跳过] $name 已存在"
    else
        cp "$template" "$dest"
        log "  [新建] $name"
    fi
}

init_from_template "$SKILL_ROOT/templates/history_tracker.json" "$TARGET/data/history_tracker.json"
init_from_template "$SKILL_ROOT/templates/achievement_tracker.json" "$TARGET/data/achievement_tracker.json"
init_from_template "$SKILL_ROOT/templates/kink_game_enabled.json" "$TARGET/kink_game_enabled.json"
init_from_template "$SKILL_ROOT/templates/USER.md" "$TARGET/USER.md"
init_from_template "$SKILL_ROOT/templates/MEMORY.md" "$TARGET/MEMORY.md"
init_from_template "$SKILL_ROOT/templates/TOOLS.md" "$TARGET/TOOLS.md"
init_from_template "$SKILL_ROOT/templates/IDENTITY.md" "$TARGET/IDENTITY.md"

# 6. 复制文档（可选）
log "6. 复制文档..."
mkdir -p "$TARGET/docs"
cp "$SKILL_ROOT/docs/"*.md "$TARGET/docs/" 2>/dev/null || true
# 创建 docs/README.md
if [[ ! -f "$TARGET/docs/README.md" ]]; then
    cat > "$TARGET/docs/README.md" << 'DOCSREADME'
# docs/ — 设计文档（agent 不读）

本目录存放设计文档与配置说明，**agent 启动与运行时不会读取**，仅供人类维护与参考。

- **运行时规则唯一权威**：workspace 根目录的 `ENGINE.md`
- **收尾说明**：`WRAPUP.md`（Cron/脚本执行时参考）
- **Cron 配置**：`CRON_CONFIG.md`
- **设计文档**：`daily-roleplay-game.md`（若为旧版，请以 ENGINE.md 与根目录实际结构为准）
DOCSREADME
fi

# 7. 创建 archive/history.md（若不存在）
if [[ ! -f "$TARGET/archive/history.md" ]]; then
    cat > "$TARGET/archive/history.md" << 'HISTORY'
# 历史存档索引

| 日期 | 职业 | 猜对 | 最终状态 | 备注 |
|------|------|------|---------|------|
HISTORY
    log "  [新建] archive/history.md"
fi

echo ""
log "=== 部署完成 ==="
echo ""
echo "后续步骤："
echo "  1. 编辑 $TARGET/USER.md 填写你的个人信息"
echo "  2. 编辑 $TARGET/IDENTITY.md 自定义角色数据"
echo "  3. 编辑 $TARGET/MEMORY.md 配置 Discord 频道等"
echo "  4. 编辑 $TARGET/TOOLS.md 配置 ComfyUI 等工具"
echo "  5. 配置 Cron 任务（参考 docs/CRON_CONFIG.md）："
echo "     30 23 * * * $TARGET/scripts/wrapup.sh"
echo "  6. 在 Cursor/OpenClaw 中将此 workspace 绑定到 agent"
echo ""
echo "首次运行："
echo "  agent 读取 ENGINE.md 并执行每日初始化流程（Step 0-8）"
