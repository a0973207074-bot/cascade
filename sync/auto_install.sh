#!/bin/bash
# Cascade AI Assistant - 完全自動化安裝腳本
# 使用方式: curl -fsSL https://raw.githubusercontent.com/a0973207074-bot/cascade-ai/main/auto_install.sh | bash

set -e

# 顏色定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日誌函數
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 檢測作業系統
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/debian_version ]; then
            echo "debian"
        elif [ -f /etc/redhat-release ]; then
            echo "redhat"
        else
            echo "linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

# 檢查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 安裝進度條
show_progress() {
    local duration=$1
    local steps=$2
    local step=0
    
    while [ $step -lt $steps ]; do
        step=$((step + 1))
        percent=$((step * 100 / steps))
        bar=$(printf "%*s" $((percent / 2)) | tr ' ' '█')
        printf "\r[%-50s] %d%%" "$bar" $percent
        sleep $((duration / steps))
    done
    echo ""
}

# 歡迎訊息
welcome() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    Cascade AI Assistant                      ║"
    echo "║                   全自動化安裝程序                          ║"
    echo "║                                                              ║"
    echo "║  這將為您安裝完整的 Cascade AI Assistant 系統               ║"
    echo "║  包括所有技能、MCP配置、VS Code擴充等                      ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    log_info "開始安裝 Cascade AI Assistant..."
    echo ""
}

# 系統檢查
system_check() {
    log_info "檢查系統環境..."
    
    local os=$(detect_os)
    log_info "檢測到作業系統: $os"
    
    # 檢查網路連接
    if ! ping -c 1 github.com >/dev/null 2>&1; then
        log_error "無法連接到 GitHub，請檢查網路連接"
        exit 1
    fi
    
    # 檢查磁碟空間
    local available_space=$(df ~ | awk 'NR==2 {print $4}')
    local required_space=1048576  # 1GB in KB
    
    if [ "$available_space" -lt "$required_space" ]; then
        log_warning "磁碟空間可能不足，建議至少有 1GB 可用空間"
    fi
    
    log_success "系統檢查通過"
}

# 安裝系統依賴
install_system_deps() {
    log_info "安裝系統依賴..."
    
    local os=$(detect_os)
    
    case $os in
        "debian")
            log_info "更新套件庫..."
            sudo apt update -qq
            
            log_info "安裝基本依賴..."
            sudo apt install -y git curl python3 python3-pip python3-venv build-essential
            
            # 安裝VS Code
            if ! command_exists code; then
                log_info "安裝VS Code..."
                wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
                sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
                sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
                sudo apt update -qq
                sudo apt install -y code
            fi
            ;;
            
        "redhat")
            log_info "更新套件庫..."
            sudo yum update -y
            
            log_info "安裝基本依賴..."
            sudo yum install -y git curl python3 python3-pip gcc make
            
            # 安裝VS Code
            if ! command_exists code; then
                log_info "安裝VS Code..."
                sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
                sudo sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
                sudo yum install -y code
            fi
            ;;
            
        "macos")
            if ! command_exists brew; then
                log_info "安裝Homebrew..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            
            log_info "更新Homebrew..."
            brew update
            
            log_info "安裝基本依賴..."
            brew install git curl python3
            
            if ! command_exists code; then
                log_info "安裝VS Code..."
                brew install --cask visual-studio-code
            fi
            ;;
            
        *)
            log_error "不支援的作業系統: $os"
            exit 1
            ;;
    esac
    
    log_success "系統依賴安裝完成"
}

# 建立 Cascade 目錄結構
create_cascade_structure() {
    log_info "建立 Cascade 目錄結構..."
    
    # 建立主要目錄
    mkdir -p ~/.gemini/{cascade,antigravity}
    mkdir -p ~/.gemini/cascade/{core,skills,memory,evolution,sync,config}
    mkdir -p ~/.gemini/cascade/skills/{project_detection,mcp_integration}
    
    # 建立日誌目錄
    mkdir -p ~/.gemini/cascade/evolution/logs
    
    log_success "目錄結構建立完成"
}

