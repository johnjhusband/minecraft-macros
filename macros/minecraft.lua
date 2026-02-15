-- minecraft.lua
-- Hammerspoon macros for Minecraft Java Edition on Mac
-- Ported from popular AutoHotkey scripts used on Windows
--
-- INSTALL: Copy this file to ~/.hammerspoon/ and add this to your init.lua:
--   require("minecraft")
--
-- All macros only activate when Minecraft is the focused window.
-- Press Ctrl+Shift+M to enable/disable the macro system.

local M = {}

-- ============================================================
-- CONFIGURATION
-- ============================================================

M.config = {
    autoClickCPS      = 12,      -- Clicks per second for auto-clicker
    swordCooldownMs   = 625,     -- Sword cooldown (625ms = 1.9+ diamond sword)
    wtapDownMs        = 45,      -- W-tap key-down duration
    wtapUpMs          = 45,      -- W-tap key-up duration
    eatDurationMs     = 5000,    -- How long to hold right-click to eat
    foodSlot          = "2",     -- Hotbar slot for food
    swordSlot         = "1",     -- Hotbar slot for sword
    antiAfkIntervalS  = 60,      -- Seconds between anti-AFK movements
}

-- ============================================================
-- STATE
-- ============================================================

local enabled = false
local timers = {}
local toggles = {
    autoClick   = false,
    leftHold    = false,
    rightHold   = false,
    autoWalk    = false,
    sprint      = false,
    crouch      = false,
    wtap        = false,
    timedAttack = false,
    antiAfk     = false,
}

-- ============================================================
-- HELPERS
-- ============================================================

local function isMinecraftFocused()
    local app = hs.application.frontmostApplication()
    if not app then return false end
    local name = app:name():lower()
    return name:find("minecraft") ~= nil or name == "java"
end

local function stopTimer(name)
    if timers[name] then
        timers[name]:stop()
        timers[name] = nil
    end
end

local function stopAllTimers()
    for name, _ in pairs(timers) do
        stopTimer(name)
    end
end

local function resetAllToggles()
    for k, _ in pairs(toggles) do
        toggles[k] = false
    end
    stopAllTimers()
end

local function showStatus(name, state)
    if state then
        hs.alert.show("MC: " .. name .. " ON", 1)
    else
        hs.alert.show("MC: " .. name .. " OFF", 1)
    end
end

local function guard(fn)
    return function()
        if not enabled then return end
        if not isMinecraftFocused() then return end
        fn()
    end
end

-- ============================================================
-- 1. AUTO-CLICKER (Left Click Repeat)
--    AHK equivalent: Ctrl+Z toggle, clicks at ~12 CPS
--    Use: PvP combat on 1.8 servers, AFK mob farms
-- ============================================================

local function toggleAutoClick()
    toggles.autoClick = not toggles.autoClick
    showStatus("Auto-Click", toggles.autoClick)

    if toggles.autoClick then
        local delay = 1.0 / M.config.autoClickCPS
        timers.autoClick = hs.timer.doWhile(
            function() return toggles.autoClick and isMinecraftFocused() end,
            function() hs.eventtap.leftClick(hs.mouse.absolutePosition(), 5000) end,
            delay
        )
    else
        stopTimer("autoClick")
    end
end

-- ============================================================
-- 2. HOLD LEFT-CLICK (Toggle Mining/Attack)
--    AHK equivalent: F1 toggle LButton Down/Up
--    Use: AFK mining, AFK mob killing
-- ============================================================

local function toggleLeftHold()
    toggles.leftHold = not toggles.leftHold
    showStatus("Left-Hold", toggles.leftHold)

    local pos = hs.mouse.absolutePosition()
    if toggles.leftHold then
        hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseDown, pos):post()
    else
        hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.leftMouseUp, pos):post()
    end
end

-- ============================================================
-- 3. HOLD RIGHT-CLICK (Toggle Eat/Block/Fish)
--    AHK equivalent: F11 toggle RButton Down/Up
--    Use: Eating food, blocking with shield, AFK fishing
-- ============================================================

