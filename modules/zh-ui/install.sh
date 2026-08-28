#!/usr/bin/env bash
# Omarchy 学研版 —— 可选模块：Omarchy 界面简体中文化
# 上游: https://github.com/QueedWen/omarchy-zh-cn (MIT)
# 说明: 汉化主菜单/系统面板/天气/快捷键面板；不修改 /usr/share/omarchy
set -euo pipefail

SRC_URL="https://github.com/QueedWen/omarchy-zh-cn.git"
DEST="$HOME/.local/share/omarchy-zh-cn"

command -v omarchy >/dev/null 2>&1 || { echo "[错误] 需要 Omarchy 环境" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "[错误] 需要 jq" >&2; exit 1; }
command -v node >/dev/null 2>&1 || { echo "[错误] 需要 Node.js" >&2; exit 1; }
pgrep -f omarchy-shell >/dev/null 2>&1 || echo "[警告] 未检测到 Omarchy Shell，安装后请重新登录"

if [[ ! -d "$DEST/.git" ]]; then
  git clone "$SRC_URL" "$DEST"
else
  git -C "$DEST" pull --ff-only
fi

cd "$DEST"
./install.sh --dry-run
./install.sh

echo
echo "完成：Omarchy 界面已汉化。"
echo "手动同步: omarchy-zh-sync"
echo "卸载: cd $DEST && ./uninstall.sh"
