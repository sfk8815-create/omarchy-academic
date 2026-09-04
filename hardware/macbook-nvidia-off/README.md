# MacBook Pro 11,3 NVIDIA 独显断电模块

适用机型（**仅限以下型号，安装脚本也会校验机型**）：

- 机型标识（DMI `product_name`）：`MacBookPro11,3`
- 对应 MacBook Pro 15 英寸 Retina 双显卡版（Late 2013 / Mid 2014）
- 显卡：Intel Iris Pro 5200 核显 + NVIDIA GeForce GT 750M（2 GB GDDR5）

作用：开机进入多用户目标后，通过内核 `vgaswitcheroo` 对 NVIDIA 独显执行
`echo OFF`，让独显断电休眠，由 Intel 核显单独承担显示，降低功耗与发热。

注意事项：

- **外接显示器不可用**：2011 年及以后的 MacBook Pro，外部 DP/Thunderbolt/HDMI
  接口只能由 NVIDIA 独显驱动。启用本模块后请使用内屏，不要外接显示器。
- 只适合用开源 nouveau 驱动且不需要 NVIDIA 加速的场景（本仓库学术场景默认如此）。
- 其他型号（包括同为 GT 750M 的 MacBookPro11,2）未在本仓库验证，请勿直接套用。

安装（需要 root，install.sh 会自动 sudo）：

```bash
sudo ./hardware/macbook-nvidia-off/install.sh
```

也可在总安装脚本中选择：

```bash
./install.sh --with-macbook-nvidia-off
```

卸载：

```bash
sudo systemctl disable --now nvidia-gpu-off.service
sudo rm /etc/systemd/system/nvidia-gpu-off.service /usr/local/sbin/gpu-off.sh
```