local function toggleRightHold()
    toggles.rightHold = not toggles.rightHold
    showStatus("Right-Hold", toggles.rightHold)

    local pos = hs.mouse.absolutePosition()
    if toggles.rightHold then
        hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.rightMouseDown, pos):post()
    else
        hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.rightMouseUp, pos):post()
    end
end

-- ============================================================
-- 4. AUTO-WALK (Toggle W key)
--    AHK equivalent: F2 toggle W Down/Up
--    Use: Long distance travel, ice roads
-- ============================================================

local function toggleAutoWalk()
    toggles.autoWalk = not toggles.autoWalk
    showStatus("Auto-Walk", toggles.autoWalk)

    if toggles.autoWalk then
        hs.eventtap.event.newKeyEvent("w", true):post()
    else
        hs.eventtap.event.newKeyEvent("w", false):post()
    end
end

-- ============================================================
-- 5. TOGGLE SPRINT (Ctrl+W)
--    AHK equivalent: F9 hold Ctrl+W
--    Use: Sprint without holding two keys
-- ============================================================

local function toggleSprint()
    toggles.sprint = not toggles.sprint
    showStatus("Sprint", toggles.sprint)

    if toggles.sprint then
        hs.eventtap.event.newKeyEvent("ctrl", true):post()
        hs.eventtap.event.newKeyEvent("w", true):post()
    else
        hs.eventtap.event.newKeyEvent("w", false):post()
        hs.eventtap.event.newKeyEvent("ctrl", false):post()
    end
end

-- ============================================================
-- 6. TOGGLE CROUCH/SNEAK (Toggle Shift)
--    AHK equivalent: Ctrl+R toggle Shift
--    Use: Edge building, bridging
-- ============================================================

local function toggleCrouch()
    toggles.crouch = not toggles.crouch
    showStatus("Crouch", toggles.crouch)

    if toggles.crouch then
        hs.eventtap.event.newKeyEvent("shift", true):post()
    else
        hs.eventtap.event.newKeyEvent("shift", false):post()
    end
end

-- ============================================================
-- 7. W-TAP (Sprint Reset for PvP)
--    AHK equivalent: F9 rapid W tap with 45ms intervals
--    Use: PvP knockback advantage on 1.8 servers
-- ============================================================

local function toggleWtap()
    toggles.wtap = not toggles.wtap
    showStatus("W-Tap", toggles.wtap)

    if toggles.wtap then
        local downMs = M.config.wtapDownMs / 1000
        local upMs = M.config.wtapUpMs / 1000
        local step = 0

        timers.wtap = hs.timer.doWhile(
            function() return toggles.wtap and isMinecraftFocused() end,
            function()
                if step == 0 then
                    hs.eventtap.event.newKeyEvent("w", true):post()
                    step = 1
                else
                    hs.eventtap.event.newKeyEvent("w", false):post()
                    step = 0
                end
            end,
            downMs
        )
    else
        stopTimer("wtap")
        hs.eventtap.event.newKeyEvent("w", false):post()
    end
end

-- ============================================================
-- 8. TIMED SWORD ATTACK (1.9+ Cooldown Timer)
--    AHK equivalent: F6 click on cooldown interval
--    Use: AFK mob farms in 1.9+ (max damage per hit)
-- ============================================================

local function toggleTimedAttack()
    toggles.timedAttack = not toggles.timedAttack
    showStatus("Timed Attack", toggles.timedAttack)

    if toggles.timedAttack then
        local interval = M.config.swordCooldownMs / 1000
        timers.timedAttack = hs.timer.doWhile(
            function() return toggles.timedAttack and isMinecraftFocused() end,
            function() hs.eventtap.leftClick(hs.mouse.absolutePosition(), 5000) end,
            interval
        )
    else
        stopTimer("timedAttack")
    end
end

-- ============================================================
-- 9. AUTO-EAT (Swap to food, eat, swap back)
--    AHK equivalent: F7 swap-eat-swap sequence
--    Use: Mid-combat healing
-- ============================================================

