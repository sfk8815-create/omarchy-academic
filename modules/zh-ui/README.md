# 可选模块：Omarchy 界面简体中文化

来源：[QueedWen/omarchy-zh-cn](https://github.com/QueedWen/omarchy-zh-cn)（MIT）

作用：汉化 Omarchy 4 的主菜单、系统面板、天气、快捷键面板等 300+ 项界面文案；不改 `/usr/share/omarchy`，通过用户级插件克隆实现，系统更新后自动重新同步。

安装（install.sh 交互选择，或 `--with-zh-ui`）：

```bash
./install.sh --with-zh-ui
```

该脚本会克隆上游仓库到 `~/.local/share/omarchy-zh-cn`，执行其 `install.sh --dry-run` 与 `install.sh`。

依赖：Omarchy 4.x、Node.js、jq、正在运行的 Omarchy Shell。

卸载：`cd ~/.local/share/omarchy-zh-cn && ./uninstall.sh`
