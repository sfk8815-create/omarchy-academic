#!/usr/bin/env bash
# Omarchy 学研版 —— 可选模块：MCP Cockpit（MCP 驾驶舱）
# 上游: https://github.com/sfk8815-create/mcp-cockpit（作者自有项目）
set -euo pipefail

COCKPIT_URL="https://github.com/sfk8815-create/mcp-cockpit.git"
DEST="${MCP_COCKPIT_DIR:-$HOME/mcp-cockpit}"

if [[ ! -d "$DEST/.git" ]]; then
  git clone "$COCKPIT_URL" "$DEST"
else
  git -C "$DEST" pull --ff-only
fi

cd "$DEST"
bash scripts/install.sh

echo
echo "完成：mcp-hub 网关与管理台已安装（~/.config/mcp-hub/servers.json 不会被覆盖）。"
echo "启动: cd $DEST && bash scripts/start.sh，浏览器打开 http://127.0.0.1:8899"
echo "开机自启: 参照 $DEST/docs/systemd/ 安装 systemd --user 单元"
echo "卸载: 删除 $DEST；如已装自启，先 systemctl --user disable --now mcp-hub mcp-hub-web"
