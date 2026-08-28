#!/usr/bin/env bash
# Omarchy 学研版 —— MacBook 双显卡（Intel 核显 + NVIDIA 独显）断电模块
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if (( EUID != 0 )); then
  exec sudo "$0" "$@"
fi

install -Dm755 "$HERE/gpu-off.sh" /usr/local/sbin/gpu-off.sh
install -Dm644 "$HERE/nvidia-gpu-off.service" /etc/systemd/system/nvidia-gpu-off.service
systemctl daemon-reload
systemctl enable --now nvidia-gpu-off.service

if [[ ! -f /sys/kernel/debug/vgaswitcheroo/switch ]]; then
  echo "[警告] 未检测到 vgaswitcheroo（可能不是双显卡机器），服务已安装但可能无效"
fi

echo "已安装并启用 nvidia-gpu-off.service"
