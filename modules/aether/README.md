# 可选模块：Aether（科研 AI 研究助手）

来源：[Science-Discovery/Aether](https://github.com/Science-Discovery/Aether)（MIT）

作用：基于 OpenCode 的本地 AI 科研助手平台——文献综述、论文写作、arXiv 检索、同行评审、基金申请书等 **20+ 内置技能**；支持 25+ 模型供应商、MCP 协议、RAG 知识库、PDF 阅读/翻译/转 Markdown、定时任务与语音输入。

安装（install.sh 交互选择，或 `--with-desktop`）：

```bash
./install.sh --with-desktop
```

脚本从 GitHub Releases 下载最新 `aether-linux-x64.zip`（Web 浏览器版），解压到 `~/.local/opt/aether` 并安装 `~/.local/bin/aether` 包装脚本。

> 安装包约 90MB，支持断点续传与自动重试；网络慢时请耐心等待。

启动：

```bash
aether web          # 浏览器版：启动本地服务并自动打开界面
```

可选：`cd ~/.local/opt/aether && ./install.sh` 创建桌面应用入口；Electron 桌面版见 Releases（`aether-desktop-linux-x86_64.AppImage` / `.deb`）。

卸载：删除 `~/.local/opt/aether` 与 `~/.local/bin/aether`。
