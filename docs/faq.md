# 常见问题（FAQ）

## 输入法

### 按 Ctrl+Space 切不出中文

按顺序排查：

```bash
pgrep -a fcitx5                    # 输入法进程是否在跑
cat ~/.config/hypr/hyprland.lua    # 是否有 GTK_IM_MODULE / QT_IM_MODULE / XMODIFIERS / SDL_IM_MODULE 四行
fcitx5-configtool                  # 输入法列表里是否有 rime
```

改完配置后**重新登录**最稳妥。

### 想用双拼 / 五笔 / 注音

rime-ice 自带双拼（小鹤/微软/搜狗等）、五笔、注音等方案。在 rime 菜单（`Ctrl+` 或托盘图标）里选择方案，或编辑 `~/.local/share/fcitx5/rime/default.yaml` 的 schema 列表后重新部署。

## 字体与终端

### 终端里中文是方块

```bash
fc-cache -f
fc-list :lang=zh family | sort -u | head
```

确认有 Noto Sans CJK 后重开终端。四个终端的回退链都已在仓库里配好。

### foot 里中文看起来比英文大

这是有意设计：foot 支持给回退字体单独设字号，中文用了英文的 1.2 倍（14.4pt vs 12pt）以填满字符框。不习惯可在 `~/.config/foot/foot.ini` 里把两个字号改为相同。

### 想换终端字体大小

直接改 `~/.config/<终端>/` 下的 `font size` / `font_size` 行；alacritty/kitty/ghostty 的中文与英文同号，foot 可分开设。

## 软件

### WPS 打开后缺字体

安装 `ttf-wps-fonts`（已包含在可选“中文应用”里）。

### 微信 / 钉钉 / 飞书在 Wayland 下有显示或输入法问题

这些是闭源 Electron/自绘应用，兼容性由各自发行版决定：

- 微信（wechat-universal-bwrap）一般原生 Wayland 可用；异常时在启动命令加 `--ozone-platform=x11`
- 钉钉 / 飞书若输入法失效，用 `--ozone-platform=x11` 跑（走 XWayland）
- 输入法问题常见于应用未收到 `GTK_IM_MODULE`，确认 hyprland.lua 的四行环境变量在

### Zotero 在学研版里怎么配 OCR

Zotero 负责文献管理；配合本仓库的学术软件栈，可用 Tesseract（`tesseract --list-langs` 确认 `chi_sim` 存在）做中文扫描件 OCR，具体流程见项目文档规划。

## 网络

### GitHub / AUR 连不上

国内网络建议使用代理：参考 `templates/environment.d/proxy.conf.example`，把端口改成你的代理端口，复制为 `~/.config/environment.d/proxy.conf` 后重新登录。

### 代理配置后仍不走代理

确认代理软件在运行、端口正确；`curl -I https://github.com` 看是否走通。环境变量对已登录的图形会话要重新登录才生效。

## 系统

### 界面汉化/农历日历/国内镜像怎么装

```bash
./install.sh --with-zh-ui       # 界面简体中文化（汉化菜单、面板、天气、快捷键）
./install.sh --with-lunar       # 状态栏时钟换成农历日历
./install.sh --with-cn-mirrors  # 清华镜像 + archlinuxcn 仓库
```

三者均来自 MIT 社区项目或公开镜像配置，来源见 docs/resources.md；卸载方式见 modules/ 下对应 README。

### sovena / MCP Cockpit / Open Science Desktop 怎么装

```bash
./install.sh --with-sovena      # 缙云文采文献流（需 Zotero 7+ 运行中、uv 已装）
./install.sh --with-mcp-cockpit # MCP 统一网关管理台（浏览器打开 127.0.0.1:8899）
./install.sh --with-desktop     # Aether 科研助手 + Open Science Desktop（osd server 起工作台）
```

sovena 与 MCP Cockpit 是作者自有项目（MIT / 见仓库 LICENSE），与学研版配套构成学术工作流。

### 装了 archlinuxcn 之后 AUR 助手要不要改

不用。archlinuxcn 是独立仓库，与 AUR（yay/paru）互不冲突；`archlinuxcn-keyring` 会自动安装以校验包签名。

### 不是 MacBook / 没有 Apple 键盘能装吗

可以。`install.sh` 默认只装核心中文化内容；Apple 键盘模块在询问时选“n”即可。

### 4K 屏字太小 / 太大

运行 `./hardware/hidpi/install.sh` 重新输入缩放值，或直接编辑 `~/.config/hypr/monitors.lua` 的两个变量。

### Omarchy 升级后配置被覆盖 / 想还原默认

本仓库只写 `~/.config/`，Omarchy 升级一般不覆盖。若想还原，先用 `./uninstall.sh --list` 找备份恢复；确定要重置时再 `omarchy refresh <组件>`（会自动备份）。

## 隐私

### 仓库里会不会泄露我的数据

不会。仓库只包含可公开配置与脚本；Rime 个人词库（`custom_phrase.txt`）、API 配置、代理真实端口、浏览器/聊天数据都不在仓库中，`.gitignore` 也做了拦截。
