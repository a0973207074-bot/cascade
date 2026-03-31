# Cascade AI Assistant - 純Windows原生安裝
# 不需要WSL/Ubuntu，直接在Windows上運行

param(
    [switch]$Force
)

# 顏色輸出
function Write-ColorOutput {
    param([string]$Message, [ConsoleColor]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Write-Success { param([string]$Message) Write-ColorOutput "[SUCCESS] $Message" "Green" }
function Write-Info { param([string]$Message) Write-ColorOutput "[INFO] $Message" "Cyan" }
function Write-Warning { param([string]$Message) Write-ColorOutput "[WARNING] $Message" "Yellow" }
function Write-Error { param([string]$Message) Write-ColorOutput "[ERROR] $Message" "Red" }

# 歡迎訊息
Clear-Host
Write-ColorOutput @"
╔══════════════════════════════════════════════════════════════╗
║                    Cascade AI Assistant                      ║
║                   純Windows原生安裝                         ║
║                                                              ║
║  不需要WSL/Ubuntu，直接在Windows上運行                       ║
╚══════════════════════════════════════════════════════════════╝
"@ "Blue"

# 檢查管理員權限
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Error "需要管理員權限，請以管理員身份執行"
    pause
    exit 1
}

# 檢查PowerShell版本
if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Error "需要PowerShell 5.0或更高版本"
    exit 1
}

Write-Info "開始純Windows原生安裝 Cascade AI Assistant..."

# 創建Cascade目錄
$cascadePath = "$env:USERPROFILE\.gemini\cascade"
Write-Info "創建Cascade目錄: $cascadePath"

if (Test-Path $cascadePath) {
    if (-not $Force) {
        $continue = Read-Host "Cascade目錄已存在，是否繼續？(y/N)"
        if ($continue -ne "y" -and $continue -ne "Y") {
            Write-Info "安裝已取消"
            exit 0
        }
    }
} else {
    New-Item -ItemType Directory -Path $cascadePath -Force | Out-Null
}

# 創建子目錄
$subdirs = @("core", "skills", "memory", "evolution", "sync", "config")
foreach ($subdir in $subdirs) {
    New-Item -ItemType Directory -Path "$cascadePath\$subdir" -Force | Out-Null
}

# 創建技能目錄
New-Item -ItemType Directory -Path "$cascadePath\skills\project_detection" -Force | Out-Null
New-Item -ItemType Directory -Path "$cascadePath\skills\mcp_integration" -Force | Out-Null

# 創建核心文件
Write-Info "創建核心文件..."
$coreContent = @"
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

## 🪟 Windows原生支援
- **PowerShell腳本**: 完整的Windows腳本系統
- **Windows任務計劃器**: 自動同步機制
- **檔案系統整合**: 原生Windows檔案操作
- **註冊表整合**: 系統設定管理

---
**Cascade - 你的全能AI助理，每個專案的完美夥伴**
"@

$coreContent | Out-File -FilePath "$cascadePath\core\CASCADE_CORE.md" -Encoding UTF8

# 創建專案偵測技能
$projectDetectionContent = @"
---
name: project-detection
description: "專案類型自動偵測系統。分析專案結構、檔案類型、依賴關係，自動識別專案類型並匹配對應技能與MCP伺服器。"
risk: low
source: cascade-core
date_added: "2026-03-31"
---

# Project Detection - 專案偵測系統 (Windows版)

自動分析你的專案，智能匹配最適合的技能與工具。

## 🎯 Windows檔案偵測

### PowerShell偵測腳本
```powershell
function Detect-ProjectType {
    param([string]$Path = ".")
    
    $indicators = @{
        'package.json' = 'frontend/nodejs'
        'requirements.txt' = 'python'
        'Cargo.toml' = 'rust'
        'go.mod' = 'golang'
        'pom.xml' = 'java/maven'
        'CMakeLists.txt' = 'cpp/cmake'
        'setup.py' = 'python/package'
        'Dockerfile' = 'containerized'
        'docker-compose.yml' = 'multi-container'
        'package.xml' = 'ros2'
        '.sln' = 'csharp/dotnet'
        '.csproj' = 'csharp/dotnet'
        'Gemfile' = 'ruby'
        'composer.json' = 'php'
    }
    
    $detectedTypes = @()
    
    foreach ($file in $indicators.Keys) {
        if (Test-Path (Join-Path $Path $file)) {
            $detectedTypes += $indicators[$file]
        }
    }
    
    return $detectedTypes
}
```

