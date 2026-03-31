# 建立GitHub倉庫指南

## 🎯 目標
建立GitHub倉庫以實現Cascade AI Assistant的跨裝置同步

## 📋 步驟

### 1. 建立GitHub倉庫
在GitHub網站上：
1. 登入 https://github.com
2. 點擊 "New repository"
3. 倉庫名稱: `cascade`
4. 設定為 Public
5. 不要初始化README、.gitignore、license
6. 點擊 "Create repository"

### 2. 複製倉庫URL
建立完成後，GitHub會顯示：
```
https://github.com/a0973207074-bot/cascade.git
```

### 3. 更新本地Git配置
```bash
cd ~/.gemini/cascade
git remote set-url origin https://github.com/a0973207074-bot/cascade.git
git branch -M main
```

### 4. 推送到GitHub
```bash
git push -f origin main
```

### 5. 驗證
```bash
git remote -v
# 應該顯示:
# origin  https://github.com/a0973207074-bot/cascade.git (fetch)
# origin  https://github.com/a0973207074-bot/cascade.git (push)
```

## 🚀 完成後的跨裝置安裝指令

### Linux/macOS:
```bash
curl -fsSL https://raw.githubusercontent.com/a0973207074-bot/cascade/main/sync/auto_install.sh | bash
```

### Windows PowerShell:
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
irm https://raw.githubusercontent.com/a0973207074-bot/cascade/main/sync/auto_install_windows.ps1 | iex
```

### Windows 批次檔:
```batch
# 下載並執行
curl -o install.bat https://raw.githubusercontent.com/a0973207074-bot/cascade/main/sync/windows_quick_install.bat
install.bat
```

## 📁 需要推送到GitHub的檔案

確保以下檔案在倉庫中：
- `sync/auto_install.sh`
- `sync/auto_install_windows.ps1` 
- `sync/windows_quick_install.bat`
- `core/CASCADE_CORE.md`
- `skills/project_detection/SKILL.md`
- `skills/mcp_integration/SKILL.md`
- `sync/cascade_sync.sh`

## 🔄 跨裝置同步機制

1. **設備A**: 執行 cascade-sync，推送到GitHub
2. **設備B**: 執行 cascade-sync，從GitHub拉取
3. **自動同步**: 每天早上8點自動同步

## 🎯 完成後

你就可以在任何新電腦上用一條指令部署完整的Cascade AI Assistant！
