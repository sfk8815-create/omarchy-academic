#!/usr/bin/env bash
# Omarchy 学研版 (Omarchy Academic) —— 一键安装脚本
#
# 用法:
#   ./install.sh                    交互式安装（推荐）
#   ./install.sh --yes              全部可选模块（除硬件模块外）
#   ./install.sh --with-apps --with-academic
#   ./install.sh --no-packages --no-locale
#   ./install.sh --dry-run          只打印将要执行的步骤
# 详见 docs/install.md
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_ROOT="$HOME/.omarchy-academic-backup"

DO_PACKAGES=1
DO_LOCALE=1
DO_CONFIG=1
DO_RIME=1
DO_HELPERS=1
WITH_APPS=0
WITH_ACADEMIC=0
WITH_HIDPI=0
WITH_HID_APPLE=0
WITH_PROXY=0
ASSUME_YES=0
DRY_RUN=0
TIMEZONE="Asia/Shanghai"

log()  { printf '\033[1;36m[学研版]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[警告]\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31m[错误]\033[0m %s\n' "$*" >&2; exit 1; }

usage() {
  sed -n '2,15p' "$0"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-packages)   DO_PACKAGES=0 ;;
    --no-locale)     DO_LOCALE=0 ;;
    --no-config)     DO_CONFIG=0 ;;
    --no-rime)       DO_RIME=0 ;;
    --no-helpers)    DO_HELPERS=0 ;;
    --with-apps)     WITH_APPS=1 ;;
    --with-academic) WITH_ACADEMIC=1 ;;
    --with-hidpi)    WITH_HIDPI=1 ;;
    --with-hid-apple) WITH_HID_APPLE=1 ;;
    --with-proxy)    WITH_PROXY=1 ;;
    --timezone)      TIMEZONE="$2"; shift ;;
    --yes|-y)        ASSUME_YES=1 ;;
    --dry-run)       DRY_RUN=1 ;;
    --help|-h)       usage; exit 0 ;;
    *) die "未知参数: $1（--help 查看用法）" ;;
  esac
  shift
done

BACKUP_DIR="$BACKUP_ROOT-$(date +%Y%m%d-%H%M%S)"
PKGS=()

run() {
  if (( DRY_RUN )); then
    printf '\033[2m[dry-run]\033[0m'
    printf ' %q' "$@"
    printf '\n'
    return 0
  fi
  "$@"
}

backup_file() {
  local path="$1" rel
  rel="${path#"$HOME"/}"
  if [[ -e "$path" || -L "$path" ]]; then
    run install -Dm644 -- "$path" "$BACKUP_DIR/$rel"
    log "已备份 $path -> $BACKUP_DIR/$rel"
  fi
}

deploy() {
  local src="$REPO_DIR/$1" dst="$2"
  backup_file "$dst"
  run install -Dm644 -- "$src" "$dst"
  log "已部署 $1 -> $dst"
}

read_pkgs() {
  local file="$1" pkg
  PKGS=()
  while IFS= read -r pkg; do
    pkg="${pkg%%#*}"
    [[ -z "${pkg//[[:space:]]/}" ]] && continue
    PKGS+=("$pkg")
  done < "$REPO_DIR/packages/$file"
}

ask() {
  local prompt="$1" default="$2" ans
  if (( ASSUME_YES )); then
    return 0
  fi
  read -r -p "$prompt [$default]: " ans
  case "${ans:-$default}" in
    y|Y|yes|YES|是) return 0 ;;
    *) return 1 ;;
  esac
}

section() { printf '\n\033[1;36m== %s ==\033[0m\n' "$*"; }

# ---------- 0. 环境检查 ----------
section "环境检查"
command -v omarchy >/dev/null 2>&1 || warn "未检测到 omarchy 命令；本仓库面向 Omarchy 系系统，配置仍会安装"
command -v git >/dev/null 2>&1 || die "缺少 git，请先安装"

