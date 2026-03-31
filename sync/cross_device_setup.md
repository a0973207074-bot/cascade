# Cascade AI Assistant - 跨設備全功能同步指南

## 🎯 目標
在任何電腦上快速恢復Cascade AI Assistant的完整功能，包括：
- ✅ 所有技能與知識
- ✅ MCP伺服器配置
- ✅ 個人化設定
- ✅ 專案經驗記憶

---

## 🚀 一鍵部署腳本

### 方案A: 完整同步腳本
```bash
#!/bin/bash
# cascade_setup.sh - Cascade AI Assistant 一鍵部署

set -e

echo "🚀 Cascade AI Assistant 跨設備部署開始..."

# 1. 建立基礎目錄結構
echo "📁 建立目錄結構..."
mkdir -p ~/.gemini/cascade/{core,skills,memory,evolution,sync,config}

# 2. 設定Git全域配置
echo "⚙️ 設定Git配置..."
git config --global user.email "cascade@ai.assistant"
git config --global user.name "Cascade AI"

# 3. 克隆Cascade核心倉庫
echo "📥 下載Cascade核心..."
cd ~/.gemini/cascade
if [ ! -d ".git" ]; then
    git clone https://github.com/a0973207074-bot/cascade-ai.git .
fi

# 4. 同步最新知識
echo "🔄 同步最新知識..."
git pull origin main

# 5. 設定每日同步
echo "⏰ 設定每日同步..."
(crontab -l 2>/dev/null; echo "0 8 * * * ~/.gemini/cascade/sync/cascade_sync.sh") | crontab -

# 6. 安裝VS Code擴充
echo "🔧 安裝VS Code擴充..."
if command -v code &> /dev/null; then
    cat ~/.gemini/cascade/config/vscode_extensions.txt | while read ext; do
        code --install-extension "$ext" 2>/dev/null || true
    done
fi

# 7. 設定MCP配置
echo "🔌 設定MCP配置..."
cp ~/.gemini/cascade/config/mcp_config.json ~/.gemini/antigravity/mcp_config.json 2>/dev/null || true

# 8. 建立快捷指令
echo "⚡ 建立快捷指令..."
echo 'alias cascade-sync="~/.gemini/cascade/sync/cascade_sync.sh"' >> ~/.bashrc
echo 'alias cascade-status="cd ~/.gemini/cascade && git status"' >> ~/.bashrc

echo "✅ Cascade AI Assistant 部署完成！"
echo "🎯 重新載入終端機或執行: source ~/.bashrc"
```

### 方案B: 極簡版指令
```bash
# 在新電腦上執行這一行即可
curl -fsSL https://raw.githubusercontent.com/a0973207074-bot/cascade-ai/main/setup.sh | bash
```

---

## 📋 詳細設定步驟

### 步驟1: 環境準備
```bash
# 確保基本工具已安裝
sudo apt update
sudo apt install -y git curl code

# 檢查Python環境
python3 --version
pip3 --version
```

### 步驟2: 執行一鍵部署
```bash
# 下載並執行部署腳本
wget https://raw.githubusercontent.com/a0973207074-bot/cascade-ai/main/cascade_setup.sh
chmod +x cascade_setup.sh
./cascade_setup.sh
```

### 步驟3: 驗證部署
```bash
# 檢查Cascade狀態
cascade-status

# 執行首次同步
cascade-sync

# 檢查技能庫
ls ~/.gemini/cascade/skills/
```

---

## 🔧 高階配置選項

### 1. 自定義配置
```bash
# 編輯個人化設定
nano ~/.gemini/cascade/config/personal_settings.json
```

### 2. 專案模板同步
```bash
# 同步專案模板
git clone https://github.com/a0973207074-bot/cascade-templates.git ~/.gemini/cascade/templates
```

### 3. 雲端備份設定
```bash
# 設定多雲端備份
echo "DROPBOX_TOKEN=your_token" >> ~/.gemini/cascade/config/backup_config
echo "GOOGLE_DRIVE_TOKEN=your_token" >> ~/.gemini/cascade/config/backup_config
```

---

## 🌐 支援的平台

### Linux (Ubuntu/Debian)
```bash
# 完全支援，推薦使用
curl -fsSL https://raw.githubusercontent.com/a0973207074-bot/cascade-ai/main/setup.sh | bash
```

### macOS
```bash
# 使用Homebrew安裝依賴
brew install git curl visual-studio-code
curl -fsSL https://raw.githubusercontent.com/a0973207074-bot/cascade-ai/main/setup.sh | bash
```

### Windows (WSL)
```powershell
# 在WSL中執行
wsl --install
curl -fsSL https://raw.githubusercontent.com/a0973207074-bot/cascade-ai/main/setup.sh | bash
```

---

## 🔄 同步機制詳解

### 1. 知識庫同步
```bash
# 自動從雲端同步所有技能和經驗
cascade-sync
```

### 2. 個人化設定同步
```bash
# 同步個人偏好和配置
cp ~/.gemini/cascade/config/* ~/.gemini/antigravity/
```

### 3. 專案經驗同步
```bash
# 同步專案經驗記憶
rsync -av ~/.gemini/cascade/memory/ origin:memory/
```

---

## 🎯 快速指令參考

### 常用指令
```bash
# 部署Cascade
curl -fsSL https://raw.githubusercontent.com/a0973207074-bot/cascade-ai/main/setup.sh | bash

# 手動同步
cascade-sync

# 檢查狀態
cascade-status

# 查看可用技能
ls ~/.gemini/cascade/skills/

# 重新載入配置
source ~/.bashrc
```

### 故障排除
```bash
# 重新初始化
rm -rf ~/.gemini/cascade
curl -fsSL https://raw.githubusercontent.com/a0973207074-bot/cascade-ai/main/setup.sh | bash

# 檢查網路連接
ping github.com

# 檢查Git狀態
cd ~/.gemini/cascade && git status
```

---

## 📱 行動設備支援

### ChromeOS
```bash
# 在Linux容器中執行
curl -fsSL https://raw.githubusercontent.com/a0973207074-bot/cascade-ai/main/setup.sh | bash
```

### iPad (通過SSH)
```bash
# 使用iSH或SSH連接到Linux環境
curl -fsSL https://raw.githubusercontent.com/a0973207074-bot/cascade-ai/main/setup.sh | bash
```

---

## 🔒 安全性設定

### 1. SSH金鑰設定
```bash
# 生成SSH金鑰
ssh-keygen -t ed25519 -C "cascade@ai.assistant"

# 添加到GitHub
cat ~/.ssh/id_ed25519.pub
```

### 2. 權限設定
```bash
# 設定適當權限
chmod 700 ~/.gemini
chmod 600 ~/.gemini/cascade/config/*
```

---

## 📞 支援與幫助

### 取得幫助
```bash
# 查看幫助文件
cat ~/.gemini/cascade/README.md

# 檢查日誌
tail -f ~/.gemini/cascade/evolution/evolution.log

# 回報問題
echo "問題描述" > ~/.gemini/cascade/evolution/issue_report.txt
```

---

## 🎉 完成後驗證

部署完成後，執行以下驗證：

```bash
# 1. 檢查Cascade狀態
cascade-status

# 2. 查看技能數量
ls ~/.gemini/cascade/skills/ | wc -l

# 3. 檢查同步狀態
cascade-sync

# 4. 測試MCP配置
cat ~/.gemini/antigravity/mcp_config.json
```

**驗證成功後，你在新電腦上就擁有與原電腦完全相同的Cascade AI Assistant功能！** 🚀
