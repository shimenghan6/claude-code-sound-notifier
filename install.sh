#!/usr/bin/env bash
# Claude Code Sound Notifier - macOS/Linux 一键安装
# 用法：bash install.sh

set -e

SETTINGS="$HOME/.claude/settings.json"

if [ ! -f "$SETTINGS" ]; then
    echo "[错误] 找不到 $SETTINGS"
    echo "请先运行一次 Claude Code 再安装。"
    exit 1
fi

echo "读取现有配置..."

# 根据平台选声音命令
if [[ "$OSTYPE" == "darwin"* ]]; then
    PERM_CMD='afplay /System/Library/Sounds/Ping.aiff'
    STOP_CMD='afplay /System/Library/Sounds/Glass.aiff'
else
    PERM_CMD='paplay /usr/share/sounds/freedesktop/stereo/message.oga'
    STOP_CMD='paplay /usr/share/sounds/freedesktop/stereo/complete.oga'
fi

# 用 Python 做 JSON 合并（更可靠）
python3 -c "
import json, os

with open('$SETTINGS', 'r') as f:
    settings = json.load(f)

if 'hooks' not in settings:
    settings['hooks'] = {}

hooks = settings['hooks']

if 'PermissionRequest' not in hooks:
    hooks['PermissionRequest'] = [{
        'matcher': '',
        'hooks': [{'type': 'command', 'command': '$PERM_CMD'}]
    }]
    print('已添加 PermissionRequest hook')
else:
    print('PermissionRequest hook 已存在，跳过')

if 'Stop' not in hooks:
    hooks['Stop'] = [{
        'hooks': [{'type': 'command', 'command': '$STOP_CMD'}]
    }]
    print('已添加 Stop hook')
else:
    print('Stop hook 已存在，跳过')

with open('$SETTINGS', 'w') as f:
    json.dump(settings, f, indent=2, ensure_ascii=False)

print('安装完成！开新对话生效。')
"
