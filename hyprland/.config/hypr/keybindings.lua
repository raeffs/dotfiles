---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

----------------------
---- DEFAULT APPS ----
----------------------

-- Default applications live in ~/.config/defaults/app so they can be shared
-- with anything else that needs them (scripts, quickshell, ...).
local app = os.getenv("HOME") .. "/.config/defaults/app "

local terminal = app .. "terminal"
local explorer = app .. "explorer"
local launcher = app .. "launcher"

-- Terminal
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))
-- App Launcher
hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd(launcher))
-- Explorer
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(explorer))

---------------
---- SHELL ----
---------------

-- Dock
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("qs ipc call dock toggle"))
-- Bar
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("qs ipc call bar toggle"))
-- Zen mode: bar and dock hidden together
hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd("qs ipc call zen toggle"))
-- Lock screen: its own qs process, so a shell reload cannot drop it
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("qs -n -p ~/.config/quickshell/lock.qml"))
-- Power menu: lock, suspend, log out, restart, shut down
hl.bind(mainMod .. " + ESCAPE", hl.dsp.exec_cmd("qs ipc call power toggle"))

------------------------
---- WINDOW CONTROL ----
------------------------

-- Close Window
hl.bind(mainMod .. " + C", hl.dsp.window.close())

---------------------------
---- WORKSPACE CONTROL ----
---------------------------

-- Workspace switcher in the shell: hold ALT, tap TAB, release ALT. The
-- release bind is transparent so the TAB press cannot shadow it, and it
-- carries ALT because Hyprland matches a released modifier against the
-- mods the bind asks for.
hl.bind("ALT + TAB",         hl.dsp.exec_cmd("qs ipc call switcher next"))
hl.bind("ALT + SHIFT + TAB", hl.dsp.exec_cmd("qs ipc call switcher prev"))
hl.bind("ALT + Alt_L",       hl.dsp.exec_cmd("qs ipc call switcher commit"),
        { release = true, transparent = true })

local function set_layout(layout)
    return function()
        local ws = hl.get_active_workspace()
        if ws then
            hl.workspace_rule({ workspace = tostring(ws.id), layout = layout })
        end
    end
end

local function cycle_layout()
    local ws = hl.get_active_workspace()
    if not ws then return end
    local order = { scrolling = "master", master = "dwindle", dwindle = "scrolling" }
    hl.workspace_rule({
        workspace = tostring(ws.id),
        layout    = order[ws.tiled_layout] or "scrolling",
    })
end

-- Scrolling Layout
hl.bind(mainMod .. " + ALT + S", set_layout("scrolling"))
-- Master Layout
hl.bind(mainMod .. " + ALT + M", set_layout("master"))
-- Monocle Layout
hl.bind(mainMod .. " + ALT + O", set_layout("monocle"))
-- Dwindle Layout
-- hl.bind(mainMod .. " + ALT + D", set_layout("dwindle"))
-- Cycle Layouts
-- hl.bind(mainMod .. " + ALT + TAB", cycle_layout)



-- from default config

-- hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))

-- hl.bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
-- hl.bind(mainMod .. " + P", hl.dsp.window.pseudo())
-- hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))    -- dwindle only

-- Move focus with mainMod + arrow keys
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with mainMod + [0-9]
-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i}))
    hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end

---------------------------
---- DROPDOWN TERMINAL ----
---------------------------

-- A special workspace renders on top of the current one instead of replacing
-- it, and stays out of the normal workspace cycle (ALT + TAB). on_created_empty
-- spawns the terminal the first time it is toggled open, and again whenever it
-- was closed, so it always comes back with a shell in it.
hl.workspace_rule({
    workspace        = "special:terminal",
    on_created_empty = terminal,
    -- Inset the workspace so it drops from the top edge over the upper half of
    -- the screen. Absolute pixels, sized for a 2560x1440 logical desktop.
    gaps_out         = { top = 128, right = 256, bottom = 128, left = 256 },
})

-- Toggle Dropdown Terminal
hl.bind(mainMod .. " + ALT + RETURN", hl.dsp.workspace.toggle_special("terminal"))

-----------------
---- KEEPASS ----
-----------------

-- Same overlay pattern as the dropdown terminal. KeePassXC is a Flatpak and
-- single-instance, so a launch while it sits hidden in the tray just re-shows
-- its window, which still goes through the window rule below.
local keepass = "flatpak run org.keepassxc.KeePassXC"

hl.workspace_rule({
    workspace        = "special:keepass",
    on_created_empty = keepass,
    gaps_out         = { top = 128, right = 256, bottom = 128, left = 256 },
})

-- Every KeePassXC window (main window, unlock prompt, dialogs) lands on the
-- overlay, whether it came from the keybind, the launcher or the dock. Not
-- silent: opening it from anywhere should show it.
hl.window_rule({
    name      = "keepass-on-overlay",
    match     = { class = "^org\\.keepassxc\\.KeePassXC$" },
    workspace = "special:keepass",
})

-- Toggle KeePass
hl.bind(mainMod .. " + ALT + K", hl.dsp.workspace.toggle_special("keepass"))

-------------------
---- LIGHTROOM ----
-------------------

-- Windows VM through Looking Glass. The launcher starts the VM when needed.
local lightroom = os.getenv("HOME") .. "/.local/bin/lightroom"

-- inactive_opacity dims unfocused windows to 0.9, which falsifies the colours
-- of a photo. The VM window stays fully opaque, focused or not.
hl.window_rule({
    name    = "looking-glass-opaque",
    match   = { class = "^looking-glass-client$" },
    opacity = "1.0 override 1.0 override",
})

-- Lightroom
hl.bind(mainMod .. " + ALT + L", hl.dsp.exec_cmd(lightroom))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
-- hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
-- hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      { locked = true, repeating = true })
-- hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     { locked = true, repeating = true })
-- hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   { locked = true, repeating = true })
-- hl.bind("XF86MonBrightnessUp",  hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  { locked = true, repeating = true })
-- hl.bind("XF86MonBrightnessDown",hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  { locked = true, repeating = true })

-- Requires playerctl
-- hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
-- hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
-- hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
-- hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