local function autoEat()
    showStatus("Eating...", true)
    -- Switch to food slot
    hs.eventtap.keyStroke({}, M.config.foodSlot)
    -- Hold right-click to eat
    hs.timer.doAfter(0.1, function()
        local pos = hs.mouse.absolutePosition()
        hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.rightMouseDown, pos):post()
        -- Release after eat duration and swap back
        hs.timer.doAfter(M.config.eatDurationMs / 1000, function()
            hs.eventtap.event.newMouseEvent(hs.eventtap.event.types.rightMouseUp, pos):post()
            hs.timer.doAfter(0.1, function()
                hs.eventtap.keyStroke({}, M.config.swordSlot)
                showStatus("Eating...", false)
            end)
        end)
    end)
end

-- ============================================================
-- 10. ANTI-AFK (Periodic movement to avoid kick)
--     AHK equivalent: F10 jump + walk every minute
--     Use: Stay online overnight
-- ============================================================

local function toggleAntiAfk()
    toggles.antiAfk = not toggles.antiAfk
    showStatus("Anti-AFK", toggles.antiAfk)

    if toggles.antiAfk then
        timers.antiAfk = hs.timer.doWhile(
            function() return toggles.antiAfk end,
            function()
                if not isMinecraftFocused() then return end
                hs.eventtap.keyStroke({}, "space")
                hs.timer.doAfter(0.5, function()
                    hs.eventtap.event.newKeyEvent("w", true):post()
                    hs.timer.doAfter(0.5, function()
                        hs.eventtap.event.newKeyEvent("w", false):post()
                        hs.timer.doAfter(0.3, function()
                            hs.eventtap.event.newKeyEvent("s", true):post()
                            hs.timer.doAfter(0.5, function()
                                hs.eventtap.event.newKeyEvent("s", false):post()
                            end)
                        end)
                    end)
                end)
            end,
            M.config.antiAfkIntervalS
        )
    else
        stopTimer("antiAfk")
    end
end

-- ============================================================
-- HOTKEY BINDINGS
-- ============================================================
-- All keys use Ctrl+Shift prefix to avoid conflicts with Minecraft keys.
-- Ctrl+Shift+M = Master enable/disable
--
-- Combat:
--   Ctrl+Shift+A = Auto-clicker (fast clicking)
--   Ctrl+Shift+T = Timed attack (1.9+ cooldown)
--   Ctrl+Shift+W = W-Tap (PvP sprint reset)
--   Ctrl+Shift+E = Auto-eat (swap, eat, swap back)
--
-- Movement:
--   Ctrl+Shift+F = Auto-walk forward
--   Ctrl+Shift+R = Toggle sprint
--   Ctrl+Shift+C = Toggle crouch/sneak
--   Ctrl+Shift+K = Anti-AFK
--
-- Mouse:
--   Ctrl+Shift+L = Hold left-click (mine/attack)
--   Ctrl+Shift+H = Hold right-click (eat/block/fish)
-- ============================================================

local hotkeys = {}

local function bindKey(mods, key, fn)
    local hk = hs.hotkey.new(mods, key, guard(fn))
    table.insert(hotkeys, hk)
end

-- Master toggle
hs.hotkey.bind({"ctrl", "shift"}, "M", function()
    enabled = not enabled
    if enabled then
        for _, hk in ipairs(hotkeys) do hk:enable() end
        hs.alert.show("Minecraft Macros ENABLED", 2)
    else
        resetAllToggles()
        for _, hk in ipairs(hotkeys) do hk:disable() end
        hs.alert.show("Minecraft Macros DISABLED", 2)
    end
end)

-- Combat
bindKey({"ctrl", "shift"}, "A", toggleAutoClick)
bindKey({"ctrl", "shift"}, "T", toggleTimedAttack)
bindKey({"ctrl", "shift"}, "W", toggleWtap)
bindKey({"ctrl", "shift"}, "E", autoEat)

-- Movement
bindKey({"ctrl", "shift"}, "F", toggleAutoWalk)
bindKey({"ctrl", "shift"}, "R", toggleSprint)
bindKey({"ctrl", "shift"}, "C", toggleCrouch)
bindKey({"ctrl", "shift"}, "K", toggleAntiAfk)

-- Mouse holds
bindKey({"ctrl", "shift"}, "L", toggleLeftHold)
bindKey({"ctrl", "shift"}, "H", toggleRightHold)

return M