---
**讓我為你的每個專案找到最完美的技能組合！**
"@

$projectDetectionContent | Out-File -FilePath "$cascadePath\skills\project_detection\SKILL.md" -Encoding UTF8

# 創建MCP整合技能
$mcpIntegrationContent = @"
---
name: mcp-integration
description: "Model Context Protocol整合系統。智能選擇、配置、管理MCP伺服器，擴展AI助理的能力邊界。"
risk: low
source: cascade-core
date_added: "2026-03-31"
---

# MCP Integration - MCP整合系統 (Windows版)

智能管理Model Context Protocol伺服器，為每個專案提供最適配的工具擴展。

## 🎯 Windows MCP配置

### PowerShell MCP配置
```powershell
function New-MCPConfig {
    param([string]$ConfigPath = "$env:USERPROFILE\.gemini\antigravity\mcp_config.json")
    
    $config = @{
        mcpServers = @{
            filesystem = @{
                command = "npx"
                args = @("-y", "@modelcontextprotocol/server-filesystem", $env:USERPROFILE)
                env = @{}
            }
            fetch = @{
                command = "npx"
                args = @("-y", "@modelcontextprotocol/server-fetch")
                env = @{}
            }
            powershell = @{
                command = "pwsh"
                args = @("-Command", "Invoke-MCPServer")
                env = @{
                    POWERSHELL_TELEMETRY_OPTOUT = "1"
                }
            }
        }
    }
    
    $config | ConvertTo-Json -Depth 3 | Out-File -FilePath $ConfigPath -Encoding UTF8
}
```

---
**讓我為你的專案配置最完美的MCP工具擴展！**
"@

$mcpIntegrationContent | Out-File -FilePath "$cascadePath\skills\mcp_integration\SKILL.md" -Encoding UTF8

# 創建Windows同步腳本
$syncScriptContent = @"
# Cascade AI Assistant - Windows同步腳本

param(
    [switch]$Force
)

`$cascadePath = "`$env:USERPROFILE\.gemini\cascade"
`$logPath = "`$cascadePath\evolution\logs\sync.log"

Write-Host "🚀 Cascade AI Assistant - Windows同步開始..." -ForegroundColor Green

