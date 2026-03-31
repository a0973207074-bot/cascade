#!/bin/bash
# Cascade AI Assistant - 一鍵跨設備部署腳本

set -e

echo "🚀 Cascade AI Assistant 跨設備部署開始..."

# 檢測作業系統
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

# 安裝基本依賴
install_dependencies() {
    local os=$(detect_os)
    echo "📦 檢測到作業系統: $os"
    
    case $os in
        "linux")
            if command -v apt &> /dev/null; then
                sudo apt update
                sudo apt install -y git curl python3 python3-pip
            elif command -v yum &> /dev/null; then
                sudo yum install -y git curl python3 python3-pip
            fi
            ;;
        "macos")
            if command -v brew &> /dev/null; then
                brew install git curl python3
            else
                echo "❌ 請先安裝Homebrew: https://brew.sh/"
                exit 1
            fi
            ;;
        "windows")
            echo "⚠️ Windows請使用WSL環境"
            exit 1
            ;;
    esac
}

# 安裝VS Code
install_vscode() {
    if ! command -v code &> /dev/null; then
        local os=$(detect_os)
        echo "🔧 安裝VS Code..."
        
        case $os in
            "linux")
                if command -v snap &> /dev/null; then
                    sudo snap install --classic code
                elif command -v apt &> /dev/null; then
                    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
                    sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
                    sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
                    sudo apt update
                    sudo apt install -y code
                fi
                ;;
            "macos")
                brew install --cask visual-studio-code
                ;;
        esac
    fi
}

# 建立目錄結構
create_directories() {
    echo "📁 建立Cascade目錄結構..."
    mkdir -p ~/.gemini/cascade/{core,skills,memory,evolution,sync,config}
    mkdir -p ~/.gemini/antigravity
}

# 設定Git配置
setup_git() {
    echo "⚙️ 設定Git配置..."
    git config --global user.email "cascade@ai.assistant"
    git config --global user.name "Cascade AI"
}

# 克隆Cascade倉庫
clone_cascade() {
    echo "📥 下載Cascade核心..."
    cd ~/.gemini/cascade
    
    if [ ! -d ".git" ]; then
        # 嘗試從GitHub克隆
        if git clone https://github.com/a0973207074-bot/cascade-ai.git . 2>/dev/null; then
            echo "✅ 從GitHub下載成功"
        else
            echo "⚠️ 無法從GitHub下載，建立本地倉庫..."
            git init
            git remote add origin https://github.com/a0973207074-bot/cascade-ai.git
        fi
    fi
}

# 同步最新知識
sync_knowledge() {
    echo "🔄 同步最新知識..."
    cd ~/.gemini/cascade
    
    # 嘗試從遠端同步
    if git pull origin main 2>/dev/null; then
        echo "✅ 知識同步成功"
    else
        echo "⚠️ 無法從遠端同步，使用本地知識庫"
    fi
}

# 設定每日同步
setup_cron() {
    echo "⏰ 設定每日同步..."
    (crontab -l 2>/dev/null | grep -v cascade; echo "0 8 * * * ~/.gemini/cascade/sync/cascade_sync.sh") | crontab -
}

# 安裝VS Code擴充
install_extensions() {
    echo "🔧 安裝VS Code擴充..."
    
    if command -v code &> /dev/null; then
        # 基本擴充清單
        extensions=(
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
        )
        
        for ext in "${extensions[@]}"; do
            code --install-extension "$ext" 2>/dev/null || echo "⚠️ 無法安裝 $ext"
        done
    fi
}

# 設定MCP配置
setup_mcp() {
    echo "🔌 設定MCP配置..."
    
    # 建立基本MCP配置
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
    }
  }
}
EOF
}