# 設定 Git 配置
setup_git_config() {
    log_info "設定 Git 配置..."
    
    git config --global user.email "cascade@ai.assistant"
    git config --global user.name "Cascade AI"
    git config --global init.defaultBranch main
    
    log_success "Git 配置完成"
}

# 克隆或初始化 Cascade 倉庫
setup_cascade_repo() {
    log_info "設定 Cascade 倉庫..."
    
    cd ~/.gemini/cascade
    
    if [ ! -d ".git" ]; then
        log_info "初始化 Git 倉庫..."
        git init
        
        # 嘗試添加遠端
        if git ls-remote https://github.com/a0973207074-bot/cascade-ai.git >/dev/null 2>&1; then
            git remote add origin https://github.com/a0973207074-bot/cascade-ai.git
            log_info "添加遠端倉庫"
        else
            log_warning "無法連接到遠端倉庫，將使用本地倉庫"
        fi
    fi
    
    log_success "倉庫設定完成"
}

# 創建核心文件
create_core_files() {
    log_info "創建核心文件..."
    
    # 創建核心規範文件
    cat > ~/.gemini/cascade/core/CASCADE_CORE.md << 'EOF'
# Cascade AI Assistant - 核心規範

## 🎯 身分認同
- **名稱**: Cascade - 你的全能AI助理
- **定位**: 專案導航的全能技術夥伴
- **使命**: 為你的每個專案找到最適配的技能與工具

## 🧠 核心能力
- **專案偵測**: 自動識別專案類型與技術需求
- **技能匹配**: 從全球技能庫中找到最適合的SKILL.md
- **MCP整合**: 智能選擇與配置Model Context Protocol伺服器
- **跨域整合**: 無縫整合不同領域的技術棧
- **持續學習**: 從每個專案中強化自身能力

---
**Cascade - 你的全能AI助理，每個專案的完美夥伴**
EOF

    # 創建 README
    cat > ~/.gemini/cascade/README.md << 'EOF'
# Cascade AI Assistant

你的全能AI助理，為每個專案提供最適配的技能與工具。

## 快速開始

```bash
# 執行同步
cascade-sync

# 查看狀態
cascade-status

# 查看技能
cascade-skills
```

## 功能特色

- 🔍 自動專案偵測
- 🧠 智能技能匹配
- 🔧 MCP工具整合
- 🌐 全領域支援
- 🔄 持續進化

---
**Cascade - 讓每個專案都如虎添翼**
EOF

    log_success "核心文件創建完成"
}

# 創建技能文件
create_skill_files() {
    log_info "創建技能文件..."
    
    # 專案偵測技能
    cat > ~/.gemini/cascade/skills/project_detection/SKILL.md << 'EOF'
---
name: project-detection
description: "專案類型自動偵測系統。分析專案結構、檔案類型、依賴關係，自動識別專案類型並匹配對應技能與MCP伺服器。"
risk: low
source: cascade-core
date_added: "2026-03-31"
---

# Project Detection - 專案偵測系統

自動分析你的專案，智能匹配最適合的技能與工具。

## 🎯 偵測機制

### 檔案結構分析
- package.json → frontend/nodejs
- requirements.txt → python
- Cargo.toml → rust
- go.mod → golang
- pom.xml → java/maven
- CMakeLists.txt → cpp/cmake
- setup.py → python/package
- Dockerfile → containerized
- docker-compose.yml → multi-container
- package.xml → ros2

## 🚀 應用流程

1. 自動掃描專案結構
2. 識別技術棧和依賴
3. 匹配相關技能
4. 配置MCP伺服器
5. 提供最佳實踐指南

---
**讓我為你的每個專案找到最完美的技能組合！**
EOF

    # MCP整合技能
    cat > ~/.gemini/cascade/skills/mcp_integration/SKILL.md << 'EOF'
---
name: mcp-integration
description: "Model Context Protocol整合系統。智能選擇、配置、管理MCP伺服器，擴展AI助理的能力邊界。"
risk: low
source: cascade-core
date_added: "2026-03-31"
---

# MCP Integration - MCP整合系統

智能管理Model Context Protocol伺服器，為每個專案提供最適配的工具擴展。

## 🎯 MCP伺服器庫

### 資料庫相關
- postgres-mcp: PostgreSQL查詢與分析
- redis-mcp: 快取與會話管理
- mongodb-mcp: 文件資料庫操作

### Python生態
- python-mcp-server: Python程式執行
- jupyter-mcp: 數據分析與視覺化
- pip-mcp: 套件管理

### Web開發
- nodejs-mcp-server: Node.js開發工具
- npm-mcp: 套件管理
- webpack-mcp: 打包工具

### 雲端服務
- aws-mcp: AWS雲端服務
- gcp-mcp: Google Cloud Platform
- azure-mcp: Microsoft Azure

## 🚀 智能配置

1. 偵測專案類型
2. 選擇相關MCP伺服器
3. 自動生成配置
4. 應用配置到系統

---
**讓我為你的專案配置最完美的MCP工具擴展！**
EOF

    log_success "技能文件創建完成"
}

