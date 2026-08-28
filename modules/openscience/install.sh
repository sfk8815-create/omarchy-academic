#!/usr/bin/env bash
# Omarchy 学研版 —— 可选模块：Open Science Desktop（本地优先 AI 科研工作台）
# 上游: https://github.com/ai4s-research/open-science (MIT)
set -euo pipefail

REPO="ai4s-research/open-science"
DEST="$HOME/.local/opt/osd"
WRAPPER="$HOME/.local/bin/osd"

command -v curl >/dev/null 2>&1 || { echo "[错误] 需要 curl" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "[错误] 需要 jq" >&2; exit 1; }
command -v tar >/dev/null 2>&1 || { echo "[错误] 需要 tar" >&2; exit 1; }

# 1. 获取最新版本与 Linux x86_64 CLI 资产
release="$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest")"
tag="$(printf '%s' "$release" | jq -r .tag_name)"
asset="$(printf '%s' "$release" | jq -r '.assets[].name | select(test("x86_64-unknown-linux-gnu\\.tar\\.gz$"))' | head -1)"
if [[ -z "$asset" ]]; then
  echo "[错误] 未找到 Linux CLI 发布资产（$tag）" >&2
  exit 1
fi
url="https://github.com/$REPO/releases/download/$tag/$asset"

echo "下载 $asset ..."
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
curl -fSL "$url" -o "$tmp/osd.tar.gz"

# 2. 解压到 ~/.local/opt/osd（保留旧版本备份）
if [[ -d "$DEST" ]]; then
  mv "$DEST" "$DEST.bak-$(date +%Y%m%d-%H%M%S)"
fi
mkdir -p "$DEST"
tar -xzf "$tmp/osd.tar.gz" -C "$DEST"

if [[ -x "$DEST/usr/bin/osd" ]]; then
  bin_rel="$HOME/.local/opt/osd/usr/bin/osd"
elif [[ -x "$DEST/osd" ]]; then
  bin_rel="$HOME/.local/opt/osd/osd"
else
  echo "[错误] 解压后未找到 osd 可执行文件" >&2
  exit 1
fi

# 3. 安装 PATH 包装脚本
mkdir -p "$HOME/.local/bin"
cat > "$WRAPPER" <<'EOF'
#!/bin/sh
# Open Science Desktop CLI wrapper（安装自 omarchy-academic）
exec "$HOME/.local/opt/osd/usr/bin/osd" "$@"
EOF
chmod +x "$WRAPPER"

echo "完成：osd $tag 已安装（$bin_rel）"
echo "用法: osd server（启动工作台）；osd --help 查看全部命令"
echo "卸载: 删除 $DEST 与 $WRAPPER"
