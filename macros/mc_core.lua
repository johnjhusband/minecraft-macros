-- mc_core.lua
-- Shared utilities for all Minecraft Hammerspoon macro packs
-- Required by all category macro files

local Core = {}

-- Check if Minecraft is the focused window
function Core.isMinecraftFocused()
    local app = hs.application.frontmostApplication()
    if not app then return false end
    local name = app:name():lower()
    return name:find("minecraft") ~= nil or name == "java"
end

-- Show alert overlay (set Core.showAlerts = false to disable)
Core.showAlerts = false

function Core.alert(text, duration)
    if not Core.showAlerts then return end
    hs.alert.show("MC: " .. text, duration or 1)
end

-- Guard: only run if Minecraft is focused
function Core.guard(fn)
    return function()
        if not Core.isMinecraftFocused() then return end
        fn()
    end
end

-- Timer registry (prevents garbage collection)
Core._timers = {}

function Core.startTimer(name, predicate, fn, interval)
    Core.stopTimer(name)
    Core._timers[name] = hs.timer.doWhile(predicate, fn, interval)
end

function Core.stopTimer(name)
    if Core._timers[name] then
        Core._timers[name]:stop()
        Core._timers[name] = nil
    end
end

function Core.stopAllTimers()
    for name, _ in pairs(Core._timers) do
        Core.stopTimer(name)
    end
end

-- Toggle registry
Core._toggles = {}

function Core.toggle(name)
    Core._toggles[name] = not Core._toggles[name]
    return Core._toggles[name]
end

function Core.isOn(name)
    return Core._toggles[name] == true
end

function Core.setOff(name)
    Core._toggles[name] = false
end

function Core.resetAll()
    for k, _ in pairs(Core._toggles) do
        Core._toggles[k] = false
    end
    Core.stopAllTimers()
end

-- Send a raw mouse movement delta (for camera rotation in-game)
-- Note: Minecraft captures the cursor. This sends a mouseMoved event
-- with a position delta, which macOS translates to relative movement.
function Core.mouseMoveDelta(dx, dy)
    local pos = hs.mouse.absolutePosition()
    local evt = hs.eventtap.event.newMouseEvent(
        hs.eventtap.event.types.mouseMoved,
        {x = pos.x + dx, y = pos.y + dy}
    )
    evt:post()
end

-- Left click at current position
function Core.leftClick(delayUs)
    hs.eventtap.leftClick(hs.mouse.absolutePosition(), delayUs or 5000)
end

-- Right click at current position
function Core.rightClick(delayUs)
    hs.eventtap.rightClick(hs.mouse.absolutePosition(), delayUs or 5000)
end

-- Hold/release mouse buttons
function Core.leftDown()
    local pos = hs.mouse.absolutePosition()
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown, pos):post()
end

function Core.leftUp()
    local pos = hs.mouse.absolutePosition()
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, pos):post()
end

function Core.rightDown()
    local pos = hs.mouse.absolutePosition()
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.rightMouseDown, pos):post()
end

function Core.rightUp()
    local pos = hs.mouse.absolutePosition()
    hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.rightMouseUp, pos):post()
end

-- Key press helpers
function Core.keyDown(key)
    hs.eventtap.event.newKeyEvent(key, true):post()
end

function Core.keyUp(key)
    hs.eventtap.event.newKeyEvent(key, false):post()
end

function Core.keyPress(key, mods)
    hs.eventtap.keyStroke(mods or {}, key)
end

-- Sequence runner: executes a list of {action, delayMs} pairs
-- Each step is {fn, delayAfterMs}
function Core.runSequence(steps, idx)
    idx = idx or 1
    if idx > #steps then return end
    local step = steps[idx]
    step[1]()  -- run action
    if step[2] and step[2] > 0 and idx < #steps then
        hs.timer.doAfter(step[2] / 1000, function()
            Core.runSequence(steps, idx + 1)
        end)
    elseif idx < #steps then
        Core.runSequence(steps, idx + 1)
    end
end

-- Send chat message
function Core.chat(message)
    Core.keyPress("t")
    hs.timer.doAfter(0.2, function()
        hs.eventtap.keyStrokes(message)
        hs.timer.doAfter(0.05, function()
            Core.keyPress("return")
        end)
    end)
end

-- Hotkey binding helper
Core._hotkeys = {}

function Core.bind(mods, key, fn, name)
    local hk = hs.hotkey.bind(mods, key, Core.guard(fn))
    table.insert(Core._hotkeys, {hotkey = hk, name = name or key})
    return hk
end

return Core