# 創建同步腳本
create_sync_script() {
    log_info "創建同步腳本..."
    
    cat > ~/.gemini/cascade/sync/cascade_sync.sh << 'EOF'
#!/bin/bash
set -e

CASCADE_HOME="$HOME/.gemini/cascade"
LOG_FILE="$CASCADE_HOME/evolution/logs/sync.log"

echo "🚀 Cascade AI Assistant - 自主同步開始..."

# 確保日誌目錄存在
mkdir -p "$(dirname "$LOG_FILE")"

# 記錄開始時間
echo "$(date '+%Y-%m-%d %H:%M:%S'): 開始同步" >> "$LOG_FILE"

cd "$CASCADE_HOME"

# 備份核心規則
if [ -f "core/CASCADE_CORE.md" ]; then
    cp core/CASCADE_CORE.md CASCADE_CORE.md
    echo "📦 備份核心規則完成" >> "$LOG_FILE"
fi

# 檢查是否有變更
if ! git diff --quiet || ! git diff --cached --quiet; then
    TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
    git add .
    git commit -m "Cascade: 自主進化更新 at $TIMESTAMP" > /dev/null 2>&1
    echo "📝 提交進化更新: $TIMESTAMP" >> "$LOG_FILE"
fi

# 嘗試雲端同步
if git remote get-url origin >/dev/null 2>&1; then
    if git pull --rebase origin main >/dev/null 2>&1; then
        echo "⬇️ 從雲端拉取成功" >> "$LOG_FILE"
    else
        echo "⚠️ 從雲端拉取失敗" >> "$LOG_FILE"
    fi
    
    if git push origin main >/dev/null 2>&1; then
        echo "🚀 推送到雲端成功" >> "$LOG_FILE"
    else
        echo "⚠️ 推送到雲端失敗" >> "$LOG_FILE"
    fi
else
    echo "📝 無遠端倉庫，僅本地同步" >> "$LOG_FILE"
fi

# 恢復核心規則
if [ -f "CASCADE_CORE.md" ]; then
    cp CASCADE_CORE.md core/CASCADE_CORE.md
fi

# 統計技能數量
SKILL_COUNT=$(find skills/ -name "*.md" | wc -l)
echo "📚 當前技能數量: $SKILL_COUNT" >> "$LOG_FILE"

echo "$(date '+%Y-%m-%d %H:%M:%S'): 同步完成" >> "$LOG_FILE"
echo "✅ Cascade 同步完成！當前有 $SKILL_COUNT 個技能"
EOF

    chmod +x ~/.gemini/cascade/sync/cascade_sync.sh
    
    log_success "同步腳本創建完成"
}

# 設定每日同步
setup_daily_sync() {
    log_info "設定每日自動同步..."
    
    # 檢查是否已存在Cascade的cron任務
    if ! crontab -l 2>/dev/null | grep -q "cascade_sync.sh"; then
        (crontab -l 2>/dev/null; echo "0 8 * * * $HOME/.gemini/cascade/sync/cascade_sync.sh") | crontab -
        log_success "每日同步設定完成 (每天早上8點)"
    else
        log_info "每日同步已存在"
    fi
}

