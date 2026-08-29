#!/usr/bin/env bash
# Omarchy 学研版 —— 可选模块：中文农历日历（替换状态栏时钟）
# 上游: https://github.com/GaryLiuGTA/omarchy_chinese_lunar_calendar (MIT)
set -euo pipefail

PLUGIN_URL="https://github.com/GaryLiuGTA/omarchy_chinese_lunar_calendar.git"
PLUGIN_ID="garyliu.lunar-calendar"
SHELL_JSON="$HOME/.config/omarchy/shell.json"

command -v omarchy >/dev/null 2>&1 || { echo "[错误] 需要 Omarchy 环境" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "[错误] 需要 jq" >&2; exit 1; }

# 1. 安装插件（不自动启用，布局由本脚本接管；已存在则跳过，避免重复克隆网络失败）
if [[ ! -d "$HOME/.config/omarchy/plugins/$PLUGIN_ID" ]]; then
  omarchy plugin add "$PLUGIN_URL" --yes
else
  echo "插件已存在，跳过克隆：$PLUGIN_ID"
fi

# 2. 备份并在 shell.json 中用农历日历替换内置时钟
if [[ -f "$SHELL_JSON" ]]; then
  cp -a "$SHELL_JSON" "$SHELL_JSON.bak-$(date +%Y%m%d-%H%M%S)"
fi

jq --arg id "$PLUGIN_ID" '
  .bar.centerAnchor = $id |
  .bar.layout.center = [
    .bar.layout.center[]
    | if (.id == "omarchy.clock" or .id == "sfk.clock") then {id: $id} else . end
  ]
' "$SHELL_JSON" > "$SHELL_JSON.tmp"
mv "$SHELL_JSON.tmp" "$SHELL_JSON"

if ! rg -q '"id": "'"$PLUGIN_ID"'"' "$SHELL_JSON"; then
  echo "[警告] 未在 shell.json 中找到 $PLUGIN_ID，可能内置时钟已被替换，请检查 $SHELL_JSON" >&2
fi

# 3. 重载状态栏
omarchy restart shell || omarchy-shell shell rescanPlugins 2>/dev/null || true

echo "完成：状态栏时钟已替换为农历日历（$PLUGIN_ID）。"
echo "卸载: omarchy plugin remove $PLUGIN_ID；并从 .bak-* 备份恢复 shell.json"
