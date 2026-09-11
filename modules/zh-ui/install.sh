#!/usr/bin/env bash
# Omarchy 学研版 —— 可选模块：Omarchy 界面简体中文化
# 上游: https://github.com/QueedWen/omarchy-zh-cn (MIT)
# 说明: 汉化主菜单/系统面板/天气/快捷键面板；不修改 /usr/share/omarchy
set -euo pipefail

SRC_URL="https://github.com/QueedWen/omarchy-zh-cn.git"
DEST="$HOME/.local/share/omarchy-zh-cn"

command -v omarchy >/dev/null 2>&1 || { echo "[错误] 需要 Omarchy 环境" >&2; exit 1; }
command -v jq >/dev/null 2>&1 || { echo "[错误] 需要 jq" >&2; exit 1; }
command -v node >/dev/null 2>&1 || { echo "[错误] 需要 Node.js" >&2; exit 1; }
pgrep -f omarchy-shell >/dev/null 2>&1 || echo "[警告] 未检测到 Omarchy Shell，安装后请重新登录"

if [[ ! -d "$DEST/.git" ]]; then
  git clone "$SRC_URL" "$DEST"
else
  git -C "$DEST" pull --ff-only
fi

cd "$DEST"

# 兼容不同 Omarchy 4.x 小版本：上游脚本硬编码了一批内置插件名，
# 在当前版本不存在的插件（如 4.0.1 已无 omarchy.audio/bluetooth 等）会
# 导致 omarchy plugin clone 失败。这里在运行前按实际插件目录过滤。
python3 - "$DEST/install.sh" <<'PYEOF'
import sys

path = sys.argv[1]
with open(path, encoding="utf-8") as f:
    src = f.read()

marker = "usage() {"
filter_block = """filter_plugins() {
  local available
  available=$(find /usr/share/omarchy/shell/plugins -mindepth 1 -maxdepth 1 -type d -printf '%f\\n' 2>/dev/null)
  local filtered=()
  local id
  local base
  for id in "${PLUGIN_IDS[@]}"; do
    base="${id#omarchy.}"
    if grep -Fxq "$base" <<<"$available"; then
      filtered+=("$id")
    else
      echo "[zh-cn] 跳过当前 Omarchy 版本不存在的内置插件：$id"
    fi
  done
  PLUGIN_IDS=("${filtered[@]}")
}
filter_plugins

"""
if marker in src and "filter_plugins" not in src:
    src = src.replace(marker, filter_block + marker, 1)
    with open(path, "w", encoding="utf-8") as f:
        f.write(src)
    print("[zh-ui] 已注入插件兼容过滤")
else:
    print("[zh-ui] 无需注入（已过滤或脚本结构变化）")
PYEOF

# omarchy-plugin-catalog 在部分 Omarchy 4.x 上为空/报错，导致 zh-sync 遇到
# 目录里没有的插件时直接抛错。改为跳过缺失插件并给出警告，避免整个模块失败。
python3 - "$DEST/bin/omarchy-zh-sync" <<'PYEOF'
import sys

path = sys.argv[1]
with open(path, encoding="utf-8") as f:
    src = f.read()

old = "if (!entry) throw new Error(`找不到系统插件：${id}`);"
new = (
    "if (!entry) { "
    "console.warn(`[zh-cn] 跳过当前版本不存在的系统插件：${id}`); continue; "
    "}"
)
if old in src:
    src = src.replace(old, new, 1)
    with open(path, "w", encoding="utf-8") as f:
        f.write(src)
    print("[zh-ui] 已修补 zh-sync 跳过缺失插件")
else:
    print("[zh-ui] zh-sync 无需修补（结构变化或已修补）")
PYEOF

