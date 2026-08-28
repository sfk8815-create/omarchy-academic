#!/usr/bin/env bash
# Omarchy 学研版 —— 可选模块：Aether（科研 AI 研究助手）
# 上游: https://github.com/Science-Discovery/Aether (MIT)
# 安装 Web 浏览器版（aether CLI + web/ 静态资源），Electron 桌面版可选
set -euo pipefail

REPO="Science-Discovery/Aether"
DEST="$HOME/.local/opt/aether"
WRAPPER="$HOME/.local/bin/aether"

command -v curl >/dev/null 2>&1 || { echo "[错误] 需要 curl" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "[错误] 需要 jq" >&2; exit 1; }
command -v unzip >/dev/null 2>&1 || { echo "[错误] 需要 unzip" >&2; exit 1; }

# 1. 获取最新版本与 Linux x64 Web 版资产
release="$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest")"
tag="$(printf '%s' "$release" | jq -r .tag_name)"
asset="$(printf '%s' "$release" | jq -r '.assets[].name | select(. == "aether-linux-x64.zip")' | head -1)"
if [[ -z "$asset" ]]; then
  echo "[错误] 未找到 aether-linux-x64.zip 发布资产（$tag）" >&2
  exit 1
fi
url="https://github.com/$REPO/releases/download/$tag/$asset"

echo "下载 $asset ..."
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
curl -fSL "$url" -o "$tmp/aether.zip"

# 2. 解压到 ~/.local/opt/aether（保留旧版本备份）
if [[ -d "$DEST" ]]; then
  mv "$DEST" "$DEST.bak-$(date +%Y%m%d-%H%M%S)"
fi
mkdir -p "$DEST"
unzip -q "$tmp/aether.zip" -d "$DEST"
[[ -x "$DEST/aether" ]] || { echo "[错误] 解压后未找到 aether 可执行文件" >&2; exit 1; }

# 3. PATH 包装脚本
mkdir -p "$HOME/.local/bin"
cat > "$WRAPPER" <<'EOF'
#!/bin/sh
# Aether 科研助手 CLI wrapper（安装自 omarchy-academic）
exec "$HOME/.local/opt/aether/aether" "$@"
EOF
chmod +x "$WRAPPER"

echo "完成：Aether $tag 已安装。"
echo "启动: aether web（浏览器版，自动打开本地地址）"
echo "可选: cd $DEST && ./install.sh 创建桌面应用入口；Electron 桌面版见 Releases"
echo "卸载: 删除 $DEST 与 $WRAPPER"
