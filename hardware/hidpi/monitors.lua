-- Omarchy 学研版 HiDPI 模板
-- 修改下方两个值后保存，Hyprland 会自动重载。
-- 也可用 hardware/hidpi/install.sh 交互式安装。

local omarchy_gdk_scale = 2        -- GDK/Electron 类应用的缩放系数
local omarchy_monitor_scale = 1.6  -- 屏幕 UI 缩放（4K 屏常用 1.6~2.0，1080p 用 1）

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })

-- 多显示器示例：
-- hl.monitor({ output = "DP-2", mode = "2560x1440@144", position = "0x0", scale = 1 })
