#!/usr/bin/env bash
# Omarchy 学研版 —— Apple 键盘 fn 键模块
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if (( EUID != 0 )); then
  exec sudo "$0" "$@"
fi

if [[ -f /etc/modprobe.d/hid_apple.conf ]]; then
  cp -a /etc/modprobe.d/hid_apple.conf "/etc/modprobe.d/hid_apple.conf.bak-$(date +%Y%m%d-%H%M%S)"
fi

install -Dm644 "$HERE/hid_apple.conf" /etc/modprobe.d/hid_apple.conf
echo "已安装 /etc/modprobe.d/hid_apple.conf；重启后生效"