# Omarchy 4.0.3 的 manifestHasKind() 用 Array.isArray() 判断插件类型，而克隆菜单的
# 清单要经过 Instantiator 模型才送到面板加载器，kinds 数组在那里变成 QV4 序列对象，
# 判断因此为假：克隆菜单拿不到 appLibrary，“应用” 子菜单一直是空的
# （上游 issue: omacom/omarchy#11282，PR: #11285）。
# 上游修好前，让 zh-sync 给克隆菜单自带一份应用库兜底：把系统自带的 AppLibrary.qml
# 拷进克隆，并把 Menu.qml 的 appLibrary 绑定改成「宿主有就用宿主，没有就用自带的」。
python3 - "$DEST/bin/omarchy-zh-sync" <<'PYEOF'
import sys

path = sys.argv[1]
with open(path, encoding="utf-8") as f:
    src = f.read()

menu_start = '      if (sourceId === "omarchy.menu" && path.basename(file) === "Menu.qml") {'
closing = "      }" + chr(10)
menu_patch = """        // Omarchy 4.0.3 只给第一方菜单注入 shell.appLibrary：克隆菜单的清单要经过
        // Instantiator 模型才到达面板加载器，kinds 数组在那里变成 QV4 序列，
        // manifestHasKind() 因此返回 false，菜单拿到的 appLibrary 是 null，
        // “应用” 子菜单（provider: apps）就一直是空的。上游：omacom/omarchy#11282。
        // 兜底做法是让克隆自带一份同样的应用库，宿主没给时用它。
        const appLibraryBinding = "  readonly property var appLibrary: root.shell ? root.shell.appLibrary : null";
        const appLibraryReplacement = [
          "  // 宿主只给第一方菜单注入 appLibrary（omacom/omarchy#11282），克隆菜单拿到的是",
          "  // null，“应用” 子菜单会一直是空的。这里自带一份同样的应用库兜底。",
          "  LocalAppLibrary { id: localAppLibrary }",
          "  readonly property var appLibrary: root.shell && root.shell.appLibrary ? root.shell.appLibrary : localAppLibrary"
        ].join("\\n");
        if (!after.includes(appLibraryBinding)) throw new Error("菜单插件结构已变化：appLibrary 绑定");
        after = after.replace(appLibraryBinding, appLibraryReplacement);
"""

copy_anchor = "    const backup = `${targetDir}.zh-old-${process.pid}`;"
copy_patch = """    if (sourceId === "omarchy.menu") {
      // Menu.qml 里插入的 LocalAppLibrary 兜底要求应用库与它同目录。每次同步都从
      // 当前安装的 Omarchy 拷贝一份，克隆就始终跟系统版本一致。
      const servicesDir = "/usr/share/omarchy/shell/services";
      fs.copyFileSync(path.join(servicesDir, "AppLibrary.qml"), path.join(stage, "LocalAppLibrary.qml"));
      fs.copyFileSync(path.join(servicesDir, "AppSearch.js"), path.join(stage, "AppSearch.js"));
    }

"""

if "LocalAppLibrary" in src:
    print("[zh-ui] zh-sync 已带应用库兜底，无需修补")
elif src.count(menu_start) != 1 or src.count(copy_anchor) != 1:
    print("[zh-ui] 警告：zh-sync 结构已变化，未注入应用库兜底（克隆菜单的“应用”子菜单会为空）")
else:
    start = src.index(menu_start)
    end = src.index(chr(10) + closing, start) + len(chr(10) + closing)
    block = src[start:end]
    src = src[:start] + block[: -len(closing)] + menu_patch + closing + src[end:]
    src = src.replace(copy_anchor, copy_patch + copy_anchor, 1)
    with open(path, "w", encoding="utf-8") as f:
        f.write(src)
    print("[zh-ui] 已修补 zh-sync：克隆菜单自带应用库兜底（应用子菜单不再为空）")
PYEOF

./install.sh --dry-run
./install.sh

echo
echo "完成：Omarchy 界面已汉化。"
echo "手动同步: omarchy-zh-sync"
echo "卸载: cd $DEST && ./uninstall.sh"
