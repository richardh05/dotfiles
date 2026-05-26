import os
from collections.abc import Callable

import libqtile.resources
from libqtile import bar, hook, layout, qtile, widget
from libqtile.config import Click, Drag, Group, Key, Match, Output, Screen
from libqtile.lazy import lazy
from libqtile.backend.wayland.inputs import InputConfig
import subprocess

mod = "mod4"
terminal = "kitty"

keys = [
    # A list of available commands that can be bound to keys can be found
    # at https://docs.qtile.org/en/latest/manual/config/lazy.html
    
    # Focus movement
    Key([mod], "h", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "l", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "j", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Move focus up"),
    Key([mod], "left", lazy.layout.left(), desc="Move focus to left"),
    Key([mod], "right", lazy.layout.right(), desc="Move focus to right"),
    Key([mod], "down", lazy.layout.down(), desc="Move focus down"),
    Key([mod], "up", lazy.layout.up(), desc="Move focus up"),
    
    # Window movement
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window to the left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(), desc="Move window to the right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),
    Key([mod, "shift"], "left", lazy.layout.shuffle_left(), desc="Move window to the left"),
    Key([mod, "shift"], "right", lazy.layout.shuffle_right(), desc="Move window to the right"),
    Key([mod, "shift"], "down", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "up", lazy.layout.shuffle_up(), desc="Move window up"),
    
    # App launchers & Custom bindings
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    Key([mod], "q", lazy.window.kill(), desc="Kill focused window"),
    Key([mod], "e", lazy.spawn("nautilus"), desc="Launch nautilus"),
    Key([mod], "v", lazy.window.toggle_floating(), desc="Toggle floating"),
    Key([mod], "d", lazy.spawn("rmenu apps"), desc="Launch rmenu apps"),
    Key([mod], "f", lazy.spawn("rmenu find"), desc="Launch rmenu find"),
    Key([mod], "Escape", lazy.spawn("rmenu power"), desc="Launch rmenu power"),
    Key([mod], "p", lazy.spawn("keepassxc"), desc="Launch keepassxc"),
    Key([mod], "r", lazy.spawn("killall waybar; waybar &"), desc="Reload waybar"),
    Key([mod], "z", lazy.spawn("zen-mode"), desc="Launch zen-mode"),
    Key([mod], "t", lazy.spawn("chromium --app=https://app.todoist.com/app/"), desc="Launch todoist"),
    Key([mod], "n", lazy.spawn("kitty -e fish -c \"nvim -c 'autocmd VimEnter * Telescope find_files'\""), desc="Launch nvim find files"),
    Key([mod, "shift"], "n", lazy.spawn("kitty -e fish -c \"nvim -c 'autocmd VimEnter * Telescope find_files hidden=true<CR>'\""), desc="Launch nvim find files hidden"),
    Key([mod], "semicolon", lazy.spawn("swaync-client -t"), desc="Toggle swaync"),
    
    # Screenshots & Media 
    # Note: `hyprshot` will only work on Hyprland, consider changing these to `grim`/`slurp` (Wayland) or `scrot` (X11) in the future.
    Key([], "Print", lazy.spawn("hyprshot -m output -m \"$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')\""), desc="Screenshot output"),
    Key(["shift"], "Print", lazy.spawn("hyprshot -m region"), desc="Screenshot region"),
    Key([], "XF86MonBrightnessUp", lazy.spawn("brightnessctl set +5% -e"), desc="Brightness Up"),
    Key([], "XF86MonBrightnessDown", lazy.spawn("brightnessctl set 5%- -e"), desc="Brightness Down"),
    Key([], "XF86AudioRaiseVolume", lazy.spawn("pactl set-sink-volume 0 +5%"), desc="Volume Up"),
    Key([], "XF86AudioLowerVolume", lazy.spawn("pactl set-sink-volume 0 -5%"), desc="Volume Down"),
    Key([], "XF86AudioMute", lazy.spawn("pactl set-sink-mute 0 toggle"), desc="Volume Mute"),
    
    # Screen switching
    Key([mod, "shift"], "period", lazy.next_screen(), desc="Move to next monitor"),
    Key([mod, "shift"], "comma", lazy.prev_screen(), desc="Move to prev monitor"),
    
    # Qtile specific & system actions
    Key([mod], "Tab", lazy.next_layout(), desc="Toggle between layouts"),
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload the config"),
    Key([mod, "control"], "q", lazy.shutdown(), desc="Shutdown Qtile"),
]

# Add key bindings to switch VTs in Wayland.
# We can't check qtile.core.name in default config as it is loaded before qtile is started
# We therefore defer the check until the key binding is run by using .when(func=...)
for vt in range(1, 8):
    keys.append(
        Key(
            ["control", "mod1"],
            f"f{vt}",
            lazy.core.change_vt(vt).when(func=lambda: qtile.core.name == "wayland"),
            desc=f"Switch to VT{vt}",
        )
    )


groups = [Group(i) for i in "1234567890"]

for i in groups:
    keys.extend(
        [
            # mod + group number = switch to group
            Key(
                [mod],
                i.name,
                lazy.group[i.name].toscreen(),
                desc=f"Switch to group {i.name}",
            ),
            # mod + shift + group number = switch to & move focused window to group
            Key(
                [mod, "shift"],
                i.name,
                lazy.window.togroup(i.name, switch_group=True),
                desc=f"Switch to & move focused window to group {i.name}",
            ),
            # Or, use below if you prefer not to switch to that group.
            # # mod + shift + group number = move focused window to group
            # Key([mod, "shift"], i.name, lazy.window.togroup(i.name),
            #     desc="move focused window to group {}".format(i.name)),
        ]
    )

layout_theme = {
    "border_width": 2,
    "margin": 0,
}

layouts = [
    layout.Columns(**layout_theme),
    layout.Max(**layout_theme),
    # Try more layouts by unleashing below layouts.
    # layout.Stack(num_stacks=2),
    # layout.Bsp(),
    # layout.Matrix(),
    # layout.MonadTall(),
    # layout.MonadWide(),
    # layout.RatioTile(),
    # layout.Tile(),
    # layout.TreeTab(),
    # layout.VerticalTile(),
    # layout.Zoomy(),
]

widget_defaults = dict(
    font="Ubuntu Nerd Font",
    fontsize=14,
    padding=5,
    background="#1a1a22",
    foreground="#e0def4",
)
extension_defaults = widget_defaults.copy()

logo = os.path.join(os.path.dirname(libqtile.resources.__file__), "logo.png")
screens = [
    Screen(
        top=bar.Bar(
            [
                # Left Modules
                widget.GroupBox(
                    font="Noto Serif Black",
                    fontsize=14,
                    margin_y=3,
                    margin_x=2,
                    padding_y=2,
                    padding_x=3,
                    borderwidth=3,
                    active="#e0def4",
                    inactive="#e0def4",
                    rounded=True,
                    highlight_color="#1a1a22",
                    highlight_method="block",
                    this_current_screen_border="#e0def4",
                    this_screen_border="#e0def4",
                    block_highlight_text_color="#191724",
                    urgent_text="#eb6f92",
                    urgent_border="#eb6f92",
                    disable_drag=True,
                ),
                widget.Spacer(),
                
                # Center Modules
                widget.Clock(format="%H:%M", font="Noto Serif Black"),
                widget.Spacer(),
                
                # Right Modules
                widget.CPU(format=" {load_percent}%", padding=10),
                widget.Backlight(backlight_name="intel_backlight", format=" {percent:2.0%}", padding=10),
                widget.PulseVolume(fmt="  {}", padding=10),
                widget.Battery(
                    format="{char} {percent:2.0%}",
                    charge_char="󰂄",
                    discharge_char="",
                    empty_char="",
                    full_char="",
                    unknown_char="",
                    padding=10
                ),
                widget.StatusNotifier(padding=10),
                widget.Spacer(length=5),
            ],
            30,
            # border_width=[2, 0, 2, 0],  # Draw top and bottom borders
            # border_color=["ff00ff", "000000", "ff00ff", "000000"]  # Borders are magenta
        ),
        background="#000000",
        wallpaper=logo,
        wallpaper_mode="center",
        # You can uncomment this variable if you see that on X11 floating resize/moving is laggy
        # By default we handle these events delayed to already improve performance, however your system might still be struggling
        # This variable is set to None (no cap) by default, but you can set it to 60 to indicate that you limit it to 60 events per second
        # x11_drag_polling_rate = 60,
    ),
]

# Instead of screens, you can define a function here to specify which Screen
# should correspond to which Output.
fake_screens: list[Screen] | None = None

# Instead of screens or fake screens, you can define a function here that
# returns a list of Screen objects based on the list of Outputs; that way you
# can decide based on e.g. the number of screens, or which ports are plugged
# in exactly what do render in each bar for each screen.
generate_screens: Callable[[list[Output]], list[Screen]] | None = None

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
floats_kept_above = True
cursor_warp = False
floating_layout = layout.Floating(
    float_rules=[
        # Run the utility of `xprop` to see the wm class and name of an X client.
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
        
        # Custom rules ported from Hyprland
        Match(wm_class="mpv"),
        Match(wm_class="org.keepassxc.KeePassXC"),
        Match(wm_class="keepassxc"),
        Match(wm_class="chrome-app.todoist.com__app_-Default"),
        Match(wm_class="Thunar", title="Rename.*"),
        Match(wm_class="Thunar", title="File Operation Progress.*"),
    ]
)
auto_fullscreen = True
focus_on_window_activation = "smart"
focus_previous_on_window_remove = False
reconfigure_screens = True

# If things like steam games want to auto-minimize themselves when losing
# focus, should we respect this or not?
auto_minimize = True

# When using the Wayland backend, this can be used to configure input devices.
wl_input_rules = {
    "type:keyboard": InputConfig(kb_layout="gb", kb_options="caps:swapescape"),
    "type:touchpad": InputConfig(natural_scroll=True, pointer_accel=0.5),
    "type:pointer": InputConfig(pointer_accel=0.5),

    # Example per-device config ported from Hyprland
    # Note: Device names might differ slightly in Qtile. You can check your ~/.local/share/qtile/qtile.log if this name doesn't match perfectly.
    "keychron-keychron-k10-pro": InputConfig(kb_layout="gb", kb_options="caps:swapescape, altwin:swap_alt_win")
}

# xcursor theme (string or None) and size (integer) for Wayland backend
wl_xcursor_theme = "BreezeX-RosePine-Linux"
wl_xcursor_size = 24

idle_timers = []  # type: list
idle_inhibitors = []  # type: list
wmname = "LG3D"

@hook.subscribe.startup_once
def autostart():
    processes = [
        ['nm-applet'],
        ['waybar'],
        ['hypridle'],
        ['hyprpaper'],
        ['gsettings', 'set', 'org.gnome.desktop.interface', 'gtk-theme', 'rose-pine-gtk'],
        ['gsettings', 'set', 'org.gnome.desktop.interface', 'icon-theme', 'Papirus-Dark'],
        ['dbus-update-activation-environment', '--systemd', 'WAYLAND_DISPLAY', 'XDG_CURRENT_DESKTOP'],
        ['systemctl', '--user', 'start', 'hyprpolkitagent']
    ]
    for p in processes:
        subprocess.Popen(p)