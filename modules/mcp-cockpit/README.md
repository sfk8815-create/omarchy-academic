# 可选模块：MCP Cockpit（MCP 驾驶舱）

来源：[sfk8815-create/mcp-cockpit](https://github.com/sfk8815-create/mcp-cockpit)（作者自有项目）

作用：一份 MCP 配置服务所有 AI 客户端——基于 [mcp-hub](https://github.com/ravitemer/mcp-hub) 网关的零依赖 Web 管理台 + 自愈看门狗（`127.0.0.1:8899`）。

安装（**默认必装**，install.sh 自动执行；不需要时用 `--no-mcp-cockpit` 跳过）：

```bash
./install.sh
```

脚本会 clone 到 `~/mcp-cockpit`（可用环境变量 `MCP_COCKPIT_DIR` 覆盖）并运行其 `scripts/install.sh`（安装 mcp-hub 网关 + 生成配置模板，不覆盖已有配置）。

启动与自启：

```bash
cd ~/mcp-cockpit && bash scripts/start.sh
# 浏览器打开 http://127.0.0.1:8899
# 开机自启：参照 ~/mcp-cockpit/docs/systemd/ 安装 systemd --user 单元
```
