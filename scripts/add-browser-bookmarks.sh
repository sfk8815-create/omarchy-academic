#!/usr/bin/env bash
# Omarchy 学研版 —— 将 Sovena / MCP Cockpit 管理页面加入默认浏览器书签栏
#
# 用法（需要 root，install.sh 会自动以 sudo 调用）:
#   sudo ./scripts/add-browser-bookmarks.sh
#   sudo ./scripts/add-browser-bookmarks.sh --dry-run   # 只打印将要写入的策略
#
# 支持：Chromium / Google Chrome / Brave / Microsoft Edge（托管书签策略）
#       Firefox（policies.json，书签放到工具栏）
set -u

SOVENA_URL="http://localhost:8765"
MCP_URL="http://127.0.0.1:8899"

DRY_RUN=0
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN=1
fi

note() { printf '\033[1;33m%s\033[0m\n' "$*"; }
log()  { printf '\033[1;32m%s\033[0m\n' "$*"; }

write_json() {
  local file="$1"
  local content="$2"
  if (( DRY_RUN )); then
    printf '%s\n' "---- 将写入 $file ----"
    printf '%s\n' "$content"
    return 0
  fi
  mkdir -p "$(dirname "$file")"
  printf '%s\n' "$content" >"$file"
  chmod 644 "$file"
  log "已写入 $file"
}

chromium_bookmarks_json() {
  local file="$1"
  local existing='{"ManagedBookmarks": []}'
  if [[ -f "$file" ]]; then
    existing=$(cat "$file")
  fi
  jq --arg sname "Sovena 监管台" --arg surl "$SOVENA_URL" \
     --arg mname "MCP Cockpit" --arg murl "$MCP_URL" '
      .ManagedBookmarks //= [] |
      if ([.ManagedBookmarks[]? | select(.url == $surl)] | length) == 0
        then .ManagedBookmarks += [{"name": $sname, "url": $surl}] else . end |
      if ([.ManagedBookmarks[]? | select(.url == $murl)] | length) == 0
        then .ManagedBookmarks += [{"name": $mname, "url": $murl}] else . end
    ' <<<"$existing"
}

firefox_bookmarks_json() {
  local file="$1"
  local existing='{"policies": {"Bookmarks": []}}'
  if [[ -f "$file" ]]; then
    existing=$(cat "$file")
  fi
  jq --arg sname "Sovena 监管台" --arg surl "$SOVENA_URL" \
     --arg mname "MCP Cockpit" --arg murl "$MCP_URL" '
      .policies.Bookmarks //= [] |
      if ([.policies.Bookmarks[]? | select(.URL == $surl)] | length) == 0
        then .policies.Bookmarks += [{"Title": $sname, "URL": $surl, "Placement": "toolbar"}]
        else . end |
      if ([.policies.Bookmarks[]? | select(.URL == $murl)] | length) == 0
        then .policies.Bookmarks += [{"Title": $mname, "URL": $murl, "Placement": "toolbar"}]
        else . end
    ' <<<"$existing"
}

main() {
  command -v jq >/dev/null 2>&1 || { echo "[错误] 需要 jq" >&2; exit 1; }

  local desktop=""
  if command -v xdg-settings >/dev/null 2>&1; then
    desktop=$(xdg-settings get default-web-browser 2>/dev/null || true)
  fi

  local policy_dir=""
  local firefox=0

  case "$desktop" in
    *chromium*)
      policy_dir="/etc/chromium/policies/managed" ;;
    *google-chrome*)
      policy_dir="/etc/opt/chrome/policies/managed" ;;
    *brave*)
      policy_dir="/etc/brave/policies/managed" ;;
    *microsoft-edge*)
      policy_dir="/etc/microsoft-edge/policies/managed" ;;
    *firefox*)
      firefox=1 ;;
  esac

  if [[ -z "$policy_dir" ]] && (( firefox == 0 )); then
    if [[ -z "$desktop" ]]; then
      note "未检测到默认浏览器（xdg-settings 无输出），跳过书签写入。"
    else
      note "默认浏览器 $desktop 不在支持列表（chromium/google-chrome/brave/microsoft-edge/firefox），跳过书签写入。"
    fi
    exit 0
  fi

  if (( firefox == 1 )); then
    write_json "/etc/firefox/policies/policies.json" "$(firefox_bookmarks_json /etc/firefox/policies/policies.json)"
  else
    write_json "$policy_dir/bookmarks.json" "$(chromium_bookmarks_json "$policy_dir/bookmarks.json")"
  fi

  log "完成：Sovena（$SOVENA_URL）与 MCP Cockpit（$MCP_URL）已加入默认浏览器书签栏。"
  note "重启浏览器后生效。"
}

main "$@"
