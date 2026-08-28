#!/usr/bin/env bash
# Omarchy 学研版 —— HiDPI 缩放模块安装
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="$HOME/.config/hypr/monitors.lua"

read -r -p "屏幕 UI 缩放（4K 建议 1.6~2.0，1080p 用 1，默认 1.6）: " SCALE
read -r -p "GDK 缩放（Electron 应用，通常 2，默认 2）: " GDK
SCALE="${SCALE:-1.6}"
GDK="${GDK:-2}"

mkdir -p "$(dirname "$DEST")"
if [[ -e "$DEST" ]]; then
  cp -a "$DEST" "$DEST.bak-$(date +%Y%m%d-%H%M%S)"
  echo "已备份原文件: $DEST.bak-$(date +%Y%m%d-%H%M%S)"
fi

sed -e "s/omarchy_monitor_scale = .*/omarchy_monitor_scale = $SCALE/" \
    -e "s/omarchy_gdk_scale = .*/omarchy_gdk_scale = $GDK/" \
    "$HERE/monitors.lua" > "$DEST"

echo "已写入 $DEST（scale=$SCALE，GDK_SCALE=$GDK）；Hyprland 会自动重载"
