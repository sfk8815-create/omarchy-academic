#!/usr/bin/env bash
# Omarchy 学研版 —— 国内镜像与 archlinuxcn 社区仓库配置
#
# 用法:
#   setup-cn-mirrors.sh                    # 默认清华镜像 + archlinuxcn
#   setup-cn-mirrors.sh --mirror ustc      # 中科大镜像
#   setup-cn-mirrors.sh --no-archlinuxcn   # 只换 Arch 镜像，不装社区仓库
#
# 说明:
#   - 只改写 /etc/pacman.d/mirrorlist（core/extra/multilib）；
#     [omarchy] 仓库仍走官方源，不受影响。
#   - archlinuxcn 为 Arch Linux 中文社区仓库（https://www.archlinuxcn.org）。
#   - 所有被修改的文件都会保留 .bak-<时间戳>，可随时还原。
# 需要 root；非 root 时自动用 sudo 重跑。
set -euo pipefail

if (( EUID != 0 )); then
  exec sudo "$0" "$@"
fi

MIRROR="tuna"
WITH_ARCHLINUXCN=1

while [[ $# -gt 0 ]]; do
  case "$1" in
    --mirror)
      MIRROR="$2"
      shift
      ;;
    --no-archlinuxcn)
      WITH_ARCHLINUXCN=0
      ;;
    *)
      echo "未知参数: $1" >&2
      exit 1
      ;;
  esac
  shift
done

TS="$(date +%Y%m%d-%H%M%S)"
MIRRORLIST="/etc/pacman.d/mirrorlist"

case "$MIRROR" in
  tuna)
    SERVER="https://mirrors.tuna.tsinghua.edu.cn/archlinux/\$repo/os/\$arch"
    ;;
  ustc)
    SERVER="https://mirrors.ustc.edu.cn/archlinux/\$repo/os/\$arch"
    ;;
  aliyun)
    SERVER="https://mirrors.aliyun.com/archlinux/\$repo/os/\$arch"
    ;;
  *)
    echo "[错误] 不支持的镜像: $MIRROR（可选 tuna / ustc / aliyun）" >&2
    exit 1
    ;;
esac

# 1. Arch 官方仓库镜像
if [[ -f "$MIRRORLIST" ]]; then
  cp -a "$MIRRORLIST" "$MIRRORLIST.bak-$TS"
fi
{
  echo "## Omarchy 学研版：国内镜像（$MIRROR）"
  echo "## 原文件备份: $MIRRORLIST.bak-$TS"
  echo "## 备选镜像: tuna（清华）/ ustc（中科大）/ aliyun（阿里云）"
  echo "Server = $SERVER"
} > "$MIRRORLIST"
echo "已写入 $MIRRORLIST（$MIRROR）"

# 2. archlinuxcn 社区仓库
if (( WITH_ARCHLINUXCN )); then
  if grep -q '^\[archlinuxcn\]' /etc/pacman.conf; then
    echo "[archlinuxcn] 已配置，跳过追加"
  else
    cp -a /etc/pacman.conf "/etc/pacman.conf.bak-$TS"
    cat >> /etc/pacman.conf <<'EOF'

# Omarchy 学研版：Arch Linux 中文社区仓库（archlinuxcn）
# 镜像可参考 https://github.com/archlinuxcn/mirrorlist-repo
[archlinuxcn]
Server = https://repo.archlinuxcn.org/$arch
EOF
    echo "已追加 [archlinuxcn] 到 /etc/pacman.conf"
  fi

  echo "同步并安装 archlinuxcn-keyring ..."
  pacman -Sy --noconfirm
  pacman -S --noconfirm archlinuxcn-keyring || {
    echo "[警告] archlinuxcn-keyring 安装失败，请检查网络后重试" >&2
  }
fi

echo "完成。还原方法：sudo cp $MIRRORLIST.bak-$TS $MIRRORLIST"
if (( WITH_ARCHLINUXCN )); then
  echo "（pacman.conf 备份: /etc/pacman.conf.bak-$TS）"
fi
