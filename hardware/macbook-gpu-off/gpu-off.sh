#!/bin/bash
# Power off the unused NVIDIA discrete GPU (Intel iGPU is primary on this MacBook)
if [ ! -f /sys/kernel/debug/vgaswitcheroo/switch ]; then
    mount -t debugfs debugfs /sys/kernel/debug 2>/dev/null
fi
if [ -f /sys/kernel/debug/vgaswitcheroo/switch ]; then
    echo OFF > /sys/kernel/debug/vgaswitcheroo/switch 2>/dev/null
fi
