# Apple 键盘 fn 键模块

适用：Apple 外接键盘 / MacBook 内置键盘。

作用：`fnmode=2`，让 fn 键默认触发媒体键（F1–F12 需按住 fn），符合 macOS 使用习惯。

安装（自动 sudo）：

```bash
sudo ./hardware/hid_apple/install.sh
```

重启后生效。恢复默认：

```bash
sudo rm /etc/modprobe.d/hid_apple.conf
```
