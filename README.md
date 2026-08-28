# Omarchy 学研版 · Omarchy Academic

> 为中文科研与学术场景定制的 [Omarchy](https://omarchy.org/) 发行版配置项目——面向科研人员、大学生、大学教师。

Omarchy 学研版基于 Omarchy 4.0.1（Arch Linux + Hyprland + Quickshell），开箱即用地提供**中文环境**与**学术软件栈**：

- 中文系统区域（`zh_CN.UTF-8` + 中国时区）
- fcitx5 + Rime 输入法（雾凇拼音 rime-ice，含双拼等方案，`,` `.` 翻页）
- 中文字体回退：JetBrainsMono 等拉丁字体缺字时自动落到思源黑体（Noto Sans CJK SC）
- 四个终端（alacritty / foot / kitty / ghostty）的中文渲染，foot 中文字号单独放大 1.2 倍
- 学术软件栈：Zotero、Obsidian、Zettlr、Xournal++、LibreOffice/WPS、Tesseract 中文 OCR、Pandoc、TeX Live
- 中文办公应用（可选）：微信、钉钉、飞书、WPS Office
- 硬件模块（可选）：MacBook 独显断电、Apple 键盘 fn 键、HiDPI 缩放
- 中文 sudo 密码弹窗、系统健康检查等自写工具
- 一键安装/卸载、长期维护（`sync.sh` + GitHub Actions CI）

## 快速开始

在**全新 Omarchy 4.0.1** 上，以普通用户执行：

```bash
git clone https://github.com/sfk8815-create/omarchy-academic.git
cd omarchy-academic
./install.sh
```

安装脚本会：

1. 备份所有将被覆盖的配置到 `~/.omarchy-academic-backup-<时间戳>`
2. 安装核心软件包（fcitx5 全家桶、Rime、CJK 字体）
3. 启用 `zh_CN.UTF-8` 并写入 `/etc/locale.conf`（需要 sudo）
4. 部署字体、输入法、终端、Omarchy 状态栏配置
5. 安装 rime-ice 并应用本仓库补丁
6. 交互式询问是否安装可选模块（中文应用 / 学术软件 / 硬件模块）

重新登录后即可使用。详细说明见 [docs/install.md](docs/install.md)，常见问题见 [docs/faq.md](docs/faq.md)。

## 目录结构

```
omarchy-academic/
├── install.sh               # 一键安装（交互式，支持 --dry-run 预览）
├── uninstall.sh             # 从备份恢复 / 查看备份
├── sync.sh                  # 本机配置与仓库双向同步（长期维护）
├── packages/                # 核心 / 中文应用 / 学术软件包清单
├── config/                  # 增量配置（按 ~/.config 镜像）
│   ├── fontconfig/          # CJK 字体回退
│   ├── fcitx5/              # 输入法（默认 rime）
│   ├── hypr/                # Hyprland（fcitx 环境变量）
│   ├── omarchy/             # 状态栏与全局字号
│   └── alacritty|foot|kitty|ghostty/   # 终端中文渲染
├── rime/                    # rime-ice 补丁（不包含个人词库）
├── scripts/                 # 区域设置、rime 安装、sudo 弹窗、健康检查
├── templates/               # 代理等环境变量模板
├── hardware/                # 可选硬件模块（MacBook / HiDPI）
└── docs/                    # 安装与 FAQ
```

## 与 Omarchy 的关系

本仓库是 Omarchy 之上的**增量覆盖层**：只安装/修改必要文件，尊重 Omarchy 自身的升级与默认配置（`omarchy refresh` 可随时还原）。我们不是 Omarchy 官方项目，也不修改 `/usr/share/omarchy/` 下的任何文件。

## 隐私说明

本仓库**只包含可公开分发的配置与脚本**：

- 不包含 API 密钥、代理端口、个人词库、`installation_id`、聊天/浏览器数据
- 不包含任何个人路径（用户名以 `$HOME` 表示）
- 安装时自动备份被覆盖的文件，卸载可恢复

## 许可

- 项目本体与脚本：MIT（见 [LICENSE](LICENSE)）
- `rime/`：基于 [rime-ice](https://github.com/Dvel/rime-ice)（GPL-3.0）修改，见 [rime/README.md](rime/README.md)
- 微信/钉钉/飞书/WPS/微软字体等闭源内容：仅提供安装引用，版权归原厂商，请自行确认使用许可

## 维护

```bash
./sync.sh check    # 对比本机与仓库的配置差异
./sync.sh pull     # 把本机最新配置拉回仓库
./sync.sh status   # 查看 git 状态
```

GitHub Actions 会在每次推送时自动执行 shellcheck、JSON/TOML/Lua 语法检查。
