#!/usr/bin/env bash
# Omarchy 学研版 (Omarchy Academic) —— 一键安装脚本
#
# 用法:
#   ./install.sh                    交互式安装（推荐）
#   ./install.sh --yes              全部可选模块（除硬件模块外）
#   ./install.sh --with-apps --with-academic
#   ./install.sh --with-zh-ui --with-lunar --with-cn-mirrors
#   ./install.sh --with-desktop
#   ./install.sh --with-macbook-nvidia-off     # 仅 MacBookPro11,3
#   ./install.sh --no-sovena --no-mcp-cockpit     # 跳过默认必装的文献流/MCP 网关
#   ./install.sh --no-browser-bookmarks           # 跳过浏览器书签（Sovena/MCP 管理页）
#   ./install.sh --core-only                      # 只装核心中文化（含 Rime/终端/字体）
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
WITH_ZH_UI=0
WITH_LUNAR=0
WITH_CN_MIRRORS=0
WITH_DESKTOP=0
WITH_MACBOOK_NVIDIA_OFF=0
DO_SOVENA=1
DO_MCP=1
DO_BOOKMARKS=1
CORE_ONLY=0
ASSUME_YES=0
DRY_RUN=0
TIMEZONE="Asia/Shanghai"

# sudo 优先使用本机 askpass（中文密码弹窗）；没有 askpass 时回退普通 sudo
SUDO_CMD=(sudo)
if [[ -x "${SUDO_ASKPASS:-$HOME/.local/bin/sudo-askpass}" ]]; then
  SUDO_ASKPASS="${SUDO_ASKPASS:-$HOME/.local/bin/sudo-askpass}"
  export SUDO_ASKPASS
  SUDO_CMD=(sudo -A)
fi

log()  { printf '\033[1;36m[学研版]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[警告]\033[0m %s\n' "$*"; }
die()  { printf '\033[1;31m[错误]\033[0m %s\n' "$*" >&2; exit 1; }

usage() {
  sed -n '2,22p' "$0"
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
    --with-zh-ui)    WITH_ZH_UI=1 ;;
    --with-lunar)    WITH_LUNAR=1 ;;
    --with-cn-mirrors) WITH_CN_MIRRORS=1 ;;
    --with-desktop)  WITH_DESKTOP=1 ;;
    --with-macbook-nvidia-off) WITH_MACBOOK_NVIDIA_OFF=1 ;;
    --no-sovena)     DO_SOVENA=0 ;;
    --no-mcp-cockpit) DO_MCP=0 ;;
    --no-browser-bookmarks) DO_BOOKMARKS=0 ;;
    --core-only)     CORE_ONLY=1 ;;
    --timezone)      TIMEZONE="$2"; shift ;;
    --yes|-y)        ASSUME_YES=1 ;;
    --dry-run)       DRY_RUN=1 ;;
    --help|-h)       usage; exit 0 ;;
    *) die "未知参数: $1（--help 查看用法）" ;;
  esac
  shift
done

if (( CORE_ONLY )); then
  WITH_APPS=0
  WITH_ACADEMIC=0
  WITH_HIDPI=0
  WITH_HID_APPLE=0
  WITH_PROXY=0
  WITH_ZH_UI=0
  WITH_LUNAR=0
  WITH_CN_MIRRORS=0
  WITH_DESKTOP=0
  WITH_MACBOOK_NVIDIA_OFF=0
  DO_SOVENA=0
  DO_MCP=0
  DO_BOOKMARKS=0
  ASSUME_YES=0
