#!/usr/bin/env bash
# Omarchy 学研版 —— 中文区域设置
# 用法: setup-locale.sh [--timezone Asia/Shanghai]
# 需要 root；非 root 时自动用 sudo 重跑。
set -euo pipefail

if (( EUID != 0 )); then
  exec sudo "$0" "$@"
fi

TIMEZONE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --timezone)
      TIMEZONE="$2"
      shift
      ;;
    *)
      echo "未知参数: $1" >&2
      exit 1
      ;;
  esac
  shift
done

TS="$(date +%Y%m%d-%H%M%S)"

if [[ ! -f /etc/locale.gen ]]; then
  echo "[错误] 未找到 /etc/locale.gen" >&2
  exit 1
fi

# 1. 启用 zh_CN.UTF-8 并重新生成 locale
cp -a /etc/locale.gen "/etc/locale.gen.bak-$TS"
if grep -q '^#zh_CN.UTF-8 UTF-8' /etc/locale.gen; then
  sed -i 's/^#zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/' /etc/locale.gen
elif ! grep -q '^zh_CN.UTF-8 UTF-8' /etc/locale.gen; then
  echo 'zh_CN.UTF-8 UTF-8' >> /etc/locale.gen
fi
locale-gen

# 2. 写入 /etc/locale.conf（不设置 LC_ALL，保持各分类独立）
if [[ -f /etc/locale.conf ]]; then
  cp -a /etc/locale.conf "/etc/locale.conf.bak-$TS"
fi
printf 'LANG=zh_CN.UTF-8\n' > /etc/locale.conf

# 3. 时区（可选）
if [[ -n "$TIMEZONE" ]]; then
  if [[ -f "/usr/share/zoneinfo/$TIMEZONE" ]]; then
    ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
    echo "时区已设置为 $TIMEZONE"
  else
    echo "[警告] 时区文件不存在: /usr/share/zoneinfo/$TIMEZONE，跳过" >&2
  fi
fi

echo "完成：LANG=zh_CN.UTF-8 已写入 /etc/locale.conf（旧文件备份为 .bak-$TS）"
