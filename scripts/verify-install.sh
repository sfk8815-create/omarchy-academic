#!/usr/bin/env bash
# Omarchy 学研版 —— 安装后验收清单（post-install verification）
#
# 用法:
#   ./scripts/verify-install.sh               # 完整验收（默认必装项）
#   ./scripts/verify-install.sh --core-only   # 只验收核心中文化（与 install.sh --core-only 对应）
#   ./scripts/verify-install.sh --with-academic   # 追加验收学术软件栈
#   ./scripts/verify-install.sh --with-apps       # 追加验收中文办公/通讯应用
#   ./scripts/verify-install.sh --with-desktop    # 追加验收 OpenScience / Aether 模块
#
# 退出码: 0 = 全部通过（无 FAIL）  1 = 有 FAIL  2 = 参数错误
set -u

CORE_ONLY=0
WITH_ACADEMIC=0
WITH_APPS=0
WITH_DESKTOP=0

usage() {
  sed -n '2,12p' "$0"
}

while (($# > 0)); do
  case "$1" in
    --core-only)     CORE_ONLY=1 ;;
    --with-academic) WITH_ACADEMIC=1 ;;
    --with-apps)     WITH_APPS=1 ;;
    --with-desktop)  WITH_DESKTOP=1 ;;
    -h|--help)       usage; exit 0 ;;
    *)
      printf '未知参数: %s\n（--help 查看用法）\n' "$1" >&2
      exit 2
      ;;
  esac
  shift
done

pass=0
fail=0
warn=0

ok()   { printf '  \033[1;32mPASS\033[0m  %s\n' "$1"; pass=$((pass + 1)); }
bad()  { printf '  \033[1;31mFAIL\033[0m  %s\n' "$1"; fail=$((fail + 1)); }
note() { printf '  \033[1;33mWARN\033[0m  %s\n' "$1"; warn=$((warn + 1)); }
section() { printf '\n\033[1;36m== %s ==\033[0m\n' "$1"; }

has_cmd() { command -v "$1" >/dev/null 2>&1; }
has_pkg() { pacman -Q "$1" >/dev/null 2>&1; }

section "系统与区域"

if rg -q '^ID=omarchy$' /etc/os-release 2>/dev/null; then
  ver=$(sed -n 's/^BUILD_ID=//p' /etc/os-release | tr -d '"' | head -n1)
  ok "系统为 Omarchy ${ver:-未知版本}"
elif rg -q '^ID=arch$|^ID_LIKE=.*arch' /etc/os-release 2>/dev/null; then
  note "当前为 Arch 系环境（干净 chroot / 容器测试）"
else
  bad "不是 Omarchy/Arch 环境"
fi

if [[ "${LANG:-}" == "zh_CN.UTF-8" ]]; then
  ok "LANG=zh_CN.UTF-8"
else
  note "LANG=${LANG:-未设置}（预期 zh_CN.UTF-8；可能尚未重新登录）"
fi

if rg -q '^LANG=zh_CN\.UTF-8' /etc/locale.conf 2>/dev/null; then
  ok "/etc/locale.conf 已写入 LANG=zh_CN.UTF-8"
else
  bad "/etc/locale.conf 缺少 LANG=zh_CN.UTF-8"
fi

if rg -q '^zh_CN\.UTF-8' /etc/locale.gen 2>/dev/null; then
  ok "locale.gen 已启用 zh_CN.UTF-8"
else
  bad "locale.gen 未启用 zh_CN.UTF-8"
fi

if locale -a 2>/dev/null | rg -qi '^zh_CN\.'; then
  ok "zh_CN.UTF-8 已生成"
else
  bad "zh_CN.UTF-8 未生成（需运行 locale-gen 或 localectl set-locale）"
fi

if readlink -f /etc/localtime 2>/dev/null | rg -q 'Asia/Shanghai$'; then
  ok "时区 Asia/Shanghai"
else
  note "时区非 Asia/Shanghai（install.sh --timezone 可自定义，可接受）"
fi

section "核心软件包"

if ! has_cmd pacman; then
  bad "pacman 不可用（不是 Arch 系环境）"
else
  core_pkgs=(fcitx5 fcitx5-configtool fcitx5-gtk fcitx5-qt fcitx5-rime librime noto-fonts-cjk ttf-jetbrains-mono-nerd-basic)
  for pkg in "${core_pkgs[@]}"; do
    if has_pkg "$pkg"; then
      ok "$pkg 已安装"
    else
      bad "$pkg 未安装"
    fi
  done
fi

section "中文字体"

if has_cmd fc-list; then
  if fc-list :lang=zh family 2>/dev/null | rg -qi 'Noto Sans CJK SC'; then
    ok "Noto Sans CJK SC 可用"
  else
    bad "未找到 Noto Sans CJK SC（中文字体缺失）"
  fi
else
  bad "fc-list 不可用（fontconfig 未安装）"
fi

section "配置部署"

