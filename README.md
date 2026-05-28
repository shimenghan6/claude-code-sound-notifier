# Claude Code Sound Notifier

> Claude 干完活了？叮咚一下告诉你。需要你点确认？也叮咚一下。不用死盯屏幕，听到声音再回来看。

**3 个系统全支持、双击安装、自动检测已有配置不覆盖。装完当场试听两段音效。**

### 谁需要这个

| 你 | 为什么你需要 |
|----|------------|
| Claude 跑长任务时切走干别的 | 听到声音就知道完成，不用来回切 |
| Claude 弹权限框经常错过 | 权限请求有提示音，不会漏 |
| 想简单点，不想自己配 hook | 一键安装，自动追加配置 |

## 效果

| 场景 | 触发 | 声音 |
|------|------|------|
| Claude 需要你授权（弹权限框） | `PermissionRequest` hook | 通知提示音 |
| Claude 完成任务/回复结束 | `Stop` hook | 完成音效 |

## 一键安装

### Windows（PowerShell）

```powershell
powershell -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri https://raw.githubusercontent.com/<你的用户名>/claude-code-sound-notifier/main/install.ps1 -OutFile install.ps1; .\install.ps1"
```

或者下载 `install.ps1` → 右键 → 使用 PowerShell 运行。

安装脚本会自动检测现有配置，追加 `PermissionRequest` + `Stop` hook，不影响已有配置。装完后当场播放两段试听。

### macOS / Linux

```bash
curl -fsSL https://raw.githubusercontent.com/<你的用户名>/claude-code-sound-notifier/main/install.sh | bash
```

## 手动安装

复制 `settings.sample.json` 中的 `hooks` 配置块到你的 `~/.claude/settings.json` 中，重启 Claude Code 即可。

### Windows

```json
{
  "hooks": {
    "PermissionRequest": [
      {
        "matcher": "",
        "hooks": [{
          "type": "command",
          "command": "powershell -c \"(New-Object Media.SoundPlayer 'C:\\Windows\\Media\\Windows Notify.wav').PlaySync()\""
        }]
      }
    ],
    "Stop": [
      {
        "hooks": [{
          "type": "command",
          "command": "powershell -c \"(New-Object Media.SoundPlayer 'C:\\Windows\\Media\\tada.wav').PlaySync()\""
        }]
      }
    ]
  }
}
```

### macOS

```json
{
  "hooks": {
    "PermissionRequest": [
      {
        "matcher": "",
        "hooks": [{
          "type": "command",
          "command": "afplay /System/Library/Sounds/Ping.aiff"
        }]
      }
    ],
    "Stop": [
      {
        "hooks": [{
          "type": "command",
          "command": "afplay /System/Library/Sounds/Glass.aiff"
        }]
      }
    ]
  }
}
```

### Linux

```json
{
  "hooks": {
    "PermissionRequest": [
      {
        "matcher": "",
        "hooks": [{
          "type": "command",
          "command": "paplay /usr/share/sounds/freedesktop/stereo/message.oga"
        }]
      }
    ],
    "Stop": [
      {
        "hooks": [{
          "type": "command",
          "command": "paplay /usr/share/sounds/freedesktop/stereo/complete.oga"
        }]
      }
    ]
  }
}
```

## Windows 可用音效文件

位于 `C:\Windows\Media\`，以下是比较实用的：

| 文件 | 效果 |
|------|------|
| `tada.wav` | 完成提示（嘹亮） |
| `Windows Notify.wav` | 通知（清脆） |
| `Windows Ding.wav` | 叮咚 |
| `chimes.wav` | 风铃声 |
| `chord.wav` | 和弦音 |
| `notify.wav` | 柔和提示 |
| `Windows Exclamation.wav` | 警告提示 |
| `Windows Error.wav` | 错误音 |

## 踩坑记录

### 坑1：Notification hook 在 VSCode 扩展中不触发

**现象：** 配置了 `Notification` hook 监听权限提示，但在 VSCode Claude Code 扩展中完全没声音。

**原因：** `Notification` hook 在 VSCode 扩展中存在[已知 Bug](https://github.com/anthropics/claude-code/issues/11156)，`permission_prompt` matcher 不会触发。CLI 模式正常。

**解决：** 改用 `PermissionRequest` hook。这个 hook 专门在弹出权限确认框之前触发，VSCode 扩展中工作正常。

```json
// 不要用这个（VSCode 不触发）
"Notification": [{ "matcher": "permission_prompt", ... }]

// 用这个（VSCode 正常触发）
"PermissionRequest": [{ "matcher": "", ... }]
```

### 坑2：System.Console.Beep 在现代笔记本上不响

**现象：** 用 `[System.Console]::Beep(800, 300)` 没声音。

**原因：** `Beep()` 依赖主板蜂鸣器（PC Speaker），绝大多数现代笔记本（尤其是 Windows 11）根本没有这个硬件。

**解决：** 用 `Media.SoundPlayer` 播放 WAV 文件，或者用 TTS 语音朗读。

```powershell
# 不推荐（无蜂鸣器不响）
powershell -c "[System.Console]::Beep(800,300)"

# 推荐（播放 WAV 文件）
powershell -c "(New-Object Media.SoundPlayer 'C:\Windows\Media\tada.wav').PlaySync()"

# 备选（TTS 语音）
powershell -c "Add-Type -A System.Speech; (New-Object System.Speech.Synthesis.SpeechSynthesizer).Speak('需要审批')"
```

### 坑3：SystemSounds 可能被系统静音

**现象：** `[System.Media.SystemSounds]::Asterisk.Play()` 没声音。

**原因：** Windows 系统声音有独立的音量控制，很多用户关闭了系统提示音。

**解决：** 直接用 `Media.SoundPlayer` 播放 WAV 文件，绕过系统声音设置。

### 坑4：修改 settings.json 后当前会话不生效

**现象：** 改了 `settings.json`，但 hook 完全没触发。

**原因：** Hooks 只在 Claude Code 启动时加载一次，修改配置文件后必须重启会话。

**解决：** 开一个新对话，或重启 VSCode Claude Code 面板。改完配置后这一步不能省略。

### 坑5：PlaySync 会阻塞 vs Play 可能被跳过

**现象：** 用 `Play()` 异步播放时声音偶尔不响。

**原因：** `Play()` 是异步的，如果 PowerShell 进程在音频播完前退出，声音会被截断。

**解决：** 用 `PlaySync()` 同步播放，虽然会短暂阻塞 hook 执行（通常 < 1 秒），但保证声音完整播放。

## Hook 事件速查

| Hook 事件 | 触发时机 | VSCode 可用 | 适合提示音 |
|-----------|----------|-------------|------------|
| `Stop` | Claude 回复结束 | 是 | 任务完成 |
| `PermissionRequest` | 弹权限框前 | 是 | 需要审批 |
| `PreToolUse` | 工具执行前 | 是 | 高级定制 |
| `PostToolUse` | 工具执行后 | 是 | 每步通知 |
| `Notification` | 通知消息 | CLI 可用，VSCode 有 Bug | 不推荐 |
| `SessionStart` | 会话开始 | 是 | 启动提示 |

## 相关资源

- [Claude Code Hooks 官方文档](https://docs.anthropic.com/en/docs/claude-code/hooks)
- [Notification hook VSCode Bug](https://github.com/anthropics/claude-code/issues/11156)
- Windows 音效文件位于 `C:\Windows\Media\`

## License

MIT
