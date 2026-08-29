# 安装指南

## 前提

- **Omarchy 4.0.1**（Arch Linux + Hyprland）全新安装
- 已联网（GitHub / AUR 需要网络；国内网络建议先配好代理，参考 `templates/environment.d/proxy.conf.example`）
- 已有普通用户账号（安装过程中会请求 sudo）

## 安装

```bash
git clone https://github.com/sfk8815-create/omarchy-academic.git
cd omarchy-academic
./install.sh
```

脚本默认交互式执行，逐步完成：

1. **核心软件包**：fcitx5 全家桶、Rime、CJK 字体（pacman）
2. **区域设置**：启用 `zh_CN.UTF-8`，写入 `/etc/locale.conf`，设置时区（默认 Asia/Shanghai）
3. **配置部署**：字体回退、输入法 profile、Hyprland 输入法环境、状态栏、四个终端配置；被覆盖的文件自动备份
4. **Rime**：从上游拉取 rime-ice 并应用补丁（`,` `.` 翻页）
5. **小工具**：中文 sudo 密码弹窗、健康检查脚本
6. **sovena + MCP Cockpit（默认必装）**：文献流系统与统一 MCP 网关（可用 `--no-sovena` / `--no-mcp-cockpit` 跳过）
   - 安装后会把两个监管台加入默认浏览器书签栏（`localhost:8765` / `127.0.0.1:8899`；支持 Chromium/Chrome/Brave/Edge/Firefox，重启浏览器生效；可用 `--no-browser-bookmarks` 跳过）
7. **可选模块**（交互式询问）：
   - 中文应用（微信 / 钉钉 / 飞书 / WPS，AUR）
   - 学术软件栈（Zotero / Obsidian / Zettlr / Xournal++ / OCR / Pandoc / TeX Live）
   - HiDPI 缩放（4K 屏）
   - Apple 键盘 fn 键
   - 代理环境变量模板
   - Omarchy 界面简体中文化（第三方 MIT 项目）
   - 状态栏农历日历（第三方 MIT 项目）
   - 国内镜像 + archlinuxcn 社区仓库
   - Aether 科研 AI 助手 + Open Science Desktop 科研工作台

## 常用参数

```bash
./install.sh --dry-run          # 预览将要执行的命令
./install.sh --with-academic    # 直接安装学术软件栈
./install.sh --with-apps        # 直接安装中文应用
./install.sh --with-zh-ui       # 界面简体中文化（QueedWen/omarchy-zh-cn, MIT）
./install.sh --with-lunar       # 农历日历（garyliu.lunar-calendar, MIT）
./install.sh --with-cn-mirrors  # 国内镜像 + archlinuxcn
./install.sh --with-desktop     # Aether 科研助手 + Open Science Desktop
./install.sh --no-sovena        # 跳过 sovena（默认必装）
./install.sh --no-mcp-cockpit   # 跳过 MCP Cockpit（默认必装）
./install.sh --no-browser-bookmarks  # 不写入浏览器书签（默认写入）
./install.sh --core-only        # 只装核心中文化（locale/输入法/字体/终端/工具）
./install.sh --no-locale        # 跳过系统区域设置
./install.sh --yes              # 全部可选模块（不含硬件）默认安装
```

> 注：界面汉化、农历日历、国内镜像属于“需要显式确认”的模块，`--yes` 不会自动安装。

社区模块来源、许可证与卸载方式见 [resources.md](resources.md)。

## 安装后

1. **重新登录**（让 Hyprland 环境变量、输入法、终端配置全部生效）
2. 按 `Ctrl+Space` 切换中英文输入（rime）
3. 运行 `omarchy-health-check --no-sudo` 体检
4. 终端中文渲染：打开 foot/kitty/ghostty 输入中文验证；若仍显示方块，运行 `fc-cache -f` 后重开终端

## 升级 Omarchy 之后

Omarchy 升级一般不会覆盖 `~/.config/` 下的用户配置。若某次升级后外观异常，可先用备份恢复，再对比：

```bash
./sync.sh check
```

如确认需要重置为系统默认，再使用 `omarchy refresh`（会先自动备份）。

## 卸载

```bash
./uninstall.sh --list
./uninstall.sh --restore ~/.omarchy-academic-backup-<时间戳>
```

恢复只回滚配置，不卸载软件包；如需卸载软件包请自行 `pacman -R` / `yay -R`。