fi

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
  if (( ! CORE_ONLY )); then
    if (( ! WITH_APPS )) && ask "安装中文应用（微信/钉钉/飞书/WPS，AUR）？" "n"; then
      WITH_APPS=1
    fi
    if (( ! WITH_ACADEMIC )) && ask "安装学术软件栈（Zotero/Obsidian/Xournal++/OCR/Pandoc/TeX Live）？" "y"; then
      WITH_ACADEMIC=1
    fi
  fi

  read_pkgs core.txt
  if (( ${#PKGS[@]} > 0 )); then
    run "${SUDO_CMD[@]}" pacman -S --needed --noconfirm "${PKGS[@]}"
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
  run "${SUDO_CMD[@]}" "$REPO_DIR/scripts/setup-locale.sh" --timezone "$TIMEZONE"
else
  warn "跳过区域设置 (--no-locale)"
fi

# ---------- 3. 部署配置（自动备份原文件） ----------
if (( DO_CONFIG )); then
  section "部署配置"
  run mkdir -p "$BACKUP_DIR"
  deploy "config/fontconfig/fonts.conf" "$HOME/.config/fontconfig/fonts.conf"
  deploy "config/fcitx5/profile" "$HOME/.config/fcitx5/profile"
  deploy "config/fcitx5/conf/classicui.conf" "$HOME/.config/fcitx5/conf/classicui.conf"
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

# ---------- 5b. 文献流与 MCP 网关（默认必装） ----------
if (( DO_SOVENA )); then
  section "sovena 文献流系统（默认必装）"
  run "$REPO_DIR/modules/sovena/install.sh"
else
  warn "跳过 sovena 安装 (--no-sovena)"
fi

if (( DO_MCP )); then
  section "MCP Cockpit（默认必装）"
  run "$REPO_DIR/modules/mcp-cockpit/install.sh"
else
  warn "跳过 MCP Cockpit 安装 (--no-mcp-cockpit)"
fi

# ---------- 5c. 浏览器书签（Sovena / MCP Cockpit 管理页，默认写入） ----------
if (( DO_BOOKMARKS )) && (( DO_SOVENA || DO_MCP )); then
  section "浏览器书签（Sovena / MCP Cockpit 管理页）"
  run "${SUDO_CMD[@]}" "$REPO_DIR/scripts/add-browser-bookmarks.sh"
else
  warn "跳过浏览器书签写入 (--no-browser-bookmarks)"
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

if (( WITH_MACBOOK_NVIDIA_OFF )); then
  section "硬件模块：MacBookPro11,3 NVIDIA 独显断电"
  run "$REPO_DIR/hardware/macbook-nvidia-off/install.sh"
elif (( ! ASSUME_YES )) && ask "安装 MacBookPro11,3 NVIDIA 独显断电模块？（仅 2013 末/2014 中 15 英寸双显卡 MacBook Pro）" "n"; then
  section "硬件模块：MacBookPro11,3 NVIDIA 独显断电"
  run "$REPO_DIR/hardware/macbook-nvidia-off/install.sh"
fi

# ---------- 6b. 第三方社区模块（来源与许可见 docs/resources.md） ----------
if (( WITH_ZH_UI )) || { (( ! ASSUME_YES )) && ask "安装 Omarchy 界面简体中文化？（第三方 MIT 项目）" "n"; }; then
  section "可选模块：界面汉化（QueedWen/omarchy-zh-cn, MIT）"
  run "$REPO_DIR/modules/zh-ui/install.sh"
fi

if (( WITH_LUNAR )) || { (( ! ASSUME_YES )) && ask "安装中文农历日历？（替换状态栏时钟，第三方 MIT 项目）" "n"; }; then
  section "可选模块：农历日历（garyliu.lunar-calendar, MIT）"
  run "$REPO_DIR/modules/lunar-calendar/install.sh"
fi

if (( WITH_CN_MIRRORS )) || { (( ! ASSUME_YES )) && ask "配置国内镜像与 archlinuxcn 社区仓库？（需要 sudo）" "n"; }; then
  section "可选模块：国内镜像 + archlinuxcn"
  run "${SUDO_CMD[@]}" "$REPO_DIR/scripts/setup-cn-mirrors.sh"
fi

# ---------- 6c. 学术与桌面模块 ----------
if (( WITH_DESKTOP )) || { (( ! ASSUME_YES )) && ask "安装桌面增强（Aether 科研 AI 助手 + Open Science Desktop 科研工作台）？" "n"; }; then
  section "可选模块：桌面增强（Aether + Open Science）"
  run "$REPO_DIR/modules/aether/install.sh"
  run "$REPO_DIR/modules/openscience/install.sh"
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
step=1
if (( DO_SOVENA )); then
  printf '  %d. sovena 文献流: cd ~/sovena && uv run sovena（Zotero 需运行）\n' "$step"; step=$((step + 1))
fi
if (( DO_MCP )); then
  printf '  %d. MCP Cockpit: cd ~/mcp-cockpit && bash scripts/start.sh（网页 127.0.0.1:8899）\n' "$step"; step=$((step + 1))
fi
if (( DO_BOOKMARKS )) && (( DO_SOVENA || DO_MCP )); then
  printf '  %d. 浏览器书签栏已加入 Sovena / MCP Cockpit 管理页（重启浏览器生效）\n' "$step"; step=$((step + 1))
fi
printf '  %d. 重新登录（或执行 omarchy restart terminal）让终端配置生效\n' "$step"; step=$((step + 1))
printf '  %d. 输入法：重新登录后按 Ctrl+Space 切换到 rime\n' "$step"; step=$((step + 1))
printf '  %d. 体检：omarchy-health-check --no-sudo\n' "$step"; step=$((step + 1))
printf '  %d. 遇到问题：docs/faq.md 或到仓库提 Issue\n' "$step"
if (( DRY_RUN )); then
  printf '\n（以上为 dry-run 预览，未实际执行任何操作）\n'
fi
