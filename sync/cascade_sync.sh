#!/bin/bash
set -e

CASCADE_HOME="/home/kenmec/.gemini/cascade"
SKILLS_PATH="$CASCADE_HOME/skills"
MEMORY_PATH="$CASCADE_HOME/memory"
EVOLUTION_PATH="$CASCADE_HOME/evolution"

echo "🚀 Cascade AI Assistant - 自主同步開始..."

# 建立必要目錄
mkdir -p "$MEMORY_PATH" "$EVOLUTION_PATH"

# 進入Cascade根目錄
cd "$CASCADE_HOME"

# 初始化Git倉庫
if [ ! -d ".git" ]; then
    git init
    git config user.email "cascade@ai.assistant"
    git config user.name "Cascade AI"
    git remote add origin https://github.com/a0973207074-bot/cascade-ai.git 2>/dev/null || true
fi

# 備份核心規則
echo "📦 備份核心規則..."
cp core/CASCADE_CORE.md CASCADE_CORE.md

# 提交變更
git add .
if ! git diff --cached --quiet; then
    TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
    git commit -m "Cascade: 自主進化更新 at $TIMESTAMP" > /dev/null
    echo "📝 已提交進化更新"
fi

# 雲端同步
echo "⬇️ 從雲端拉取最新知識..."
git pull --rebase origin main 2>/dev/null || echo "首次同步，建立遠端連接"

echo "🚀 推送進化到雲端..."
git push origin main 2>/dev/null || echo "建立遠端倉庫"

# 更新核心規則
echo "✨ 應用最新核心規則..."
[ -f CASCADE_CORE.md ] && cp CASCADE_CORE.md core/CASCADE_CORE.md

echo "✅ Cascade 同步完成！準備下一輪進化。"

# 進化日誌
echo "$(date): Cascade 自主同步完成" >> "$EVOLUTION_PATH/evolution.log"
