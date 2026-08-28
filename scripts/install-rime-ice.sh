#!/usr/bin/env bash
# Omarchy 学研版 —— 安装 rime-ice（雾凇拼音）并应用本仓库补丁
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RIME_DIR="${RIME_DIR:-$HOME/.local/share/fcitx5/rime}"
UPSTREAM_URL="https://github.com/Dvel/rime-ice.git"

mkdir -p "$(dirname "$RIME_DIR")"

if [[ ! -d "$RIME_DIR/.git" ]]; then
  if [[ -e "$RIME_DIR" ]]; then
    mv "$RIME_DIR" "$RIME_DIR.bak-$(date +%Y%m%d-%H%M%S)"
    echo "已备份旧目录: $RIME_DIR.bak-$(date +%Y%m%d-%H%M%S)"
  fi
  git clone --depth 1 "$UPSTREAM_URL" "$RIME_DIR"
else
  git -C "$RIME_DIR" pull --ff-only
fi

cp "$REPO_DIR/rime/default.custom.yaml" "$RIME_DIR/default.custom.yaml"

if [[ ! -f "$RIME_DIR/custom_phrase.txt" ]]; then
  cp "$REPO_DIR/rime/custom_phrase.example.txt" "$RIME_DIR/custom_phrase.txt"
  echo "已生成示例 custom_phrase.txt（可自行编辑增删短语）"
fi

echo "rime-ice 已就绪；重启 fcitx5 或重新登录后生效"
