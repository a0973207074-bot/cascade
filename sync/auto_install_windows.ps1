# Cascade AI Assistant - Windows 自動安裝腳本
# 使用方式: 
# 1. 在PowerShell中執行: Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
# 2. 然後執行: irm https://raw.githubusercontent.com/a0973207074-bot/cascade-ai/main/auto_install_windows.ps1 | iex

# 設定執行策略
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# 顏色輸出函數
function Write-ColorOutput {
    param(
        [string]$Message,
        [ConsoleColor]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Write-Success {
    param([string]$Message)
    Write-ColorOutput "[SUCCESS] $Message" "Green"
}

function Write-Info {
    param([string]$Message)
    Write-ColorOutput "[INFO] $Message" "Cyan"
}

function Write-Warning {
    param([string]$Message)
    Write-ColorOutput "[WARNING] $Message" "Yellow"
}

function Write-Error {
    param([string]$Message)
    Write-ColorOutput "[ERROR] $Message" "Red"
}

# 歡迎訊息
function Show-Welcome {
    Clear-Host
    Write-ColorOutput @"
╔══════════════════════════════════════════════════════════════╗
║                    Cascade AI Assistant                      ║
║                   Windows 自動安裝程序                        ║
║                                                              ║
║  這將為您安裝完整的 Cascade AI Assistant 系統               ║
║  包括WSL環境、所有技能、MCP配置等                            ║
╚══════════════════════════════════════════════════════════════╝
"@ "Blue"
    Write-Host ""
    Write-Info "開始安裝 Cascade AI Assistant for Windows..."
    Write-Host ""
}

# 檢查管理員權限
function Test-AdminRights {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# 進度條
function Show-Progress {
    param(
        [int]$Duration,
        [int]$Steps,
        [string]$Activity = "安裝進程"
    )
    
    for ($i = 1; $i -le $Steps; $i++) {
        $percent = [math]::Round(($i / $Steps) * 100)
        $bar = "█" * [math]::Floor($percent / 2)
        Write-Progress -Activity $Activity -Status "[$bar] $percent%" -PercentComplete $percent
        Start-Sleep -Milliseconds ($Duration * 1000 / $Steps)
    }
    Write-Progress -Activity $Activity -Completed
}

# 系統檢查
function Test-System {
    Write-Info "檢查Windows系統環境..."
    
    # 檢查Windows版本
    $windowsVersion = [System.Environment]::OSVersion.Version
    Write-Info "Windows版本: $($windowsVersion.Major).$($windowsVersion.Minor)"
    
    # 檢查網路連接
    try {
        $response = Invoke-WebRequest -Uri "https://github.com" -TimeoutSec 5 -UseBasicParsing
        Write-Success "網路連接正常"
    }
    catch {
        Write-Error "無法連接到GitHub，請檢查網路連接"
        exit 1
    }
    
    # 檢查磁碟空間
    $drive = Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DeviceID -eq "C:" }
    $freeSpaceGB = [math]::Round($drive.FreeSpace / 1GB, 2)
    Write-Info "C:可用空間: $freeSpaceGB GB"
    
    if ($freeSpaceGB -lt 2) {
        Write-Warning "磁碟空間不足，建議至少有2GB可用空間"
    }
    
    Write-Success "系統檢查通過"
}

# 安裝WSL
function Install-WSL {
    Write-Info "檢查並安裝WSL..."
    
    # 檢查WSL是否已安裝
    try {
        $wslVersion = wsl --version
        Write-Success "WSL已安裝: $($wslVersion[0])"
        return
    }
    catch {
        Write-Info "WSL未安裝，開始安裝..."
    }
    
    # 啟用WSL功能
    Write-Info "啟用WSL功能..."
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
    Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
    
    # 下載WSL更新包
    Write-Info "下載WSL更新包..."
    $wslUpdateUrl = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
    $wslUpdatePath = "$env:TEMP\wsl_update_x64.msi"
    
    try {
        Invoke-WebRequest -Uri $wslUpdateUrl -OutFile $wslUpdatePath
        Start-Process msiexec.exe -ArgumentList "/i `"$wslUpdatePath`" /quiet" -Wait
        Remove-Item $wslUpdatePath
        Write-Success "WSL更新包安裝完成"
    }
    catch {
        Write-Warning "WSL更新包下載失敗，將繼續安裝"
    }
    
    # 設定WSL預設版本為2
    Write-Info "設定WSL預設版本為2..."
    wsl --set-default-version 2
    
    Write-Success "WSL安裝完成"
    Write-Warning "需要重新啟動電腦以完成WSL安裝"
    Write-Warning "請重新啟動後重新執行此腳本"
    
    # 詢問是否重新啟動
    $restart = Read-Host "是否立即重新啟動電腦？(y/N)"
    if ($restart -eq "y" -or $restart -eq "Y") {
        Restart-Computer -Force
    }
    else {
        exit 0
    }
}

# 安裝Ubuntu
function Install-Ubuntu {
    Write-Info "檢查並安裝Ubuntu..."
    
    # 檢查是否已有Linux發行版
    try {
        $distributions = wsl --list --quiet
        if ($distributions -match "Ubuntu") {
            Write-Success "Ubuntu已安裝"
            return
        }
    }
    catch {
        Write-Info "未找到Linux發行版"
    }
    
    Write-Info "從Microsoft Store安裝Ubuntu..."
    Write-Info "請手動從Microsoft Store安裝Ubuntu 22.04 LTS"
    Write-Info "安裝完成後，請重新執行此腳本"
    
    # 嘗試自動打開Microsoft Store
    try {
        Start-Process "ms-windows-store://pdp/?productid=9N9TNGVNDX3G"
    }
    catch {
        Write-Warning "無法自動打開Microsoft Store"
    }
    
    Write-Warning "安裝Ubuntu後需要重新啟動並重新執行此腳本"
    exit 0
}

# 在WSL中安裝Cascade
function Install-CascadeInWSL {
    Write-Info "在WSL中安裝Cascade AI Assistant..."
    
    $wslCommands = @'
# 更新套件庫
sudo apt update && sudo apt upgrade -y

# 安裝基本依賴
sudo apt install -y git curl python3 python3-pip build-essential

# 安裝VS Code Server
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
sudo apt update
sudo apt install -y code

# 建立Cascade目錄
mkdir -p ~/.gemini/cascade/{core,skills,memory,evolution,sync,config}
mkdir -p ~/.gemini/antigravity

# 設定Git配置
git config --global user.email "cascade@ai.assistant"
git config --global user.name "Cascade AI"

# 初始化Git倉庫
cd ~/.gemini/cascade
git init
git remote add origin https://github.com/a0973207074-bot/cascade-ai.git 2>/dev/null || true

# 創建核心文件
cat > core/CASCADE_CORE.md << 'EOF'
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

# 創建技能文件
mkdir -p skills/{project_detection,mcp_integration}

cat > skills/project_detection/SKILL.md << 'EOF'
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

---
**讓我為你的每個專案找到最完美的技能組合！**
EOF

cat > skills/mcp_integration/SKILL.md << 'EOF'
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

---
**讓我為你的專案配置最完美的MCP工具擴展！**
EOF

# 創建同步腳本
cat > sync/cascade_sync.sh << 'EOF'
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
    git commit -m "Cascade: 自主進化更新 at $TIMESTAMP" > /dev/null 2>&1
    echo "📝 提交進化更新"
fi

# 雲端同步
git pull --rebase origin main 2>/dev/null || echo "首次同步"
git push origin main 2>/dev/null || echo "建立遠端倉庫"

# 恢復核心規則
[ -f CASCADE_CORE.md ] && cp CASCADE_CORE.md core/CASCADE_CORE.md

echo "✅ Cascade 同步完成！"
EOF

chmod +x sync/cascade_sync.sh

# 設定每日同步
(crontab -l 2>/dev/null; echo "0 8 * * * ~/.gemini/cascade/sync/cascade_sync.sh") | crontab -

# 創建MCP配置
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

# 初始提交
git add .
git commit -m "Cascade: Windows WSL 初始安裝完成

✅ WSL環境建立
✅ 基本依賴安裝
✅ VS Code Server安裝
✅ Cascade核心系統建立
✅ 技能系統部署
✅ 同步機制設定

Cascade AI Assistant 準備就緒！" 2>/dev/null || true

echo "✅ Cascade AI Assistant 在WSL中安裝完成！"
'@
    
    try {
        Write-Info "在WSL中執行安裝命令..."
        $result = wsl bash -c $wslCommands
        Write-Success "WSL安裝完成"
    }
    catch {
        Write-Error "WSL安裝失敗: $($_.Exception.Message)"
        exit 1
    }
}

# 創建Windows快捷方式
function Create-Shortcuts {
    Write-Info "創建Windows快捷方式..."
    
    $desktopPath = [Environment]::GetFolderPath("Desktop")
    $cascadeWSL = @"
@echo off
wsl bash -c "cd ~/.gemini/cascade && ./sync/cascade_sync.sh"
pause
"@
    
    $cascadeStatus = @"
@echo off
wsl bash -c "cd ~/.gemini/cascade && git status"
pause
"@
    
    $cascadeSkills = @"
@echo off
wsl bash -c "ls ~/.gemini/cascade/skills/"
pause
"@
    
    # 創建批次檔
    $cascadeWSL | Out-File -FilePath "$env:USERPROFILE\Cascade_Sync.bat" -Encoding ASCII
    $cascadeStatus | Out-File -FilePath "$env:USERPROFILE\Cascade_Status.bat" -Encoding ASCII
    $cascadeSkills | Out-File -FilePath "$env:USERPROFILE\Cascade_Skills.bat" -Encoding ASCII
    
    Write-Success "快捷方式創建完成"
    Write-Info "批次檔位置:"
    Write-Info "  - Cascade_Sync.bat: 執行同步"
    Write-Info "  - Cascade_Status.bat: 查看狀態"
    Write-Info "  - Cascade_Skills.bat: 查看技能"
}

# 創建PowerShell別名
function Create-PowerShellAliases {
    Write-Info "創建PowerShell別名..."
    
    $profilePath = $PROFILE.CurrentUserCurrentHost
    
    # 備份現有profile
    if (Test-Path $profilePath) {
        Copy-Item $profilePath "$profilePath.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    }
    
    # 添加Cascade別名
    $cascadeAliases = @"

# Cascade AI Assistant 別名
function Invoke-CascadeSync { wsl bash -c "cd ~/.gemini/cascade && ./sync/cascade_sync.sh" }
function Invoke-CascadeStatus { wsl bash -c "cd ~/.gemini/cascade && git status" }
function Invoke-CascadeSkills { wsl bash -c "ls ~/.gemini/cascade/skills/" }
function Invoke-CascadeLog { wsl bash -c "tail -f ~/.gemini/cascade/evolution/logs/sync.log" }

# Set aliases
Set-Alias -Name cascade-sync -Value Invoke-CascadeSync
Set-Alias -Name cascade-status -Value Invoke-CascadeStatus
Set-Alias -Name cascade-skills -Value Invoke-CascadeSkills
Set-Alias -Name cascade-log -Value Invoke-CascadeLog
"@
    
    Add-Content -Path $profilePath -Value $cascadeAliases
    
    Write-Success "PowerShell別名創建完成"
    Write-Info "請重新啟動PowerShell以載入別名"
}

# 驗證安裝
function Test-Installation {
    Write-Info "驗證安裝..."
    
    try {
        # 測試WSL
        $wslTest = wsl --version
        Write-Success "WSL運行正常"
    }
    catch {
        Write-Error "WSL測試失敗"
        return $false
    }
    
    try {
        # 測試Cascade目錄
        $cascadeTest = wsl bash -c "test -d ~/.gemini/cascade && echo 'Cascade目錄存在'"
        if ($cascadeTest -eq "Cascade目錄存在") {
            Write-Success "Cascade目錄存在"
        } else {
            Write-Error "Cascade目錄不存在"
            return $false
        }
    }
    catch {
        Write-Error "Cascade目錄測試失敗"
        return $false
    }
    
    try {
        # 測試同步腳本
        $syncTest = wsl bash -c "test -f ~/.gemini/cascade/sync/cascade_sync.sh && echo '同步腳本存在'"
        if ($syncTest -eq "同步腳本存在") {
            Write-Success "同步腳本存在"
        } else {
            Write-Error "同步腳本不存在"
            return $false
        }
    }
    catch {
        Write-Error "同步腳本測試失敗"
        return $false
    }
    
    return $true
}

# 完成訊息
function Show-Completion {
    Write-Host ""
    Write-ColorOutput @"
╔══════════════════════════════════════════════════════════════╗
║                    🎉 Windows安裝完成！                     ║
║                                                              ║
║  Cascade AI Assistant 已成功安裝到您的WSL環境中             ║
║                                                              ║
║  📋 使用方式：                                               ║
║  1. PowerShell中執行: cascade-sync                          ║
║  2. 或雙擊: Cascade_Sync.bat                               ║
║  3. 查看狀態: cascade-status                                ║
║  4. 查看技能: cascade-skills                                ║
║                                                              ║
║  🚀 現在您可以在Windows中使用Cascade AI Assistant！          ║
║                                                              ║
║  💡 提示:                                                   ║
║  - 所有操作都在WSL Ubuntu環境中執行                        ║
║  - 每天早上8點會自動同步最新知識                           ║
║  - 可以直接在Windows中使用PowerShell指令                    ║
╚══════════════════════════════════════════════════════════════╝
"@ "Green"
    Write-Host ""
}

# 主要安裝流程
function Main {
    Show-Welcome
    
    # 顯示安裝進度
    Show-Progress -Duration 2 -Steps 10 -Activity "系統檢查"
    Test-System
    
    Show-Progress -Duration 2 -Steps 10 -Activity "檢查WSL"
    Install-WSL
    
    Show-Progress -Duration 2 -Steps 10 -Activity "檢查Ubuntu"
    Install-Ubuntu
    
    Show-Progress -Duration 5 -Steps 10 -Activity "安裝Cascade"
    Install-CascadeInWSL
    
    Show-Progress -Duration 1 -Steps 10 -Activity "創建快捷方式"
    Create-Shortcuts
    
    Show-Progress -Duration 1 -Steps 10 -Activity "設定PowerShell"
    Create-PowerShellAliases
    
    if (Test-Installation) {
        Show-Completion
    } else {
        Write-Error "安裝驗證失敗"
        exit 1
    }
}

# 執行主程序
try {
    Main
}
catch {
    Write-Error "安裝過程中發生錯誤: $($_.Exception.Message)"
    Write-Host ""
    Write-Info "請檢查:"
    Write-Info "1. 是否以管理員權限執行"
    Write-Info "2. 網路連接是否正常"
    Write-Info "3. Windows版本是否支援WSL2"
    exit 1
}
