# Rime 配置

本目录包含 rime-ice（雾凇拼音）的中文化补丁，**不包含** rime-ice 本体与任何个人词库。

- `default.custom.yaml`：基于 [rime-ice](https://github.com/Dvel/rime-ice)（GPL-3.0）的默认配置修改，增加 `,` / `.` 翻页。
- `custom_phrase.example.txt`：自定义短语示例，安装时复制为 `custom_phrase.txt`，可自行编辑（注意不要提交个人短语）。

安装脚本 `scripts/install-rime-ice.sh` 会从上游 clone rime-ice 到 `~/.local/share/fcitx5/rime`，再应用本目录补丁。

遵循上游 [GPL-3.0](https://github.com/Dvel/rime-ice/blob/main/LICENSE) 许可。
