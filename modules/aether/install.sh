#!/usr/bin/env bash
# Omarchy 学研版 —— 可选模块：Aether（科研 AI 研究助手）
# 上游: https://github.com/Science-Discovery/Aether (MIT)
# 安装 Web 浏览器版（aether CLI + web/ 静态资源），Electron 桌面版可选
set -euo pipefail

REPO="Science-Discovery/Aether"
DEST="$HOME/.local/opt/aether"
WRAPPER="$HOME/.local/bin/aether"

command -v curl >/dev/null 2>&1 || { echo "[错误] 需要 curl" >&2; exit 1; }
command -v unzip >/dev/null 2>&1 || { echo "[错误] 需要 unzip" >&2; exit 1; }

# 大文件下载可选走代理（避免 GitHub API 未认证限流；只对下载生效）
PROXY="${DOWNLOAD_PROXY:-}"
curl_cmd() {
  if [[ -n "$PROXY" ]]; then
    curl -fSL --proxy "$PROXY" "$@"
  else
    curl -fSL "$@"
  fi
}

# 1. Linux x64 Web 版资产（releases/latest 自动指向最新版本，不依赖 API）
url="https://github.com/$REPO/releases/latest/download/aether-linux-x64.zip"

echo "下载 aether-linux-x64.zip ..."
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
curl_cmd --retry 3 --retry-delay 5 -C - "$url" -o "$tmp/aether.zip"

# 2. 解压到 ~/.local/opt/aether（保留旧版本备份）
if [[ -d "$DEST" ]]; then
  mv "$DEST" "$DEST.bak-$(date +%Y%m%d-%H%M%S)"
fi
mkdir -p "$DEST"
unzip -q "$tmp/aether.zip" -d "$DEST"

# 兼容压缩包内带顶层目录的情况：自动定位可执行文件与 web/ 资源
BIN="$(find "$DEST" -maxdepth 3 -type f -name aether -perm -u+x 2>/dev/null | head -1)"
APPROOT="$(dirname "${BIN:-}")"
if [[ -z "$BIN" || ! -d "$APPROOT/web" ]]; then
  echo "[错误] 解压后未找到 aether 可执行文件（或缺少 web/ 资源）" >&2
  exit 1
fi

# 3. PATH 包装脚本
mkdir -p "$HOME/.local/bin"
cat > "$WRAPPER" <<'EOF'
#!/bin/sh
# Aether 科研助手 CLI wrapper（安装自 omarchy-academic）
exec "BIN_PATH" "$@"
EOF
sed -i "s|BIN_PATH|$BIN|" "$WRAPPER"
chmod +x "$WRAPPER"

echo "完成：Aether 已安装（$BIN）。"
echo "启动: aether web（浏览器版，自动打开本地地址）"
echo "可选: cd $DEST && ./install.sh 创建桌面应用入口；Electron 桌面版见 Releases"
echo "卸载: 删除 $DEST 与 $WRAPPER"
