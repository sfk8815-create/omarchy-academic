#!/usr/bin/env bash
# Omarchy 学研版 —— 可选模块：sovena（缙云文采）文献流系统
# 上游: https://github.com/sfk8815-create/sovena (MIT，作者自有项目)
set -euo pipefail

SOVENA_URL="https://github.com/sfk8815-create/sovena.git"
DEST="${SOVENA_DIR:-$HOME/sovena}"

command -v uv >/dev/null 2>&1 || {
  echo "[错误] 需要 uv：curl -LsSf https://astral.sh/uv/install.sh | sh" >&2
  exit 1
}

if [[ ! -d "$DEST/.git" ]]; then
  git clone "$SOVENA_URL" "$DEST"
else
  git -C "$DEST" pull --ff-only
fi

cd "$DEST"
uv sync

echo
echo "完成：sovena 依赖已就绪。"
echo "启动: cd $DEST && uv run sovena"
echo "要求: Zotero 7+ 正在运行；检索需要 embedding 服务（详见 sovena README）"
echo "卸载: rm -rf $DEST"
