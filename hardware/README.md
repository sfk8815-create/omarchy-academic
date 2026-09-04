# 可选硬件模块

这些模块针对特定硬件，**默认不安装**，由 `install.sh` 交互式询问或通过 `--with-*` 参数启用：

| 模块 | 适用设备 | 说明 |
| --- | --- | --- |
| `hidpi/` | 4K / 高分屏 | Hyprland UI 缩放与 GDK_SCALE（安装时输入数值） |
| `hid_apple/` | Apple 键盘 | fn 键默认触发媒体键（fnmode=2） |
| `macbook-nvidia-off/` | MacBookPro11,3（2013 末/2014 中 15 英寸双显卡版） | 开机后经 vgaswitcheroo 关闭 NVIDIA 独显（安装时校验机型） |

全部模块安装前都会备份被覆盖的文件。
