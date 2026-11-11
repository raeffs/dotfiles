local meh = "CTRL + ALT + SHIFT"

-- A client can ask the compositor to stop handling shortcuts. Looking Glass
-- does so while it has focus (grabKeyboardOnFocus), so that every key reaches
-- the VM. Binds with these options ignore the request.
local passthrough = { dont_inhibit = true }

local app = os.getenv("HOME") .. "/.config/defaults/app "

local terminal = app .. "terminal"
local explorer = app .. "explorer"
local launcher = app .. "launcher"

local lightroom = os.getenv("HOME") .. "/.local/bin/lightroom"

hl.bind(meh .. " + RETURN", hl.dsp.workspace.toggle_special("terminal"), passthrough)
hl.bind(meh .. " + T", hl.dsp.exec_cmd(terminal), passthrough)
hl.bind(meh .. " + SPACE", hl.dsp.exec_cmd(launcher), passthrough)
hl.bind(meh .. " + E", hl.dsp.exec_cmd(explorer), passthrough)
hl.bind(meh .. " + L", hl.dsp.exec_cmd(lightroom), passthrough)
hl.bind(meh .. " + BACKSPACE", hl.dsp.window.close(), passthrough)
hl.bind(meh .. " + K", hl.dsp.workspace.toggle_special("keepass"), passthrough)
