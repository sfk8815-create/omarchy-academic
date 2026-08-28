# 可选模块：中文农历日历（替换状态栏时钟）

来源：[GaryLiuGTA/omarchy_chinese_lunar_calendar](https://github.com/GaryLiuGTA/omarchy_chinese_lunar_calendar)（MIT）

作用：把内置时钟（含 Omarchy 界面汉化后的 `sfk.clock`）替换为带农历、二十四节气、节假日文案的日历组件（简/繁/英三语，可设置每周起始日）。

安装（install.sh 交互选择，或 `--with-lunar`）：

```bash
./install.sh --with-lunar
```

依赖：Omarchy 4.x、jq。

卸载：

```bash
omarchy plugin remove garyliu.lunar-calendar
# 并从 ~/.omarchy-academic-backup-* 或 .bak-* 备份恢复 shell.json
```