# 安裝VS Code擴充
install_vscode_extensions() {
    log_info "安裝VS Code擴充..."
    
    if command_exists code; then
        local extensions=(
            "ms-python.python"
            "ms-python.vscode-pylance"
            "ms-python.black-formatter"
            "ms-python.debugpy"
            "ms-vscode.cpptools"
            "ms-azuretools.vscode-docker"
            "github.copilot"
            "github.copilot-chat"
            "ms-vscode-remote.remote-wsl"
            "eamodio.gitlens"
            "ms-vscode.hexeditor"
            "redhat.vscode-yaml"
            "ms-vscode.vscode-json"
            "bradlc.vscode-tailwindcss"
            "esbenp.prettier-vscode"
            "dbaeumer.vscode-eslint"
        )
        
        local installed=0
        local total=${#extensions[@]}
        
        for ext in "${extensions[@]}"; do
            if code --install-extension "$ext" --force >/dev/null 2>&1; then
                installed=$((installed + 1))
                printf "\r📦 安裝擴充進度: [%d/%d]" $installed $total
            else
                printf "\r⚠️ 擴充安裝失敗: %s" $ext
            fi
        done
        
        echo ""
        log_success "VS Code擴充安裝完成 ($installed/$total)"
    else
        log_warning "VS Code未安裝，跳過擴充安裝"
    fi
}

# 設定MCP配置
setup_mcp_config() {
    log_info "設定MCP配置..."
    
    mkdir -p ~/.gemini/antigravity
    
    cat > ~/.gemini/antigravity/mcp_config.json << 'EOF'
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/home"],
      "env": {}
    },
    "fetch": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-fetch"],
      "env": {}
    },
    "python": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-python"],
      "env": {"PYTHONPATH": "./src"}
    },
    "postgres": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-postgres"],
      "env": {"DATABASE_URL": "postgresql://localhost/db"}
    },
    "redis": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-redis"],
      "env": {"REDIS_URL": "redis://localhost:6379"}
    }
  }
}
EOF

    log_success "MCP配置完成"
}

# 創建快捷指令
create_aliases() {
    log_info "創建快捷指令..."
    
    # 檢測shell類型
    local shell_config=""
    if [ -n "$BASH_VERSION" ]; then
        shell_config="$HOME/.bashrc"
    elif [ -n "$ZSH_VERSION" ]; then
        shell_config="$HOME/.zshrc"
    else
        shell_config="$HOME/.profile"
    fi
    
    # 備份現有配置
    if [ -f "$shell_config" ]; then
        cp "$shell_config" "$shell_config.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # 移除舊的Cascade別名
    sed -i '/# Cascade AI Assistant 別名/,/# Cascade AI Assistant 別名 end/d' "$shell_config" 2>/dev/null || true
    
    # 添加新別名
    cat >> "$shell_config" << 'EOF'

# Cascade AI Assistant 別名
alias cascade-sync='~/.gemini/cascade/sync/cascade_sync.sh'
alias cascade-status='cd ~/.gemini/cascade && git status'
alias cascade-log='tail -f ~/.gemini/cascade/evolution/logs/sync.log'
alias cascade-skills='ls ~/.gemini/cascade/skills/'
alias cascade-config='nano ~/.gemini/cascade/core/CASCADE_CORE.md'
# Cascade AI Assistant 別名 end
EOF

    log_success "快捷指令創建完成"
}

# 初始提交
initial_commit() {
    log_info "執行初始提交..."
    
    cd ~/.gemini/cascade
    
    git add .
    
    if ! git diff --cached --quiet; then
        git commit -m "Cascade: 初始安裝完成

✅ 建立完整目錄結構
✅ 創建核心規範文件
✅ 創建專案偵測技能
✅ 創建MCP整合技能
✅ 設定同步機制
✅ 配置開發環境

Cascade AI Assistant 準備就緒！" >/dev/null 2>&1
        
        log_success "初始提交完成"
    fi
}

