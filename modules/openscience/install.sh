#!/usr/bin/env bash
# Omarchy 学研版 —— 可选模块：Open Science Desktop（本地优先 AI 科研工作台）
# 上游: https://github.com/ai4s-research/open-science (MIT)
set -euo pipefail

REPO="ai4s-research/open-science"
DEST="$HOME/.local/opt/osd"
WRAPPER="$HOME/.local/bin/osd"

command -v curl >/dev/null 2>&1 || { echo "[错误] 需要 curl" >&2; exit 1; }
command -v tar >/dev/null 2>&1 || { echo "[错误] 需要 tar" >&2; exit 1; }

# 大文件下载可选走代理（避免 GitHub API 未认证限流；只对下载生效）
PROXY="${DOWNLOAD_PROXY:-}"
curl_cmd() {
  if [[ -n "$PROXY" ]]; then
    curl -fSL --proxy "$PROXY" "$@"
  else
    curl -fSL "$@"
  fi
}

# 1. 通过 releases/latest 跳转获取最新 tag（不依赖 GitHub API，避免未认证限流）
latest_url="$(curl_cmd -sIL -o /dev/null -w '%{url_effective}' "https://github.com/$REPO/releases/latest")"
tag="${latest_url##*/}"
asset="osd-${tag#v}-x86_64-unknown-linux-gnu.tar.gz"
url="https://github.com/$REPO/releases/download/$tag/$asset"

echo "下载 $asset ..."
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
curl_cmd --retry 3 --retry-delay 5 -C - "$url" -o "$tmp/osd.tar.gz"

# 2. 解压到 ~/.local/opt/osd（保留旧版本备份）
if [[ -d "$DEST" ]]; then
  mv "$DEST" "$DEST.bak-$(date +%Y%m%d-%H%M%S)"
fi
mkdir -p "$DEST"
tar -xzf "$tmp/osd.tar.gz" -C "$DEST"

# 兼容压缩包内带顶层目录的情况：自动定位 osd 可执行文件
BIN="$(find "$DEST" -maxdepth 3 -type f -name osd -perm -u+x 2>/dev/null | head -1)"
if [[ -z "$BIN" ]]; then
  echo "[错误] 解压后未找到 osd 可执行文件" >&2
  exit 1
fi

# 3. 安装 PATH 包装脚本
mkdir -p "$HOME/.local/bin"
cat > "$WRAPPER" <<'EOF'
#!/bin/sh
# Open Science Desktop CLI wrapper（安装自 omarchy-academic）
exec "BIN_PATH" "$@"
EOF
sed -i "s|BIN_PATH|$BIN|" "$WRAPPER"
chmod +x "$WRAPPER"

echo "完成：osd $tag 已安装（$BIN）"
echo "用法: osd server（启动工作台）；osd --help 查看全部命令"
echo "卸载: 删除 $DEST 与 $WRAPPER"