# ---------- 1. 核心软件包 ----------
if (( DO_PACKAGES )); then
  section "核心软件包"

  # 交互式询问可选软件包（--yes 时自动接受）
  if (( ! WITH_APPS )) && ask "安装中文应用（微信/钉钉/飞书/WPS，AUR）？" "n"; then
    WITH_APPS=1
  fi
  if (( ! WITH_ACADEMIC )) && ask "安装学术软件栈（Zotero/Obsidian/Xournal++/OCR/Pandoc/TeX Live）？" "y"; then
    WITH_ACADEMIC=1
  fi

  read_pkgs core.txt
  if (( ${#PKGS[@]} > 0 )); then
    run sudo pacman -S --needed --noconfirm "${PKGS[@]}"
  fi

  if (( WITH_APPS || WITH_ACADEMIC )); then
    if ! command -v yay >/dev/null 2>&1 && ! command -v paru >/dev/null 2>&1; then
      die "可选软件包需要 AUR 助手（yay/paru），请先安装"
    fi
  fi

  if (( WITH_APPS )); then
    read_pkgs apps.txt
    if (( ${#PKGS[@]} > 0 )); then
      log "安装中文应用（AUR）..."
      if command -v yay >/dev/null 2>&1; then
        run yay -S --needed --noconfirm "${PKGS[@]}"
      else
        run paru -S --needed --noconfirm "${PKGS[@]}"
      fi
    fi
  fi

  if (( WITH_ACADEMIC )); then
    read_pkgs academic.txt
    if (( ${#PKGS[@]} > 0 )); then
      log "安装学术软件栈..."
      if command -v yay >/dev/null 2>&1; then
        run yay -S --needed --noconfirm "${PKGS[@]}"
      else
        run paru -S --needed --noconfirm "${PKGS[@]}"
      fi
    fi
  fi
else
  warn "跳过软件包安装 (--no-packages)"
fi

# ---------- 2. 中文区域设置 ----------
if (( DO_LOCALE )); then
  section "中文区域设置 (zh_CN.UTF-8)"
  run sudo "$REPO_DIR/scripts/setup-locale.sh" --timezone "$TIMEZONE"
else
  warn "跳过区域设置 (--no-locale)"
fi

# ---------- 3. 部署配置（自动备份原文件） ----------
if (( DO_CONFIG )); then
  section "部署配置"
  run mkdir -p "$BACKUP_DIR"
  deploy "config/fontconfig/fonts.conf" "$HOME/.config/fontconfig/fonts.conf"
  deploy "config/fcitx5/profile" "$HOME/.config/fcitx5/profile"
  deploy "config/hypr/hyprland.lua" "$HOME/.config/hypr/hyprland.lua"
  deploy "config/omarchy/shell.json" "$HOME/.config/omarchy/shell.json"
  deploy "config/omarchy/shell.toml" "$HOME/.config/omarchy/shell.toml"
  deploy "config/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml"
  deploy "config/foot/foot.ini" "$HOME/.config/foot/foot.ini"
  deploy "config/kitty/kitty.conf" "$HOME/.config/kitty/kitty.conf"
  deploy "config/ghostty/config" "$HOME/.config/ghostty/config"
else
  warn "跳过配置部署 (--no-config)"
fi

# ---------- 4. Rime 输入方案 ----------
if (( DO_RIME )); then
  section "Rime 输入方案（rime-ice 雾凇拼音）"
  run "$REPO_DIR/scripts/install-rime-ice.sh"
else
  warn "跳过 Rime 安装 (--no-rime)"
fi

# ---------- 5. 中文小工具 ----------
if (( DO_HELPERS )); then
  section "中文小工具（sudo 密码弹窗、健康检查）"
  deploy "scripts/gui-password.py" "$HOME/.local/bin/gui-password"
  deploy "scripts/sudo-askpass" "$HOME/.local/bin/sudo-askpass"
  deploy "scripts/health-check.sh" "$HOME/.local/bin/omarchy-health-check"
  run chmod +x "$HOME/.local/bin/gui-password" "$HOME/.local/bin/sudo-askpass" "$HOME/.local/bin/omarchy-health-check"
else
  warn "跳过小工具安装 (--no-helpers)"
fi

# ---------- 6. 可选硬件模块 ----------
if (( WITH_HIDPI )); then
  section "硬件模块：HiDPI 缩放"
  run "$REPO_DIR/hardware/hidpi/install.sh"
elif (( ! ASSUME_YES )) && ask "安装 HiDPI 缩放模块？（4K 屏推荐）" "n"; then
  section "硬件模块：HiDPI 缩放"
  run "$REPO_DIR/hardware/hidpi/install.sh"
fi

if (( WITH_HID_APPLE )); then
  section "硬件模块：Apple 键盘 fn 键"
  run "$REPO_DIR/hardware/hid_apple/install.sh"
elif (( ! ASSUME_YES )) && ask "安装 Apple 键盘 fn 键模块？（仅 Apple 键盘）" "n"; then
  section "硬件模块：Apple 键盘 fn 键"
  run "$REPO_DIR/hardware/hid_apple/install.sh"
fi

# ---------- 7. 代理模板（可选） ----------
if (( WITH_PROXY )) || ask "安装代理环境变量模板？（用于访问 GitHub 等）" "n"; then
  section "代理环境变量模板"
  if [[ -e "$HOME/.config/environment.d/proxy.conf" ]]; then
    warn "已存在 ~/.config/environment.d/proxy.conf，未覆盖；请参考 templates/environment.d/proxy.conf.example 自行修改"
  else
    backup_file "$HOME/.config/environment.d/proxy.conf"
    run mkdir -p "$HOME/.config/environment.d"
    run install -Dm644 "$REPO_DIR/templates/environment.d/proxy.conf.example" "$HOME/.config/environment.d/proxy.conf"
    log "已生成 ~/.config/environment.d/proxy.conf（请按需修改代理端口）"
  fi
fi

# ---------- 完成 ----------
section "完成"
log "配置备份目录: $BACKUP_DIR"
printf '\n下一步:\n'
printf '  1. 重新登录（或执行 omarchy restart terminal）让终端配置生效\n'
printf '  2. 输入法：重新登录后按 Ctrl+Space 切换到 rime\n'
printf '  3. 体检：omarchy-health-check --no-sudo\n'
printf '  4. 遇到问题：docs/faq.md 或到仓库提 Issue\n'
if (( DRY_RUN )); then
  printf '\n（以上为 dry-run 预览，未实际执行任何操作）\n'
fi
