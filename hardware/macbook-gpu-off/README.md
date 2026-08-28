# MacBook 独显断电模块

适用：Intel 核显 + NVIDIA 独显的双显卡 MacBook（如 MacBook Pro 15/16 寸旧款）。

作用：开机后通过 `vgaswitcheroo` 关闭未使用的 NVIDIA 独显，降低功耗与发热。

安装（需要 root，install.sh 会自动 sudo）：

```bash
sudo ./hardware/macbook-gpu-off/install.sh
```

卸载：

```bash
sudo systemctl disable --now nvidia-gpu-off.service
sudo rm /etc/systemd/system/nvidia-gpu-off.service /usr/local/sbin/gpu-off.sh
```
