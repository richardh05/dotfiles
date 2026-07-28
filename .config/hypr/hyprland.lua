---@module 'hl'

-- source = ~/.config/hypr/colours.conf -> requires manual conversion
-- local colours = require("colours")
-- TODO: convert ~/.config/hypr/colours.conf to .lua and use require()

-- source = ~/.config/hypr/machine.conf -> requires manual conversion
-- local machine = require("machine")
-- TODO: convert ~/.config/hypr/machine.conf to .lua and use require()

local fg = "rgba(e0def4ff)"
local bg = "rgba(191724ee)"
local red = "rgba(eb6f92ff)"
local check = "rgba(ebbcbaff)"
local form_outer= "rgba(343049ff)"
local form_inner = "rgba(252239ff)"
local active_border = "rgba(9ccfd8ee)"
local inactive_border = "rgba(434a4caa)"
local shadow = "rgba(1a1a1aee)"

--###############
--## MONITORS ###
--###############

hl.monitor({
    output   = "eDP-1",
    mode     = "1920x1080@60",
    position = "-1920x0",
    scale    = 1,
})

hl.monitor({
    output   = "DP-3",
    mode     = "1920x1080@60",
    position = "-1920x0",
    scale    = 1,
})

--################
--## AUTOSTART ###
--################

hl.on("hyprland.start", function()
    hl.exec_cmd("nm-applet & waybar & hypridle & hyprpaper")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme rose-pine-gtk")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface icon-theme Papirus-Dark")
    --hl.exec_cmd ("gsettings set org.gnome.desktop.interface font-name Ubuntu Nerd Font 11")"
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
end)

--############################
--## ENVIRONMENT VARIABLES ###
--############################

-- See https://wiki.hyprland.org/Configuring/Environment-variables/

hl.env("XCURSOR_SIZE", 24)
hl.env("HYPRCURSOR_SIZE", 24)
hl.env("HYPRCURSOR_THEME", "BreezeX-RosePine-Linux")

local function has_nvidia_gpu()
    -- Fast check: See if Nvidia driver proc directory exists
    local proc_check = io.open("/proc/driver/nvidia/version", "r")
    if proc_check then
        proc_check:close()
        return true
    end

    -- Fallback check: Read PCI vendor IDs for 0x10de (Nvidia vendor code)
    local pfile = io.popen("grep -l '0x10de' /sys/bus/pci/devices/*/vendor 2>/dev/null")
    if pfile then
        local output = pfile:read("*a")
        pfile:close()
        if output and #output > 0 then
            return true
        end
    end

    return false
end

if has_nvidia_gpu() then
    hl.env("LIBVA_DRIVER_NAME", "nvidia")
    hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
end

--####################
--##    GENERAL    ###
--####################

hl.config({
    general = {
        gaps_in = 0,
        gaps_out = 0,
        border_size = 2,
        resize_on_border = true,
        allow_tearing = false,
        layout = "dwindle",
        col = {
            active_border = active_border,
            inactive_border = inactive_border,
        },
    },

    input = {
        kb_layout = "gb",
        kb_options = "caps:swapescape",
        follow_mouse = 1,
        sensitivity = 0.5,
        -- -1.0 - 1.0, 0 means no modification.
        touchpad = {
            natural_scroll = true,
        },
    },

    decoration = {
        rounding = 0,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        blur = {
            enabled = true,
            size = 7,
            passes = 1,
            noise = 0.1,
            vibrancy = 0.1696,
        },
        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = "rgba(1a1a1aee)",
        },
    },

    animations = {
        enabled = true,
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
    },

    debug = {
        disable_logs = false,
        gl_debugging = true,
        -- Enables OpenGL error messages
    },
})

hl.curve( "myBezier", { type = "bezier", points = { {0.05, 0.9}, {0.1, 1.05} } })

hl.animation({ leaf = "windows", enabled = true, speed = 8, bezier="myBezier"})
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7, bezier = "default", style = "popin 80%"})
hl.animation({ leaf = "border", enabled = true, speed = 10, bezier = "default"})
hl.animation({ leaf = "borderangle", enabled = true, speed = 8, bezier = "default"})
hl.animation({ leaf = "borderangle", enabled = true, speed = 7, bezier = "default"})
hl.animation({ leaf = "workspaces", enabled = false})

--############
--## INPUT ###
--############

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

hl.device({
    name = "keychron-keychron-k10-pro",
    kb_options = "caps:swapescape",
})

