# Claude Code Sound Notifier - Windows 一键安装
# 用法：右键 → 使用 PowerShell 运行，或：
#   powershell -ExecutionPolicy Bypass -File install.ps1

$settingsPath = "$env:USERPROFILE\.claude\settings.json"

if (-not (Test-Path $settingsPath)) {
    Write-Host "[错误] 找不到 settings.json: $settingsPath" -ForegroundColor Red
    Write-Host "请先运行一次 Claude Code 再安装。"
    exit 1
}

Write-Host "读取现有配置..." -ForegroundColor Cyan
$settings = Get-Content $settingsPath -Raw -Encoding UTF8 | ConvertFrom-Json

# 确保 hooks 对象存在
if (-not $settings.hooks) {
    $settings | Add-Member -MemberType NoteProperty -Name "hooks" -Value @{}
}

# PermissionRequest hook
$permHook = @{
    matcher = ""
    hooks = @(
        @{
            type = "command"
            command = "powershell -c `"(New-Object Media.SoundPlayer 'C:\Windows\Media\Windows Notify.wav').PlaySync()`""
        }
    )
}

# Stop hook
$stopHook = @{
    hooks = @(
        @{
            type = "command"
            command = "powershell -c `"(New-Object Media.SoundPlayer 'C:\Windows\Media\tada.wav').PlaySync()`""
        }
    )
}

# 更新 hooks
$hooks = $settings.hooks

if (-not $hooks.PermissionRequest) {
    Write-Host "添加 PermissionRequest hook（权限弹窗提示音）..." -ForegroundColor Green
    $hooks | Add-Member -MemberType NoteProperty -Name "PermissionRequest" -Value @($permHook) -Force
} else {
    Write-Host "PermissionRequest hook 已存在，跳过。" -ForegroundColor Yellow
}

if (-not $hooks.Stop) {
    Write-Host "添加 Stop hook（任务完成提示音）..." -ForegroundColor Green
    $hooks | Add-Member -MemberType NoteProperty -Name "Stop" -Value @($stopHook) -Force
} else {
    Write-Host "Stop hook 已存在，跳过。" -ForegroundColor Yellow
}

# 保存
$newJson = $settings | ConvertTo-Json -Depth 10
$newJson | Set-Content $settingsPath -Encoding UTF8

Write-Host ""
Write-Host "安装完成！" -ForegroundColor Green
Write-Host "现在打开新对话，Claude 就会在需要你同意时发出提示音了。"
Write-Host ""
Write-Host "试听:" -ForegroundColor Cyan
Write-Host "  权限提示音 → 按键测试..."
(New-Object Media.SoundPlayer 'C:\Windows\Media\Windows Notify.wav').PlaySync()
Write-Host "  完成提示音 → 按键测试..."
(New-Object Media.SoundPlayer 'C:\Windows\Media\tada.wav').PlaySync()
Write-Host "听到声音就说明安装成功！" -ForegroundColor Green