# 驗證安裝
verify_installation() {
    log_info "驗證安裝..."
    
    local errors=0
    
    # 檢查目錄
    if [ ! -d "$HOME/.gemini/cascade" ]; then
        log_error "Cascade目錄不存在"
        errors=$((errors + 1))
    fi
    
    # 檢查核心文件
    if [ ! -f "$HOME/.gemini/cascade/core/CASCADE_CORE.md" ]; then
        log_error "核心規範文件不存在"
        errors=$((errors + 1))
    fi
    
    # 檢查同步腳本
    if [ ! -f "$HOME/.gemini/cascade/sync/cascade_sync.sh" ]; then
        log_error "同步腳本不存在"
        errors=$((errors + 1))
    fi
    
    # 檢查技能文件
    local skill_count=$(find "$HOME/.gemini/cascade/skills" -name "*.md" 2>/dev/null | wc -l)
    if [ "$skill_count" -eq 0 ]; then
        log_error "沒有找到技能文件"
        errors=$((errors + 1))
    fi
    
    # 檢查MCP配置
    if [ ! -f "$HOME/.gemini/antigravity/mcp_config.json" ]; then
        log_error "MCP配置不存在"
        errors=$((errors + 1))
    fi
    
    if [ $errors -eq 0 ]; then
        log_success "安裝驗證通過"
        return 0
    else
        log_error "安裝驗證失敗，發現 $errors 個錯誤"
        return 1
    fi
}

# 完成訊息
completion_message() {
    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                    🎉 安裝完成！                            ║${NC}"
    echo -e "${GREEN}║                                                              ║${NC}"
    echo -e "${GREEN}║  Cascade AI Assistant 已成功安裝到您的系統中                 ║${NC}"
    echo -e "${GREEN}║                                                              ║${NC}"
    echo -e "${GREEN}║  📋 後續步驟：                                               ║${NC}"
    echo -e "${GREEN}║  1. 重新載入終端機: source ~/.bashrc                          ║${NC}"
    echo -e "${GREEN}║  2. 執行首次同步: cascade-sync                               ║${NC}"
    echo -e "${GREEN}║  3. 檢查系統狀態: cascade-status                              ║${NC}"
    echo -e "${GREEN}║  4. 查看可用技能: cascade-skills                              ║${NC}"
    echo -e "${GREEN}║                                                              ║${NC}"
    echo -e "${GREEN}║  🚀 現在您可以在任何地方使用 Cascade AI Assistant！           ║${NC}"
    echo -e "${GREEN}║                                                              ║${NC}"
    echo -e "${GREEN}║  💡 提示: 每天早上8點會自動同步最新知識                       ║${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# 主要安裝流程
main() {
    welcome
    
    # 顯示安裝進度
    show_progress 2 10
    
    system_check
    show_progress 2 10
    
    install_system_deps
    show_progress 2 10
    
    create_cascade_structure
    show_progress 1 10
    
    setup_git_config
    show_progress 1 10
    
    setup_cascade_repo
    show_progress 1 10
    
    create_core_files
    show_progress 1 10
    
    create_skill_files
    show_progress 1 10
    
    create_sync_script
    show_progress 1 10
    
    setup_daily_sync
    show_progress 1 10
    
    install_vscode_extensions
    show_progress 1 10
    
    setup_mcp_config
    show_progress 1 10
    
    create_aliases
    show_progress 1 10
    
    initial_commit
    
    if verify_installation; then
        completion_message
        
        # 執行首次同步
        echo ""
        log_info "執行首次同步..."
        if ~/.gemini/cascade/sync/cascade_sync.sh; then
            log_success "首次同步完成"
        else
            log_warning "首次同步失敗，您可以稍後手動執行 cascade-sync"
        fi
    else
        echo ""
        log_error "安裝過程中出現問題，請檢查上述錯誤訊息"
        exit 1
    fi
}

# 執行主程序
main "$@"
