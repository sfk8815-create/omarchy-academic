# 可选模块：Open Science Desktop（本地优先 AI 科研工作台）

来源：[ai4s-research/open-science](https://github.com/ai4s-research/open-science)（MIT，ResearchClawBench 榜首）

作用：把科研全流程（探索 → 文献调研 → 实验 → 图表 → 论文）收进一个可审计的本地工作台；`osd` CLI 无界面版本可直接 `osd server` 起 Web 工作台 + API。

安装（install.sh 交互选择，或 `--with-desktop`）：

```bash
./install.sh --with-desktop
```

脚本会从 GitHub Releases 下载最新 `osd-*-x86_64-unknown-linux-gnu.tar.gz`，解压到 `~/.local/opt/osd` 并安装 `~/.local/bin/osd` 包装脚本。

常用：

```bash
osd server          # 启动工作台（打印 URL 与访问令牌）
osd auth set …      # 配置模型提供方
osd --help          # 全部命令
```

卸载：删除 `~/.local/opt/osd` 与 `~/.local/bin/osd`。
