#!/usr/bin/env bash
# Omarchy 学研版 —— 安装 rime-ice（雾凇拼音）并应用本仓库补丁
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RIME_DIR="${RIME_DIR:-$HOME/.local/share/fcitx5/rime}"
UPSTREAM_URL="https://github.com/iDvel/rime-ice.git"
TARBALL_URL="https://codeload.github.com/iDvel/rime-ice/tar.gz/refs/heads/main"
PROXY="${DOWNLOAD_PROXY:-}"

export GIT_TERMINAL_PROMPT=0
mkdir -p "$(dirname "$RIME_DIR")"

git_cmd() {
  if [[ -n "$PROXY" ]]; then
    git -c http.proxy="$PROXY" -c https.proxy="$PROXY" "$@"
  else
    git "$@"
  fi
}

curl_cmd() {
  if [[ -n "$PROXY" ]]; then
    curl -fSL --proxy "$PROXY" "$@"
  else
    curl -fSL "$@"
  fi
}

clone_or_pull() {
  if [[ ! -d "$RIME_DIR/.git" ]]; then
    if [[ -e "$RIME_DIR" ]]; then
      mv "$RIME_DIR" "$RIME_DIR.bak-$(date +%Y%m%d-%H%M%S)"
      echo "已备份旧目录: $RIME_DIR.bak-$(date +%Y%m%d-%H%M%S)"
    fi
    git_cmd clone --depth 1 "$UPSTREAM_URL" "$RIME_DIR"
  else
    git_cmd -C "$RIME_DIR" pull --ff-only
  fi
}

if ! clone_or_pull; then
  echo "[警告] git 克隆失败，改用 tarball 下载（网络慢/代理异常时更稳）"
  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT
  curl_cmd --retry 3 --retry-delay 5 "$TARBALL_URL" -o "$tmp/rime-ice.tar.gz"
  if [[ -e "$RIME_DIR" ]]; then
    mv "$RIME_DIR" "$RIME_DIR.bak-$(date +%Y%m%d-%H%M%S)"
  fi
  mkdir -p "$RIME_DIR"
  tar -xzf "$tmp/rime-ice.tar.gz" -C "$tmp"
  cp -a "$tmp"/rime-ice-main/. "$RIME_DIR/"
  echo "已通过 tarball 安装 rime-ice（后续可用 omarchy-academic 更新脚本重新同步）"
fi

if [[ ! -d "$RIME_DIR/.git" ]]; then
  echo "[提示] 当前为 tarball 安装（无 .git），更新时建议删除 $RIME_DIR 后重新安装"
fi

cp "$REPO_DIR/rime/default.custom.yaml" "$RIME_DIR/default.custom.yaml"

if [[ ! -f "$RIME_DIR/custom_phrase.txt" ]]; then
  cp "$REPO_DIR/rime/custom_phrase.example.txt" "$RIME_DIR/custom_phrase.txt"
  echo "已生成示例 custom_phrase.txt（可自行编辑增删短语）"
fi

echo "rime-ice 已就绪；重启 fcitx5 或重新登录后生效"
