#!/usr/bin/env bash
# Omarchy 学研版 —— 把 sovena 文献流的 MCP 端点注册进 MCP Cockpit（mcp-hub）
#
# 幂等：sovena 已存在时更新为当前端点；自动备份 servers.json。
# 环境变量：
#   MCP_HUB_CONFIG   mcp-hub 配置文件路径（默认 ~/.config/mcp-hub/servers.json）
#   SOVENA_MCP_URL   sovena MCP 端点（默认 http://127.0.0.1:8765/mcp）
set -euo pipefail

CONFIG="${MCP_HUB_CONFIG:-$HOME/.config/mcp-hub/servers.json}"
SOVENA_URL="${SOVENA_MCP_URL:-http://127.0.0.1:8765/mcp}"

command -v jq >/dev/null 2>&1 || { echo "[错误] 需要 jq" >&2; exit 1; }

if [[ ! -f "$CONFIG" ]]; then
  echo "[错误] 未找到 mcp-hub 配置：$CONFIG（请先安装 MCP Cockpit）" >&2
  exit 1
fi

cp -a "$CONFIG" "$CONFIG.bak-$(date +%Y%m%d-%H%M%S)"

jq --arg url "$SOVENA_URL" '
  .mcpServers.sovena = { url: $url, headers: {} }
' "$CONFIG" > "$CONFIG.tmp"
mv "$CONFIG.tmp" "$CONFIG"

echo "已注册 sovena → $SOVENA_URL（$CONFIG）"
if pgrep -f 'mcp-hub' >/dev/null 2>&1; then
  echo "提示：mcp-hub 正在运行，新服务器需重启网关生效（如 systemd 自启：systemctl --user restart mcp-hub）"
fi
