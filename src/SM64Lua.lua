-- SM64 Lua Redux, Powerful SM64 TASing utility

-- Core is heavily modified InputDirection lua by:
-- Author: MKDasher
-- Hacker: Eddio0141
-- Special thanks to Pannenkoek2012 and Peter Fedak for angle calculation support.
-- Also thanks to MKDasher to making the code very clean
-- Other contributors:
--	Madghostek, Xander, galoomba, ShadoXFM, Lemon, Manama, tjk

assert(emu.atloadstate, "emu.atloadstate missing")

-- forward-compat lua 5.4 shims
if not math.pow then
    math.pow = function(x, y)
        return x ^ y
    end
end
if not math.atan2 then
    math.atan2 = math.atan
end

function swap(arr, index_1, index_2)
    local tmp = arr[index_2]
    arr[index_2] = arr[index_1]
    arr[index_1] = tmp
end

function expand_rect(t)
    return {
        x = t[1],
        y = t[2],
        width = t[3],
        height = t[4],
    }
end

local queued_pause = false
local post_frame_advance_callback = nil

function frame_advance(func)
    emu.pause(true)
    queued_pause = true
    post_frame_advance_callback = func
end

path_sep = package.config:gsub("\n.+$", "")

folder = debug.getinfo(1).source:sub(2):match("(.*[\\/])")
res_path = folder .. "res" .. path_sep
local tabs_path = folder .. "tabs" .. path_sep
local core_path = folder .. "core" .. path_sep
local lib_path = folder .. "lib" .. path_sep


dofile(lib_path .. "mupen-lua-ugui.lua")
dofile(lib_path .. "mupen-lua-ugui-ext.lua")
dofile(lib_path .. "linq.lua")
dofile(res_path .. "base.lua")
dofile(core_path .. "Settings.lua")
dofile(core_path .. "Formatter.lua")
dofile(core_path .. "VarWatch.lua")
dofile(core_path .. "Presets.lua")
dofile(core_path .. "Drawing.lua")
dofile(core_path .. "Memory.lua")
dofile(core_path .. "Joypad.lua")
dofile(core_path .. "Angles.lua")
dofile(core_path .. "Engine.lua")
dofile(core_path .. "Buttons.lua")
dofile(core_path .. "MoreMaths.lua")
dofile(core_path .. "Actions.lua")
dofile(core_path .. "Swimming.lua")
dofile(core_path .. "Framewalk.lua")
dofile(core_path .. "Grind.lua")
dofile(core_path .. "WorldVisualizer.lua")
dofile(core_path .. "Lookahead.lua")
dofile(core_path .. "RNGToIndex.lua")
dofile(core_path .. "IndexToRNG.lua")
dofile(core_path .. "Ghost.lua")

Memory.initialize()
Joypad.update()
VarWatch.update()
Drawing.size_up()

local tabs = {
    dofile(tabs_path .. "TAS.lua"),
    dofile(tabs_path .. "Settings.lua"),
    dofile(tabs_path .. "Timer.lua"),
    dofile(tabs_path .. "Experiments.lua"),
    dofile(tabs_path .. "RNG.lua"),
    dofile(tabs_path .. "Ghost.lua"),
}

local current_tab_index = 1
local mouse_wheel = 0

function at_input()
    if queued_pause then
        emu.pause(false)
        queued_pause = false
        if post_frame_advance_callback then
            post_frame_advance_callback()
        end
    end

    -- frame stage 1: set everything up
    Memory.update_previous()
    Memory.update(true)
    VarWatch.update()

    Joypad.update()
    Engine.input()
    if Settings.movement_mode ~= Settings.movement_modes.disabled then
        result = Engine.inputsForAngle(Settings.goal_angle)
        if Settings.goal_mag then
            Engine.scaleInputsForMagnitude(result, Settings.goal_mag, Settings.high_magnitude)
        end
        Joypad.set('X', result.X)
        Joypad.set('Y', result.Y)
    end

    -- frame stage 2: let domain code loose on everything, then perform transformations or inspections (e.g.: swimming, rng override, ghost)
    tabs[current_tab_index].update()

    if Settings.override_rng then
        if Settings.override_rng_use_index then
            memory.writeword(0x00B8EEE0, get_value(Settings.override_rng_value))
        else
            memory.writeword(0x00B8EEE0, Settings.override_rng_value)
        end
    end

    Grind.update()
    Lookahead.update()

    Joypad.send()
    Swimming.swim()
    Framewalk.update()
    Ghost.update()
end

function at_update_screen()
    local keys = input.get()
    Mupen_lua_ugui.begin_frame({
        mouse_position = {
            x = keys.xmouse,
            y = keys.ymouse,
        },
        wheel = mouse_wheel,
        is_primary_down = keys.leftclick,
        held_keys = keys,
    })
    mouse_wheel = 0

    WorldVisualizer.draw()

    BreitbandGraphics.fill_rectangle({
        x = Drawing.initial_size.width,
        y = 0,
        width = Drawing.size.width - Drawing.initial_size.width,
        height = Drawing.size.height
    }, Settings.styles[Settings.active_style_index].theme.background_color)

    tabs[current_tab_index].draw()

    -- navigation and presets

    current_tab_index = Mupen_lua_ugui.carrousel_button({
        uid = -5000,

        rectangle = grid_rect(0, 15, 8, 1),
        items = lualinq.select_key(tabs, "name"),
        selected_index = current_tab_index,
    })

    for i = 1, #Presets.presets, 1 do
        local prev = Presets.current_index == i
        local now = Mupen_lua_ugui.toggle_button({
            uid = -5000 - 5 * i,

            rectangle = grid_rect(i - 1, 16, 1, 1),
            text = i,
            is_checked = Presets.current_index == i
        })

        if now and not prev then
            Presets.apply(i)
        end
    end

    if Mupen_lua_ugui.button({
            uid = -6000,

            rectangle = grid_rect(6, 16, 2, 1),
            text = "Reset"
        }) then
        Presets.reset(Presets.current_index)
        Presets.apply(Presets.current_index)
    end



    Mupen_lua_ugui.end_frame()
end

function at_vi()
    -- reading memory in at_input returns stale data(!) from previous frame...
    Memory.update()
    VarWatch.update()

    Engine.vi()
end

emu.atinput(at_input)
emu.atupdatescreen(at_update_screen)
emu.atvi(at_vi)
emu.atstop(Drawing.size_down)
emu.atwindowmessage(function(hwnd, msg_id, wparam, lparam)
    if msg_id == 522 then                         -- WM_MOUSEWHEEL
        -- high word (most significant 16 bits) is scroll rotation in multiples of WHEEL_DELTA (120)
        local scroll = math.floor(wparam / 65536) --(wparam & 0xFFFF0000) >> 16
        if scroll == 120 then
            mouse_wheel = 1
        elseif scroll == 65416 then -- 65536 - 120
            mouse_wheel = -1
        end
    end
end)