# 建立快捷指令
create_aliases() {
    echo "⚡ 建立快捷指令..."
    
    # 檢查shell類型
    if [ -n "$BASH_VERSION" ]; then
        shell_config="$HOME/.bashrc"
    elif [ -n "$ZSH_VERSION" ]; then
        shell_config="$HOME/.zshrc"
    else
        shell_config="$HOME/.profile"
    fi
    
    # 添加別名
    {
        echo "# Cascade AI Assistant 別名"
        echo "alias cascade-sync='~/.gemini/cascade/sync/cascade_sync.sh'"
        echo "alias cascade-status='cd ~/.gemini/cascade && git status'"
        echo "alias cascade-log='tail -f ~/.gemini/cascade/evolution/evolution.log'"
        echo "alias cascade-skills='ls ~/.gemini/cascade/skills/'"
    } >> "$shell_config"
}

# 建立同步腳本
create_sync_script() {
    echo "📝 建立同步腳本..."
    
    cat > ~/.gemini/cascade/sync/cascade_sync.sh << 'EOF'
#!/bin/bash
set -e

CASCADE_HOME="$HOME/.gemini/cascade"
echo "🚀 Cascade AI Assistant - 自主同步開始..."

cd "$CASCADE_HOME"

# 備份核心規則
cp core/CASCADE_CORE.md CASCADE_CORE.md 2>/dev/null || true

# 提交變更
git add .
if ! git diff --cached --quiet; then
    TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
    git commit -m "Cascade: 自主進化更新 at $TIMESTAMP" > /dev/null
    echo "📝 已提交進化更新"
fi

# 雲端同步
git pull --rebase origin main 2>/dev/null || echo "首次同步，建立遠端連接"
git push origin main 2>/dev/null || echo "建立遠端倉庫"

# 更新核心規則
[ -f CASCADE_CORE.md ] && cp CASCADE_CORE.md core/CASCADE_CORE.md

# 記錄進化日誌
mkdir -p evolution
echo "$(date): Cascade 自主同步完成" >> evolution/evolution.log

echo "✅ Cascade 同步完成！準備下一輪進化。"
EOF

    chmod +x ~/.gemini/cascade/sync/cascade_sync.sh
}

# 驗證安裝
verify_installation() {
    echo "🔍 驗證安裝..."
    
    # 檢查目錄
    if [ -d "$HOME/.gemini/cascade" ]; then
        echo "✅ Cascade目錄已建立"
    else
        echo "❌ Cascade目錄建立失敗"
        return 1
    fi
    
    # 檢查Git倉庫
    if [ -d "$HOME/.gemini/cascade/.git" ]; then
        echo "✅ Git倉庫已建立"
    else
        echo "⚠️ Git倉庫建立失敗"
    fi
    
    # 檢查同步腳本
    if [ -f "$HOME/.gemini/cascade/sync/cascade_sync.sh" ]; then
        echo "✅ 同步腳本已建立"
    else
        echo "❌ 同步腳本建立失敗"
        return 1
    fi
    
    # 檢查技能數量
    skill_count=$(find "$HOME/.gemini/cascade/skills" -name "*.md" | wc -l)
    echo "📚 已載入 $skill_count 個技能"
    
    return 0
}

# 主要安裝流程
main() {
    echo "🎯 開始安裝 Cascade AI Assistant..."
    
    install_dependencies
    install_vscode
    create_directories
    setup_git
    clone_cascade
    sync_knowledge
    setup_cron
    install_extensions
    setup_mcp
    create_aliases
    create_sync_script
    
    if verify_installation; then
        echo ""
        echo "🎉 Cascade AI Assistant 安裝完成！"
        echo ""
        echo "📋 後續步驟："
        echo "1. 重新載入終端機或執行: source ~/.bashrc"
        echo "2. 執行首次同步: cascade-sync"
        echo "3. 檢查狀態: cascade-status"
        echo "4. 查看技能: cascade-skills"
        echo ""
        echo "🚀 現在你可以在任何地方使用 Cascade AI Assistant！"
    else
        echo "❌ 安裝過程中出現問題，請檢查日誌"
        exit 1
    fi
}

# 執行主程序
main "$@"
