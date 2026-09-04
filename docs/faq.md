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

### 候选词窗口太小 / 想调大

学研版通过 `~/.config/fcitx5/conf/classicui.conf` 把 Classic UI 的字体设为 `Sans 12`（fcitx5 默认 `Sans 10`），候选词更大更清晰。想再调大（或调回默认）：

```bash
sed -i 's/Font="Sans 12"/Font="Sans 14"/' ~/.config/fcitx5/conf/classicui.conf
fcitx5-remote -r
```

修改即时生效，无需重新登录。该文件同时收录在仓库 `config/fcitx5/conf/classicui.conf`，可用 `./sync.sh pull` 拉回维护。

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

### 透明代理（TUN 模式）下不要设置显式代理变量

- 现象：mihomo/clash 开启 **TUN 模式**后，如果系统里再设置 `http_proxy`/`https_proxy` 指向 `127.0.0.1:7897`，pacman 从国内镜像（清华/中科大等）下载会报 `Operation too slow` 超时。
- 原因：流量被代理链绕行两遍——TUN 已接管全部流量，显式代理又转发一次，国内源反而被拖慢。
- 建议：TUN 模式下**不要**设置全局显式代理变量；显式代理只用于单独的大文件下载（见下一条）。

### GitHub 大文件下载慢/卡住怎么办

学研版的大文件下载模块（Aether、Open Science Desktop）支持只给下载走代理：

```bash
DOWNLOAD_PROXY=http://127.0.0.1:7897 ./modules/aether/install.sh
DOWNLOAD_PROXY=http://127.0.0.1:7897 ./modules/openscience/install.sh
```

只影响该次下载，不污染系统其他流量；模块已内置断点续传与自动重试。另外这些模块不依赖未认证的 GitHub API（有每小时限流），而是走 `releases/latest` 跳转，避免 403。

## 系统

### 界面汉化/农历日历/国内镜像怎么装

```bash
./install.sh --with-zh-ui       # 界面简体中文化（汉化菜单、面板、天气、快捷键）
./install.sh --with-lunar       # 状态栏时钟换成农历日历
./install.sh --with-cn-mirrors  # 清华镜像 + archlinuxcn 仓库
```

三者均来自 MIT 社区项目或公开镜像配置，来源见 docs/resources.md；卸载方式见 modules/ 下对应 README。

### sovena / MCP Cockpit 是必装吗

```bash
./install.sh                    # 默认自动安装 sovena + MCP Cockpit
./install.sh --no-sovena        # 不需要时跳过
./install.sh --no-mcp-cockpit   # 不需要时跳过
./install.sh --with-desktop     # 另装 Aether 科研助手 + Open Science Desktop
```

是的，两者是**默认必装**：

- sovena 文献流：需要 Zotero 7+ 运行中、uv 已装；启动 `cd ~/sovena && uv run sovena`
- MCP Cockpit：启动 `cd ~/mcp-cockpit && bash scripts/start.sh`，浏览器打开 127.0.0.1:8899
- sovena 启动后，MCP Cockpit 会自动把它的 MCP 端点注册进网关（`scripts/add-sovena-mcp.sh`），AI 客户端连统一端点即可用文献检索

两者均为作者自有项目（MIT / 见仓库 LICENSE），与学研版配套构成学术工作流。

### 装了 archlinuxcn 之后 AUR 助手要不要改

不用。archlinuxcn 是独立仓库，与 AUR（yay/paru）互不冲突；`archlinuxcn-keyring` 会自动安装以校验包签名。

### 不是 MacBook / 没有 Apple 键盘能装吗

可以。`install.sh` 默认只装核心中文化内容；Apple 键盘模块在询问时选“n”即可。

### 不是 MacBookPro11,3 能装 NVIDIA 独显断电模块吗

不能。该模块仅适配 MacBook Pro 15 英寸 Retina 双显卡版（Late 2013 / Mid 2014，DMI 机型 `MacBookPro11,3`，Intel Iris Pro + NVIDIA GT 750M）。`install.sh` 在交互询问时会说明适用机型，模块自身的 `install.sh` 也会读取 `/sys/class/dmi/id/product_name` 校验机型，不符直接拒绝并报当前机型，不会写入任何文件。若你的机器是其他双显卡 MacBook（如 `MacBookPro11,2`），暂时不要手动绕过校验，等待仓库后续验证适配。

### 4K 屏字太小 / 太大

运行 `./hardware/hidpi/install.sh` 重新输入缩放值，或直接编辑 `~/.config/hypr/monitors.lua` 的两个变量。

### Omarchy 升级后配置被覆盖 / 想还原默认

本仓库只写 `~/.config/`，Omarchy 升级一般不覆盖。若想还原，先用 `./uninstall.sh --list` 找备份恢复；确定要重置时再 `omarchy refresh <组件>`（会自动备份）。

## 隐私

### 仓库里会不会泄露我的数据

不会。仓库只包含可公开配置与脚本；Rime 个人词库（`custom_phrase.txt`）、API 配置、代理真实端口、浏览器/聊天数据都不在仓库中，`.gitignore` 也做了拦截。

## 干净 VM / 无头环境

### 在全新 Omarchy VM 里跑模块时报 "omarchy-shell is not responding"

Omarchy 的插件命令（`omarchy plugin clone/add`、zh-ui 汉化同步）通过 `qs ipc` 与正在运行的 Omarchy Shell 通信：

1. 非登录会话（SSH/TTY）缺 `OMARCHY_PATH`，导致 `omarchy-plugin-catalog` 找不到 `/shell/plugins`。先 `export OMARCHY_PATH=/usr/share/omarchy`（或写入 `/etc/environment`）。
2. 插件克隆需要桌面会话环境变量：`WAYLAND_DISPLAY`、`XDG_RUNTIME_DIR`、`HYPRLAND_INSTANCE_SIGNATURE`（可在运行中的 Hyprland/quickshell 进程的 `/proc/<pid>/environ` 里取）。
3. TCG 软件模拟（无 KVM）下 Shell 响应慢，默认 2 秒 IPC 超时不够：`export OMARCHY_SHELL_IPC_TIMEOUT=60s`。

最稳妥的方式是**登录桌面会话后**再运行 `install.sh`（与真实使用一致）。

### zh-ui 汉化在全新 4.0.1 上跳过部分插件

上游 `omarchy-zh-cn` 硬编码了 22 个内置插件名，但 Omarchy 4.x 不同小版本的插件集有增删（如 4.0.1 已无 `omarchy.audio`）。学研版已对上游脚本打补丁：按当前版本实际插件目录**过滤不存在的插件**、zh-sync 缺失插件改为警告跳过，剩余插件正常克隆。

### cn-mirrors 在 VM/沙箱里同步 archlinuxcn 失败

`setup-cn-mirrors.sh` 会先探测可达镜像（tuna→ustc→aliyun）再写 mirrorlist，并追加 `[archlinuxcn]`。若 VM 的 NAT 到国内镜像或 `pkgs.omarchy.org` 超时，`pacman -Sy` 一步会失败——这是网络环境问题，不是脚本问题；换用可直连国外源的网络后重跑即可。

### VM 验收记录

干净 Omarchy 4.0.1 虚拟机（QEMU TCG，无人值守 cidata 安装）全流程验证记录见 [images/vm-desktop.png](images/vm-desktop.png)（顶栏农历日历与中文界面渲染正常）。