hl.bind("SUPER + Return", hl.dsp.exec_cmd("kitty"))
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + E", hl.dsp.exec_cmd("nautilus"))
hl.bind("SUPER + V", hl.dsp.window.float())
hl.bind("SUPER + D", hl.dsp.exec_cmd("rmenu apps"))
hl.bind("SUPER + F", hl.dsp.exec_cmd("rmenu find"))
hl.bind("SUPER + Escape", hl.dsp.exec_cmd("rmenu power"))
hl.bind("SUPER + P", hl.dsp.exec_cmd("keepassxc"))
hl.bind("SUPER + R", hl.dsp.exec_cmd("killall waybar; waybar &"))
hl.bind("SUPER + Z", hl.dsp.exec_cmd("zen-mode"))
hl.bind("SUPER + T", hl.dsp.exec_cmd("chromium --app=https://app.todoist.com/app/"))
hl.bind("SUPER + N", hl.dsp.exec_cmd("kitty -e fish -c nvim -c 'autocmd VimEnter * Telescope find_files'"))
hl.bind("SUPER + SHIFT + N", hl.dsp.exec_cmd("kitty -e fish -c nvim -c 'autocmd VimEnter * Telescope find_files hidden=true<CR>'"))
hl.bind("SUPER + SEMICOLON", hl.dsp.exec_cmd("swaync-client -t"))
hl.bind("PRINT", hl.dsp.exec_cmd("hyprshot -m output -m $(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')"))
hl.bind("SHIFT + PRINT", hl.dsp.exec_cmd("hyprshot -m region"))

-- Move focus with SUPER + arrow keys or vim keys

hl.bind("SUPER + left", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + right", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + up", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + down", hl.dsp.focus({ direction = "down" }))
hl.bind("SUPER + SHIFT + left", hl.dsp.window.move({ direction = "left" }))
hl.bind("SUPER + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind("SUPER + SHIFT + up", hl.dsp.window.move({ direction = "up" }))
hl.bind("SUPER + SHIFT + down", hl.dsp.window.move({ direction = "down" }))
hl.bind("SUPER + h", hl.dsp.focus({ direction = "left" }))
hl.bind("SUPER + l", hl.dsp.focus({ direction = "right" }))
hl.bind("SUPER + k", hl.dsp.focus({ direction = "up" }))
hl.bind("SUPER + j", hl.dsp.focus({ direction = "down" }))
hl.bind("SUPER + SHIFT + h", hl.dsp.window.move({ direction = "l" }))
hl.bind("SUPER + SHIFT + l", hl.dsp.window.move({ direction = "r" }))
hl.bind("SUPER + SHIFT + k", hl.dsp.window.move({ direction = "u" }))
hl.bind("SUPER + SHIFT + j", hl.dsp.window.move({ direction = "d" }))

-- TODO: manual review (unknown dispatcher: movecurrentworkspacetomonitor)
-- hl.bind("$"SUPER + SHIFT + PERIOD", hl.dsp.movecurrentworkspacetomonitor("r"))

-- TODO: manual review (unknown dispatcher: movecurrentworkspacetomonitor)
-- hl.bind("$"SUPER + SHIFT + COMMA", hl.dsp.movecurrentworkspacetomonitor("l"))

-- Switch workspaces with "SUPER + [0-9]
-- Move active window to a workspace with "SUPER + SHIFT + [0-9]

for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind("SUPER  + " .. key, hl.dsp.focus({ workspace = i}))
    hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Example special workspace (scratchpad)

hl.bind("SUPER + Minus", hl.dsp.workspace.toggle_special("magic"))
hl.bind("SUPER + SHIFT + Minus", hl.dsp.window.move({ workspace = "special:magic" }))

-- Scroll through existing workspaces with "SUPER + scroll

hl.bind("SUPER + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with "SUPER + LMB/RMB and dragging

hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set +5% -e"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%- -e"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pactl set-sink-volume 0 -5%"))
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pactl set-sink-volume 0 +5%"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pactl set-sink-mute 0 toggle"))

--#############################
--## WINDOWS AND WORKSPACES ###
--#############################

hl.window_rule({ name = "Supress all maximising", match = { class = ".*" }, suppress_event = "maximize" })

hl.window_rule({ name = "Float MPV", match = { class = "^(mpv)$", }, float = true})

-- KeepassXC window rules
hl.window_rule({ name = "Float KeepassXC", match = { class = "^(org.keepassxc.KeePassXC)$", }, float = true, center = true, stay_focused = true, size = { 800,600 } })

-- Todoist rules
hl.window_rule({ match = { class = "chrome-app.todoist.com__app_-Default", }, float = true, size = { 900, 900 },})

-- [570, 490]
hl.window_rule({ name = "Thunar Rename", match = { class = "^(Thunar)$", title = ".*Rename.*", }, float = true, })
hl.window_rule({ name = "Thunar Progress", match = { class = "^(Thunar)$", title = ".*File Operation Progress*", }, float = true, })

-- github.com/hyprwm/Hyprland/issues/4257
hl.window_rule({
    name  = "Jetbrains Tooltips Flickering",
    match = {
        class = "^(.*jetbrains.*)$",
        title = "^(win.*)$"
    },
    no_initial_focus = true,
    no_focus = true,
})

hl.window_rule({
    name  = "Jetbrains Tab-Dragging",
    match = {
        class = "^(.*jetbrains.*)",
        title = "^\\s$", --always have a single space character as their title
    },
    no_initial_focus = true,
    no_focus = true,
})

hl.window_rule({
    name  = "XWayland-popups",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
    },
    no_blur = true,
    no_shadow = true,
    --no_rounding = true,
})

hl.window_rule({ name = "Smart Gaps 1", match = { workspace = "w[tv1]", }, border_size = 0, rounding = 0 })

hl.window_rule({ name = "Smart Gaps 2", match = { workspace = "f[1]", }, border_size = 0, rounding = 0 })
