# 可选模块：sovena（缙云文采）文献流系统

来源：[sfk8815-create/sovena](https://github.com/sfk8815-create/sovena)（MIT，作者自有项目）

作用：Zotero → Markdown 语义文献包 → 向量检索的本地文献流系统，以 MCP 服务暴露给任意 AI 客户端；扫描版 PDF 自动走 OCR（MLX / GGUF 双后端）。

安装（**默认必装**，install.sh 自动执行；不需要时用 `--no-sovena` 跳过）：

```bash
./install.sh
```

脚本会 clone 到 `~/sovena`（可用环境变量 `SOVENA_DIR` 覆盖）并执行 `uv sync`。

使用前提：

- Zotero 7+ 正在运行（本地 API 读取，无需配置）
- embedding 模型服务（本地 mlx-lm / Ollama，或远程 OpenAI 兼容服务）
- OCR 可选（扫描件才需要）

启动：

```bash
cd ~/sovena && uv run sovena
```

详细配置见 sovena 仓库 README。
