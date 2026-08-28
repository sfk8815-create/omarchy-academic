#!/usr/bin/env bash
# Omarchy 学研版 —— 卸载 / 恢复
#
#   ./uninstall.sh --list      列出所有备份
#   ./uninstall.sh --restore <备份目录>   从指定备份恢复配置
#   ./uninstall.sh             未指定参数时打印用法
set -euo pipefail

BACKUP_ROOT="$HOME/.omarchy-academic-backup"

usage() {
  sed -n '2,8p' "$0"
}

cmd="${1:-}"

case "$cmd" in
  --list)
    shopt -s nullglob
    dirs=("$BACKUP_ROOT"-*)
    if (( ${#dirs[@]} == 0 )); then
      echo "没有找到备份目录"
      exit 0
    fi
    for d in "${dirs[@]}"; do
      echo "$d  ($(find "$d" -type f | wc -l) 个文件)"
    done
    ;;
  --restore)
    backup="${2:-}"
    [[ -n "$backup" ]] || { usage; exit 1; }
    if [[ ! -d "$backup" ]]; then
      echo "备份目录不存在: $backup" >&2
      exit 1
    fi
    count=0
    while IFS= read -r -d '' f; do
      rel="${f#"$backup"/}"
      dst="$HOME/$rel"
      mkdir -p "$(dirname "$dst")"
      cp -a "$f" "$dst"
      count=$((count + 1))
      echo "恢复 $rel"
    done < <(find "$backup" -type f -print0)
    echo "完成：共恢复 $count 个文件到 $HOME"
    ;;
  *)
    usage
    ;;
esac
