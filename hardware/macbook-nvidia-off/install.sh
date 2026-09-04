#!/usr/bin/env bash
# Omarchy 学研版 —— MacBook Pro 11,3 NVIDIA 独显断电模块
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if (( EUID != 0 )); then
  exec sudo "$0" "$@"
fi

MODEL="$(cat /sys/class/dmi/id/product_name 2>/dev/null || true)"
if [[ "$MODEL" != "MacBookPro11,3" ]]; then
  echo "[错误] 本模块仅适用于 MacBookPro11,3（MacBook Pro 15 英寸 Retina 双显卡版，Late 2013 / Mid 2014）" >&2
  echo "[错误] 当前机型: ${MODEL:-未知}" >&2
  exit 1
fi

install -Dm755 "$HERE/gpu-off.sh" /usr/local/sbin/gpu-off.sh
install -Dm644 "$HERE/nvidia-gpu-off.service" /etc/systemd/system/nvidia-gpu-off.service
systemctl daemon-reload
systemctl enable --now nvidia-gpu-off.service

if [[ ! -f /sys/kernel/debug/vgaswitcheroo/switch ]]; then
  mount -t debugfs debugfs /sys/kernel/debug 2>/dev/null || true
fi
if [[ ! -f /sys/kernel/debug/vgaswitcheroo/switch ]]; then
  echo "[警告] 未找到 /sys/kernel/debug/vgaswitcheroo/switch，服务已安装但可能未生效"
fi

echo "已为 MacBookPro11,3 安装并启用 nvidia-gpu-off.service（NVIDIA 独显开机断电）"
