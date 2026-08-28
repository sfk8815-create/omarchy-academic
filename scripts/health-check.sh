#!/usr/bin/env bash
# Omarchy 学研版 —— 系统健康检查
# 用法:
#   omarchy-health-check            # 完整检查（部分项目需要 sudo 密码弹窗）
#   omarchy-health-check --no-sudo  # 跳过需要 root 的检查
set -u

if [[ "${1:-}" == "--no-sudo" ]]; then
	SUDO_CMD=()
else
	SUDO_CMD=(sudo -A)
	if [[ -x "${SUDO_ASKPASS:-$HOME/.local/bin/sudo-askpass}" ]]; then
		export SUDO_ASKPASS="${SUDO_ASKPASS:-$HOME/.local/bin/sudo-askpass}"
	else
		SUDO_CMD=(sudo)
	fi
fi

pass=0
fail=0
warn=0

ok()   { printf '  \033[1;32mPASS\033[0m  %s\n' "$1"; pass=$((pass + 1)); }
bad()  { printf '  \033[1;31mFAIL\033[0m  %s\n' "$1"; fail=$((fail + 1)); }
note() { printf '  \033[1;33mWARN\033[0m  %s\n' "$1"; warn=$((warn + 1)); }
section() { printf '\n\033[1;36m== %s ==\033[0m\n' "$1"; }

section "双显卡（仅 MacBook 等 vgaswitcheroo 机型）"
if [[ -f /sys/kernel/debug/vgaswitcheroo/switch ]]; then
	if (( ${#SUDO_CMD[@]} )); then
		if "${SUDO_CMD[@]}" cat /sys/kernel/debug/vgaswitcheroo/switch 2>/dev/null | rg -q 'DIS:.*:Off'; then
			ok "独显已断电 (vgaswitcheroo DIS Off)"
		else
			bad "独显仍在供电 (vgaswitcheroo DIS 非 Off)"
		fi
		svc=$("${SUDO_CMD[@]}" systemctl is-enabled nvidia-gpu-off.service 2>/dev/null)
		if [[ "$svc" == "enabled" ]]; then
			ok "nvidia-gpu-off.service 开机自启"
		else
			bad "nvidia-gpu-off.service 未启用 ($svc)"
		fi
	else
		note "跳过独显检查 (需要 root)"
	fi
else
	note "非 vgaswitcheroo 机型，跳过"
fi

section "服务裁剪"
running=$(systemctl list-units --type=service --state=running --no-pager 2>/dev/null | rg -c '\.service' || true)
if (( running <= 21 )); then
	ok "运行服务数 $running (目标 <=21)"
else
	note "运行服务数 $running (>21, 有新增服务)"
fi
for svc in cups cups-browsed avahi-daemon avahi-daemon.socket; do
	state=$(systemctl is-enabled "$svc" 2>/dev/null)
	if [[ "$state" == "disabled" ]]; then
		ok "$svc 已禁用"
	else
		note "$svc 状态: $state (如需要打印可启用)"
	fi
done

section "存储与内存"
if systemctl is-active fstrim.timer >/dev/null 2>&1; then
	ok "fstrim.timer 每周自动 TRIM"
else
	bad "fstrim.timer 未运行"
fi
if zramctl 2>/dev/null | rg -q 'zstd'; then
	ok "zram 已启用 (zstd 压缩)"
else
	bad "zram 未运行"
fi
swappiness=$(sysctl -n vm.swappiness 2>/dev/null)
if [[ "$swappiness" == "150" ]]; then
	ok "vm.swappiness = 150 (zram 优化配置)"
else
	note "vm.swappiness = ${swappiness:-未知} (预期 150)"
fi

section "LUKS TRIM"
if rg -q 'allow-discards' /proc/cmdline; then
	ok "启动参数已含 allow-discards"
else
	bad "启动参数缺少 allow-discards —— 修改后需重启一次"
fi
if (( ${#SUDO_CMD[@]} )); then
	if "${SUDO_CMD[@]}" cryptsetup status /dev/mapper/root 2>/dev/null | rg -qi 'discard'; then
		ok "LUKS 已放行 discard (重启后生效)"
	else
		bad "LUKS 未放行 discard —— 需要重启"
	fi
else
	note "跳过 LUKS discard 检查 (需要 root)"
fi

section "包管理器"
if rg -q '^ParallelDownloads\s*=\s*([5-9]|1[0-9])' /etc/pacman.conf; then
	ok "pacman 并行下载已开启"
else
	note "pacman 未配置 ParallelDownloads"
fi

section "电源与散热"
profile=$(powerprofilesctl get 2>/dev/null)
ok "当前电源模式: ${profile:-未知}"
if (( ${#SUDO_CMD[@]} )); then
	for z in /sys/class/thermal/thermal_zone*/temp; do
		[[ -r "$z" ]] || continue
		type=$(cat "${z%/temp}/type" 2>/dev/null)
		temp=$(( $(cat "$z") / 1000 ))
		ok "${type:-unknown}: ${temp}°C"
	done
else
	note "跳过温度检查 (需要 root)"
fi

section "蓝牙 (可选)"
state=$(systemctl is-enabled bluetooth 2>/dev/null)
note "bluetooth 当前: $state —— 不用蓝牙可执行 sudo systemctl disable --now bluetooth 省电"

printf '\n\033[1;36m== 结果: %d 通过, %d 警告, %d 失败 ==\033[0m\n' "$pass" "$warn" "$fail"
exit 0
