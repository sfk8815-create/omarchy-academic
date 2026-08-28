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

## 学术科研方向调查（2026-08 补充）

| 项目 | 星级 | 许可证 | 一句话定位 | 吸纳情况 |
| --- | --- | --- | --- | --- |
| [ai4s-research/open-science](https://github.com/ai4s-research/open-science)（Open Science Desktop） | 1.5k | MIT | 本地优先、模型无关的 AI 科研工作台（ResearchClawBench 榜首），`osd` 无头 CLI | **吸纳为模块** `modules/openscience/` |
| [Science-Discovery/Aether](https://github.com/Science-Discovery/Aether)（Aether 科研助手） | 71 | MIT | 基于 OpenCode 的本地 AI 科研助手：文献综述/论文写作/审稿/基金写作等 20+ 技能，RAG、MCP、PDF→Markdown | **吸纳为模块** `modules/aether/` |
| [typst/typst](https://github.com/typst/typst) | 55.7k | Apache-2.0 | 面向科学的标记排版系统（LaTeX 现代替代） | **加入 `academic.txt`** |
| [ocrmypdf/OCRmyPDF](https://github.com/ocrmypdf/OCRmyPDF) | 34.6k | MPL-2.0 | 给扫描 PDF 加 OCR 文本层（中文扫描件可搜索） | **加入 `academic.txt`**（archlinuxcn/AUR） |
| [kovidgoyal/calibre](https://github.com/kovidgoyal/calibre) | 24k+ | GPL-3.0 | 电子书库管理 | **加入 `academic.txt`** |
| [jupyter/notebook](https://github.com/jupyter/notebook) | 12k+ | BSD-3-Clause | 可复现研究笔记本 | **加入 `academic.txt`** |
| [quarto-dev/quarto-cli](https://github.com/quarto-dev/quarto-cli) | 6k | 见仓库 LICENSE | 基于 Pandoc 的科学出版系统 | 文档记录（AUR `quarto-cli` 可装） |
| [rendercv/rendercv](https://github.com/rendercv/rendercv) | 17.4k | MIT | 学术简历/求职材料生成器 | 文档记录（AUR `rendercv`） |
| [JabRef/jabref](https://github.com/JabRef/jabref) | 4k+ | MIT | Java 文献管理（BibTeX 友好） | 文档记录（AUR `jabref`；已有 Zotero 时非必需） |
| [paperless-ngx/paperless-ngx](https://github.com/paperless-ngx/paperless-ngx) | 26k+ | GPL-3.0 | 论文/文档数字化归档与全文检索 | 文档记录（体量较大，后续可做模块） |
| [pedrohcgs/claude-code-my-workflow](https://github.com/pedrohcgs/claude-code-my-workflow) | 1.5k | 见仓库 LICENSE | 面向学术写作的 AI 多智能体审稿/复现模板 | 文档记录 |
| [sfk8815-create/sovena](https://github.com/sfk8815-create/sovena) | 5 | MIT | Zotero → 语义文献包 → 向量检索 + MCP（作者自有） | **默认集成** `modules/sovena/` |
| [sfk8815-create/mcp-cockpit](https://github.com/sfk8815-create/mcp-cockpit) | 1 | MIT | 统一 MCP 网关管理台 + 自愈看门狗（作者自有） | **默认集成** `modules/mcp-cockpit/` |

### 学术场景选型建议

- **文献管理**：Zotero（已有）+ sovena（语义检索/OCR）→ 可选 JabRef（BibTeX 工作流）
- **写作排版**：Pandoc + TeX Live（已有）+ Typst + Quarto
- **阅读批注**：Zathura（MuPDF）+ Xournal++（已有）
- **扫描件数字化**：Tesseract（已有）+ OCRmyPDF
- **实验与复现**：Jupyter Notebook + Open Science Desktop
- **AI 接入**：MCP Cockpit 统一网关，供 Codex / Claude / Trae 等客户端共享同一批 MCP 服务器；Aether 科研助手承担文献综述/写作/审稿等研究型任务