# 確保日誌目錄存在
New-Item -ItemType Directory -Path (Split-Path `$logPath) -Force | Out-Null

# 記錄開始時間
"$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): 開始同步" | Out-File -FilePath `$logPath -Append

# 備份核心規則
if (Test-Path "`$cascadePath\core\CASCADE_CORE.md") {
    Copy-Item "`$cascadePath\core\CASCADE_CORE.md" "`$cascadePath\CASCADE_CORE.md" -Force
    "📦 備份核心規則完成" | Out-File -FilePath `$logPath -Append
}

# 檢查Git變更
Set-Location `$cascadePath
`$status = git status --porcelain

if (`$status) {
    `$timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    git add .
    git commit -m "Cascade: Windows自動更新 at `$timestamp" 2>`$null
    "📝 提交變更: `$timestamp" | Out-File -FilePath `$logPath -Append
} else {
    "ℹ️ 沒有變更需要提交" | Out-File -FilePath `$logPath -Append
}

# 雲端同步
try {
    git pull origin main 2>`$null
    "⬇️ 從雲端拉取成功" | Out-File -FilePath `$logPath -Append
} catch {
    "⚠️ 從雲端拉取失敗: `$_" | Out-File -FilePath `$logPath -Append
}

try {
    git push origin main 2>`$null
    "🚀 推送到雲端成功" | Out-File -FilePath `$logPath -Append
} catch {
    "⚠️ 推送到雲端失敗: `$_" | Out-File -FilePath `$logPath -Append
}

# 恢復核心規則
if (Test-Path "`$cascadePath\CASCADE_CORE.md") {
    Copy-Item "`$cascadePath\CASCADE_CORE.md" "`$cascadePath\core\CASCADE_CORE.md" -Force
}

# 統計技能數量
`$skillCount = (Get-ChildItem "`$cascadePath\skills" -Recurse -Filter "*.md").Count
"📚 當前技能數量: `$skillCount" | Out-File -FilePath `$logPath -Append

"$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'): 同步完成" | Out-File -FilePath `$logPath -Append
Write-Host "✅ Cascade Windows同步完成！當前有 `$skillCount 個技能" -ForegroundColor Green
"@

$syncScriptContent | Out-File -FilePath "$cascadePath\sync\cascade_sync_windows.ps1" -Encoding UTF8

# 創建MCP配置
$antigravityPath = "$env:USERPROFILE\.gemini\antigravity"
New-Item -ItemType Directory -Path $antigravityPath -Force | Out-Null

$mcpConfig = @{
    mcpServers = @{
        filesystem = @{
            command = "npx"
            args = @("-y", "@modelcontextprotocol/server-filesystem", $env:USERPROFILE)
            env = @{}
        }
        fetch = @{
            command = "npx"
            args = @("-y", "@modelcontextprotocol/server-fetch")
            env = @{}
        }
        powershell = @{
            command = "pwsh"
            args = @("-Command", "Start-MCPServer")
            env = @{
                POWERSHELL_TELEMETRY_OPTOUT = "1"
            }
        }
    }
}

$mcpConfig | ConvertTo-Json -Depth 3 | Out-File -FilePath "$antigravityPath\mcp_config.json" -Encoding UTF8

# 初始化Git倉庫
Write-Info "初始化Git倉庫..."
Set-Location $cascadePath

if (-not (Test-Path ".git")) {
    git init
    git config user.email "cascade@ai.assistant"
    git config user.name "Cascade AI"
    
    # 添加遠端
    try {
        git remote add origin "https://github.com/a0973207074-bot/cascade.git"
        Write-Success "添加遠端倉庫"
    } catch {
        Write-Warning "無法添加遠端倉庫，將使用本地倉庫"
    }
}

# 初始提交
git add .
if (git status --porcelain) {
    git commit -m "Cascade: Windows原生初始安裝完成

✅ 建立Windows原生目錄結構
✅ 創建PowerShell腳本系統
✅ 創建Windows任務計劃器支援
✅ 創建專案偵測技能
✅ 創建MCP整合技能
✅ 設定Windows同步機制
✅ 配置Windows MCP伺服器

Cascade AI Assistant Windows原生版準備就緒！" 2>$null
    
    Write-Success "初始提交完成"
}

# 創建Windows任務計劃器
Write-Info "設定Windows任務計劃器..."
$taskName = "CascadeSync"
$taskDescription = "Cascade AI Assistant 每日自動同步"
$scriptPath = "$cascadePath\sync\cascade_sync_windows.ps1"

# 創建任務觸發器（每天早上8點）
$trigger = New-ScheduledTaskTrigger -Daily -At 8:00AM

# 創建任務動作
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -File `"$scriptPath`""

# 創建任務設定
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

# 註冊任務
try {
    Register-ScheduledTask -TaskName $taskName -Description $taskDescription -Trigger $trigger -Action $action -Settings $settings -Force | Out-Null
    Write-Success "Windows任務計劃器設定完成"
} catch {
    Write-Warning "無法設定Windows任務計劃器: $($_.Exception.Message)"
}

# 創建PowerShell配置文件
Write-Info "創建PowerShell配置文件..."
$profilePath = $PROFILE.CurrentUserCurrentHost

# 備份現有profile
if (Test-Path $profilePath) {
    Copy-Item $profilePath "$profilePath.backup.$(Get-Date -Format 'yyyyMMdd_HHmmss')" -Force
}

# 添加Cascade別名
$cascadeAliases = @"

# Cascade AI Assistant Windows別名
function Invoke-CascadeSync { & "$cascadePath\sync\cascade_sync_windows.ps1" }
function Invoke-CascadeStatus { Set-Location "$cascadePath"; git status }
function Invoke-CascadeSkills { Get-ChildItem "$cascadePath\skills" -Recurse -Filter "*.md" }
function Invoke-CascadeLog { Get-Content "$cascadePath\evolution\logs\sync.log" -Tail 10 -Wait }

# 設定別名
Set-Alias -Name cascade-sync -Value Invoke-CascadeSync
Set-Alias -Name cascade-status -Value Invoke-CascadeStatus
Set-Alias -Name cascade-skills -Value Invoke-CascadeSkills
Set-Alias -Name cascade-log -Value Invoke-CascadeLog

Write-Host "🚀 Cascade AI Assistant Windows版已載入" -ForegroundColor Green
"@

Add-Content -Path $profilePath -Value $cascadeAliases

# 創建桌面快捷方式
Write-Info "創建桌面快捷方式..."
$desktopPath = [Environment]::GetFolderPath("Desktop")
$shell = New-Object -ComObject WScript.Shell

# 創建同步快捷方式
$shortcutPath = "$desktopPath\Cascade Sync.lnk"
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = "PowerShell.exe"
$shortcut.Arguments = "-ExecutionPolicy Bypass -File `"$scriptPath`""
$shortcut.WorkingDirectory = $cascadePath
$shortcut.IconLocation = "PowerShell.exe,0"
$shortcut.Description = "Cascade AI Assistant 同步"
$shortcut.Save()

# 創建狀態快捷方式
$statusShortcutPath = "$desktopPath\Cascade Status.lnk"
$statusShortcut = $shell.CreateShortcut($statusShortcutPath)
$statusShortcut.TargetPath = "PowerShell.exe"
$statusShortcut.Arguments = "-NoExit -Command `"Set-Location '$cascadePath'; git status`""
$statusShortcut.WorkingDirectory = $cascadePath
$statusShortcut.IconLocation = "PowerShell.exe,0"
$statusShortcut.Description = "Cascade AI Assistant 狀態"
$statusShortcut.Save()

Write-Success "桌面快捷方式創建完成"

# 完成訊息
Write-Host ""
Write-ColorOutput @"
╔══════════════════════════════════════════════════════════════╗
║                    🎉 Windows原生安裝完成！                  ║
║                                                              ║
║  Cascade AI Assistant 已成功安裝到Windows原生環境           ║
║                                                              ║
║  📋 使用方式：                                               ║
║  1. 重新啟動PowerShell                                       ║
║  2. 執行同步: cascade-sync                                  ║
║  3. 查看狀態: cascade-status                                ║
║  4. 查看技能: cascade-skills                                ║
║  5. 查看日誌: cascade-log                                   ║
║                                                              ║
║  🚀 現在您可以在Windows上直接使用Cascade AI Assistant！      ║
║                                                              ║
║  💡 特點：                                                   ║
║  - 不需要WSL/Ubuntu                                         ║
║  - 純Windows原生運行                                        ║
║  - Windows任務計劃器自動同步                                ║
║  - PowerShell腳本系統                                       ║
║  - 桌面快捷方式                                             ║
╚══════════════════════════════════════════════════════════════╝
"@ "Green"

Write-Host ""
Write-Info "安裝完成！請重新啟動PowerShell以載入新功能。"
Write-Info "您可以使用桌面快捷方式或PowerShell別名來操作Cascade。"

# 執行首次同步
Write-Info "執行首次同步..."
try {
    & "$cascadePath\sync\cascade_sync_windows.ps1"
    Write-Success "首次同步完成"
} catch {
    Write-Warning "首次同步失敗，您可以稍後手動執行 cascade-sync"
}
