# 社区资源调查与吸纳说明

本文档记录 2026-08 对 GitHub 上中文/Omarchy 相关项目的调查结论，以及学研版“有条件吸纳”的取舍。

## 调查清单

| 项目 | 星级 | 许可证 | 一句话定位 | 分析 | 吸纳情况 |
| --- | --- | --- | --- | --- | --- |
| [OmarchyCN](https://git.zacharyzhang.com/ZacharyZhang-NY/omarchycn) | - | MIT（README 声明） | 面向中国**开发者**的 Omarchy 下游发行版：国内镜像、Fcitx5+Rime、AI Hub（Kimi/DeepSeek/GLM/Ollama）、国内应用中心、一键转换/还原 | 与学研版定位最接近但面向开发者；提供 archiso、镜像管理、doctor 诊断等系统级能力 | **不吸纳代码**（体量大、自建镜像站）；作为定位参照与路线图参考，README 中说明互补关系 |
| [QueedWen/omarchy-zh-cn](https://github.com/QueedWen/omarchy-zh-cn) | 10 | MIT | Omarchy 4 界面简体中文化：菜单/面板/天气/快捷键，用户级插件克隆 | 质量高、改动面可控、不碰 `/usr/share/omarchy`、更新自动同步 | **吸纳为可选模块** `modules/zh-ui/` |
| [iDvel/rime-ice](https://github.com/iDvel/rime-ice) | 19k | GPL-3.0 | 雾凇拼音长期维护词库 | 学研版输入法基础 | **已在用**（安装脚本 + 补丁） |
| [manateelazycat/rime-ice-installer](https://github.com/manateelazycat/rime-ice-installer) | 27 | 未声明 | Fcitx5+Rime TUI 安装器，含 9 候选、`,` `.` 翻页、Shift 临时英文 | 配置思路可借鉴 | **借鉴思路，不抄代码**：候选数调为 9（补丁自实现） |
| [archlinuxcn/repo](https://github.com/archlinuxcn/repo) | 1.9k | 未声明 | Arch Linux 中文社区仓库 | 中文软件生态的官方社区源 | **吸纳镜像配置事实**，自写 `scripts/setup-cn-mirrors.sh` |
| [archlinuxcn/mirrorlist-repo](https://github.com/archlinuxcn/mirrorlist-repo) | 589 | 未声明 | archlinuxcn 公共镜像列表 | 提供清华/北大/中科大等镜像地址 | 同上（仅引用公开镜像地址） |
| [GaryLiuGTA/omarchy_chinese_lunar_calendar](https://github.com/GaryLiuGTA/omarchy_chinese_lunar_calendar) | 1 | MIT | Omarchy 农历/节气日历插件 | 小而精，直接替换内置时钟 | **吸纳为可选模块** `modules/lunar-calendar/` |
| [rocklau/omarchy-book](https://github.com/rocklau/omarchy-book) | 14 | 未声明 | Omarchy 中文社区资源手册 | 整理质量高（命令速查、社区项目索引） | **文档参考**：链接进 README |
| [SHORiN-KiWATA/Shorin-ArchLinux-Guide](https://github.com/SHORiN-KiWATA/Shorin-ArchLinux-Guide) | 2.5k | 未声明 | Arch Linux 新手中文教程 | 对目标人群（学生/教师）友好 | **文档参考** |
| [omarchy-mac](https://github.com/omarchy-mac/omarchy-mac) | 1.2k | 未声明 | Apple Silicon 一条命令装 Omarchy | 与 MacBook 硬件相关 | **文档参考**（Apple Silicon 用户） |

## 吸纳原则

1. **许可证兼容**：MIT/GPL 且来源明确才吸纳代码；未声明许可证的项目只借鉴思路或引用公开事实。
2. **不重复造轮子**：已有成熟上游（rime-ice、汉化、农历、archlinuxcn）的，作为可选模块引用，而不是复制维护。
3. **不动上游**：第三方模块都只写入 `~/.config` / `~/.local`，不修改 `/usr/share/omarchy`。
4. **可卸载**：每个模块都有卸载路径（备份恢复或上游自带 uninstall）。

## 定位差异

学研版与 OmarchyCN 不冲突：

- **OmarchyCN**：开发者向——镜像管理、AI Hub、国内应用中心、完整 ISO。
- **学研版**：学术向——中文环境、学术软件栈（Zotero/Obsidian/OCR/LaTeX）、教师/学生友好文档。

两者可以共存（同一台 Omarchy 上先装 OmarchyCN 再叠加学研版配置，或反之）；学研版不提供完整 ISO，专注可叠加的配置层。
