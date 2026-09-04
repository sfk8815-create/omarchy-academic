#!/bin/bash
# Power off the unused NVIDIA discrete GPU on MacBookPro11,3.
# The Intel Iris Pro iGPU drives the internal panel; the GT 750M is unused.
if [ ! -f /sys/kernel/debug/vgaswitcheroo/switch ]; then
    mount -t debugfs debugfs /sys/kernel/debug 2>/dev/null
fi
if [ -f /sys/kernel/debug/vgaswitcheroo/switch ]; then
    echo OFF > /sys/kernel/debug/vgaswitcheroo/switch 2>/dev/null
fi
