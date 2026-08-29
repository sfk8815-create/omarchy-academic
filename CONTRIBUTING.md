# 贡献指南（Contributing）

感谢你愿意为 **Omarchy 学研版（Omarchy Academic）** 贡献。本项目是面向中文科研与学术环境的 Omarchy 发行版配置项目，任何让科研人员、大学生、教师用起来更顺手的改进都欢迎。

## 项目结构

- `install.sh` / `uninstall.sh` / `sync.sh` — 一键安装 / 卸载 / 同步
- `packages/` — 核心、中文应用、学术软件包清单
- `config/` — 增量配置（按 `~/.config` 镜像，不修改 `/usr/share/omarchy`）
- `modules/` — 第三方社区模块（汉化、农历、OpenScience、sovena、MCP Cockpit 等）
- `scripts/` — 区域设置、Rime 安装、sudo 弹窗、健康检查
- `docs/` — 安装、FAQ、第三方资源来源与许可

## 提交规范

1. 先查看已有 Issue / 讨论，避免重复工作。
2. 说明改动动机与验证方式（例如：在干净 Omarchy VM 或真机上跑过 `install.sh`）。
3. 提交信息用中文、简洁描述（例：`修复 rime-ice 上游仓库地址`）。
4. **隐私红线**：不提交 API 密钥、代理真实端口、个人词库（`custom_phrase.txt`）、聊天/浏览器数据；用户路径一律用 `$HOME`。

## 代码要求

- 脚本遵守 `set -euo pipefail`，并通过 `shellcheck`。
- CI 会自动检查：bash 语法、shellcheck、JSON/TOML/Lua 语法、空白错误。推送前可本地先跑：

  ```bash
  bash -n install.sh uninstall.sh sync.sh scripts/*.sh hardware/*/install.sh modules/*/install.sh
  shellcheck install.sh uninstall.sh sync.sh scripts/*.sh hardware/*/install.sh modules/*/install.sh
  jq empty config/omarchy/shell.json
  git diff --check
  ```

- 配置与脚本尽量**幂等**：重复运行不破坏已有配置、不重复覆盖用户备份。
- 模块安装脚本保留上游来源与许可证（见 `docs/resources.md`），并在文件顶部注明。

## 文档

- 新功能 / 新模块请同步更新 `README.md` 或 `docs/faq.md`。
- 界面截图放入 `docs/images/`，并在 README 的界面预览表中引用。
- 网络相关经验（代理、镜像、慢网）补充到 `docs/faq.md` 的网络章节。

## 许可

- 项目本体与脚本：MIT（见 [LICENSE](LICENSE)）。
- 第三方模块遵守各自上游许可证（详见 `docs/resources.md`）。