configs=(
  "fontconfig/fonts.conf"
  "fcitx5/profile"
  "fcitx5/conf/classicui.conf"
  "hypr/hyprland.lua"
  "omarchy/shell.json"
  "omarchy/shell.toml"
  "alacritty/alacritty.toml"
  "foot/foot.ini"
  "kitty/kitty.conf"
  "ghostty/config"
)

for rel in "${configs[@]}"; do
  if [[ -f "$HOME/.config/$rel" ]]; then
    ok "$HOME/.config/$rel"
  else
    bad "$HOME/.config/$rel 缺失"
  fi
done

if rg -q '^Font="Sans 12"$' "$HOME/.config/fcitx5/conf/classicui.conf" 2>/dev/null; then
  ok "fcitx5 候选词窗口字号 Sans 12"
else
  bad "classicui.conf 未设置候选词字号 Sans 12"
fi

if rg -q 'GTK_IM_MODULE.*fcitx' "$HOME/.config/hypr/hyprland.lua" 2>/dev/null; then
  ok "Hyprland 已注入 fcitx 环境变量"
else
  bad "Hyprland 缺少 fcitx 环境变量"
fi

section "Rime 输入法"

rime_dir="$HOME/.local/share/fcitx5/rime"
if [[ -d "$rime_dir" ]]; then
  ok "Rime 用户目录存在"
  if [[ -f "$rime_dir/default.custom.yaml" ]]; then
    ok "学研版补丁 default.custom.yaml 已应用"
  else
    bad "未找到 default.custom.yaml（rime-ice 补丁未应用）"
  fi
  if [[ -f "$rime_dir/custom_phrase.txt" ]]; then
    ok "custom_phrase.txt 已生成"
  else
    note "未生成 custom_phrase.txt（可选）"
  fi
else
  bad "Rime 用户目录不存在（rime-ice 未安装/未部署）"
fi

section "输入法进程"

if pgrep -x fcitx5 >/dev/null 2>&1; then
  ok "fcitx5 正在运行"
else
  note "fcitx5 未运行（无图形会话/未登录时属正常）"
fi

section "备份"

if find "$HOME" -maxdepth 1 -type d -name '.omarchy-academic-backup-*' | rg -q .; then
  ok "存在安装备份 ~/.omarchy-academic-backup-*"
else
  note "未找到备份目录（从未安装过本仓库时可忽略）"
fi

if (( CORE_ONLY == 0 )); then
  section "默认必装（sovena / MCP Cockpit）"

  if [[ -d "$HOME/sovena/.git" ]]; then
    ok "sovena 已克隆（~/sovena）"
  else
    bad "sovena 未安装（~/sovena 不存在）"
  fi

  if [[ -d "$HOME/mcp-cockpit/.git" ]]; then
    ok "mcp-cockpit 已克隆（~/mcp-cockpit）"
  else
    bad "mcp-cockpit 未安装（~/mcp-cockpit 不存在）"
  fi

  if [[ -f "$HOME/.config/mcp-hub/servers.json" ]]; then
    ok "mcp-hub 网关配置存在（~/.config/mcp-hub/servers.json）"
  else
    note "未找到 ~/.config/mcp-hub/servers.json（mcp-cockpit 内 install.sh 未跑完？）"
  fi
fi

if (( WITH_ACADEMIC == 1 )); then
  section "学术软件栈"

  academic_pkgs=(pandoc texlive-latex tesseract tesseract-data-chi_sim ocrmypdf typst calibre zathura-pdf-mupdf jupyter-notebook xournalpp zettlr obsidian libreoffice-fresh libreoffice-fresh-zh-cn zotero-bin)
  for pkg in "${academic_pkgs[@]}"; do
    if has_pkg "$pkg"; then
      ok "$pkg 已安装"
    else
      bad "$pkg 未安装"
    fi
  done
fi

if (( WITH_APPS == 1 )); then
  section "中文办公/通讯应用"

  app_pkgs=(wechat-universal-bwrap dingtalk-bin feishu-bin wps-office wps-office-mui-zh-cn ttf-wps-fonts)
  for pkg in "${app_pkgs[@]}"; do
    if has_pkg "$pkg"; then
      ok "$pkg 已安装"
    else
      bad "$pkg 未安装"
    fi
  done
fi

if (( WITH_DESKTOP == 1 )); then
  section "科研工作台（OpenScience / Aether）"

  if has_cmd osd; then
    ok "Open Science Desktop CLI（osd）可用"
  else
    note "osd 不在 PATH（模块可能仅安装了仓库，未加入 PATH）"
  fi
  if [[ -d "$HOME/aether" ]] || [[ -d "$HOME/Aether" ]]; then
    ok "Aether 已克隆"
  else
    note "未找到 ~/aether 或 ~/Aether（模块未安装）"
  fi
fi

section "汇总"

printf '  PASS %d · FAIL %d · WARN %d\n' "$pass" "$fail" "$warn"
if (( fail > 0 )); then
  printf '验收未通过（有 FAIL 项），请按 docs/install.md 排查。\n'
  exit 1
fi
if (( CORE_ONLY == 1 )); then
  printf '核心中文化验收通过（可选模块未检查，可用 --with-* 追加）。\n'
else
  printf '验收全部通过。\n'
fi
exit 0
