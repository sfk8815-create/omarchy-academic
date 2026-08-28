#!/usr/bin/env bash
# Omarchy 学研版 —— 本机配置 <-> 仓库同步（长期维护）
#
#   ./sync.sh check   对比仓库与本机配置，列出差异
#   ./sync.sh pull    把本机最新配置拉回仓库（覆盖仓库文件）
#   ./sync.sh status  查看仓库 git 状态
#
# 只同步下面列出的“干净”文件；个人数据（Rime 词库、API 配置等）不在同步范围。
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 格式：仓库相对路径|本机绝对路径
PAIRS=(
  "config/fontconfig/fonts.conf|$HOME/.config/fontconfig/fonts.conf"
  "config/fcitx5/profile|$HOME/.config/fcitx5/profile"
  "config/hypr/hyprland.lua|$HOME/.config/hypr/hyprland.lua"
  "config/omarchy/shell.json|$HOME/.config/omarchy/shell.json"
  "config/omarchy/shell.toml|$HOME/.config/omarchy/shell.toml"
  "config/alacritty/alacritty.toml|$HOME/.config/alacritty/alacritty.toml"
  "config/foot/foot.ini|$HOME/.config/foot/foot.ini"
  "config/kitty/kitty.conf|$HOME/.config/kitty/kitty.conf"
  "config/ghostty/config|$HOME/.config/ghostty/config"
)

cmd="${1:-check}"

case "$cmd" in
  check)
    for pair in "${PAIRS[@]}"; do
      rel="${pair%%|*}"
      dst="${pair#*|}"
      if [[ ! -f "$dst" ]]; then
        echo "MISSING  $rel（本机无此文件）"
        continue
      fi
      if ! diff -q "$REPO_DIR/$rel" "$dst" >/dev/null 2>&1; then
        echo "DIFF     $rel"
      fi
    done
    ;;
  pull)
    for pair in "${PAIRS[@]}"; do
      rel="${pair%%|*}"
      dst="${pair#*|}"
      if [[ ! -f "$dst" ]]; then
        echo "SKIP     $rel（本机无此文件）"
        continue
      fi
      if ! diff -q "$REPO_DIR/$rel" "$dst" >/dev/null 2>&1; then
        cp -a "$dst" "$REPO_DIR/$rel"
        echo "UPDATED  $rel"
      fi
    done
    echo "完成。请 review 后 git add / commit / push。"
    ;;
  status)
    git -C "$REPO_DIR" status --short
    ;;
  *)
    echo "用法: $0 {check|pull|status}" >&2
    exit 1
    ;;
esac
