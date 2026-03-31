@echo off
REM Cascade AI Assistant - Windows 快速安裝批次檔
REM 這是一個簡化的安裝腳本，適合快速部署

title Cascade AI Assistant - Windows 安裝

echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║                    Cascade AI Assistant                      ║
echo ║                   Windows 快速安裝                           ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.

REM 檢查管理員權限
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] 需要管理員權限，請以管理員身份執行此批次檔
    pause
    exit /b 1
)

echo [INFO] 開始安裝 Cascade AI Assistant for Windows...
echo.

REM 步驟1: 啟用WSL
echo [1/6] 啟用WSL功能...
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

REM 步驟2: 下載WSL更新包
echo [2/6] 下載WSL更新包...
powershell -Command "Invoke-WebRequest -Uri 'https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi' -OutFile '%TEMP%\wsl_update_x64.msi'"
msiexec.exe /i "%TEMP%\wsl_update_x64.msi" /quiet

REM 步驟3: 設定WSL預設版本
echo [3/6] 設定WSL預設版本為2...
wsl --set-default-version 2

REM 步驟4: 安裝Ubuntu
echo [4/6] 安裝Ubuntu...
echo 請手動從Microsoft Store安裝Ubuntu 22.04 LTS
echo 安裝完成後，請按任意鍵繼續...
pause

REM 步驟5: 在WSL中安裝Cascade
echo [5/6] 在WSL中安裝Cascade...
wsl bash -c "curl -fsSL https://raw.githubusercontent.com/a0973207074-bot/cascade-ai/main/auto_install.sh | bash"

REM 步驟6: 創建快捷方式
echo [6/6] 創建Windows快捷方式...

echo @echo off > "%USERPROFILE%\Cascade_Sync.bat"
echo wsl bash -c "cd ~/.gemini/cascade && ./sync/cascade_sync.sh" >> "%USERPROFILE%\Cascade_Sync.bat"
echo pause >> "%USERPROFILE%\Cascade_Sync.bat"

echo @echo off > "%USERPROFILE%\Cascade_Status.bat"
echo wsl bash -c "cd ~/.gemini/cascade && git status" >> "%USERPROFILE%\Cascade_Status.bat"
echo pause >> "%USERPROFILE%\Cascade_Status.bat"

echo @echo off > "%USERPROFILE%\Cascade_Skills.bat"
echo wsl bash -c "ls ~/.gemini/cascade/skills/" >> "%USERPROFILE%\Cascade_Skills.bat"
echo pause >> "%USERPROFILE%\Cascade_Skills.bat"

echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║                    🎉 安裝完成！                            ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.
echo 📋 使用方式:
echo   - 雙擊 Cascade_Sync.bat: 執行同步
echo   - 雙擊 Cascade_Status.bat: 查看狀態
echo   - 雙擊 Cascade_Skills.bat: 查看技能
echo.
echo 💡 提示: 需要重新啟動電腦以完成WSL安裝
echo.
echo 按任意鍵退出...
pause >nul
