# 可选模块：Omarchy 界面简体中文化

来源：[QueedWen/omarchy-zh-cn](https://github.com/QueedWen/omarchy-zh-cn)（MIT）

作用：汉化 Omarchy 4 的主菜单、系统面板、天气、快捷键面板等 300+ 项界面文案；不改 `/usr/share/omarchy`，通过用户级插件克隆实现，系统更新后自动重新同步。

安装（install.sh 交互选择，或 `--with-zh-ui`）：

```bash
./install.sh --with-zh-ui
```

该脚本会克隆上游仓库到 `~/.local/share/omarchy-zh-cn`，执行其 `install.sh --dry-run` 与 `install.sh`。

## 本地兼容补丁

安装时会在 `~/.local/share/omarchy-zh-cn/bin/omarchy-zh-sync` 上打两处补丁（可重复执行，结构变化时会跳过并提示）：

1. 跳过当前 Omarchy 版本里不存在的内置插件，避免 `omarchy plugin clone` 中断。
2. **应用菜单兜底**：Omarchy 4.0.3 的 `manifestHasKind()` 只认真正的 JS 数组，而克隆菜单的清单要经过 Instantiator 模型才送到面板加载器，`kinds` 在那里变成 QV4 序列对象，判断因此为假 —— 克隆菜单拿不到 `appLibrary`，“应用”子菜单一直是空的（面板里显示“这里暂时没有内容”）。补丁让 zh-sync 同步时把系统自带的 `AppLibrary.qml` / `AppSearch.js` 拷进菜单克隆（`LocalAppLibrary.qml`），并把 `Menu.qml` 的绑定改成「宿主给了就用宿主的，没给就用克隆自带的」。上游修复见 omacom/omarchy#11282（PR #11285），合入新版后这份兜底自动闲置。

依赖：Omarchy 4.x、Node.js、jq、正在运行的 Omarchy Shell。

卸载：`cd ~/.local/share/omarchy-zh-cn && ./uninstall.sh`
