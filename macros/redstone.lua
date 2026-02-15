-- redstone.lua
-- Redstone / Technical macros for Minecraft (ported from AHK)
-- Requires mc_core.lua
--
-- INSTALL: Copy mc_core.lua and redstone.lua to ~/.hammerspoon/
--   In init.lua: require("redstone")

local C = require("mc_core")

local redstone = {}

-- ============================================================
-- 92. REPEATER DELAY CYCLING
-- Right-click repeater N times for desired tick delay (1-4)
-- AHK: Click Right N times with Sleep 50
-- ============================================================

function redstone.repeater1() C.rightClick() end
function redstone.repeater2()
    C.rightClick()
    hs.timer.doAfter(0.05, function() C.rightClick() end)
end
function redstone.repeater3()
    C.rightClick()
    hs.timer.doAfter(0.05, function()
        C.rightClick()
        hs.timer.doAfter(0.05, function() C.rightClick() end)
    end)
end
function redstone.repeater4()
    local clicks = 0
    local function click()
        if clicks >= 4 then return end
        C.rightClick()
        clicks = clicks + 1
        hs.timer.doAfter(0.05, click)
    end
    click()
end

-- ============================================================
-- 93. COMPARATOR TOGGLE
-- Right-click to toggle comparator mode
-- AHK: Click Right
-- ============================================================

function redstone.comparatorToggle()
    C.rightClick()
end

-- ============================================================
-- 94. PISTON TIMING SEQUENCE
-- Activate buttons in sequence with specific timing
-- AHK: Click Right, mouse_event turn, Click Right, repeat
-- ============================================================

function redstone.pistonSequence()
    C.alert("Piston Seq", true)
    C.runSequence({
        {function() C.rightClick() end, 100},
        {function() C.mouseMoveDelta(200, 0) end, 0},
        {function() C.rightClick() end, 100},
        {function() C.mouseMoveDelta(200, 0) end, 0},
        {function() C.rightClick() end, 0},
        {function() C.mouseMoveDelta(-400, 0) end, 0},  -- return view
    })
end

-- ============================================================
-- 95. TNT CANNON FIRING SEQUENCE
-- Dispense charge TNT, wait, fire projectile
-- AHK: Click Right, Sleep 2000, mouse turn, Click Right
-- ============================================================

function redstone.tntCannon()
    C.alert("TNT Fire!", true)
    C.runSequence({
        {function() C.rightClick() end, 2000},            -- charge TNT
        {function() C.mouseMoveDelta(300, 0) end, 0},     -- turn to projectile
        {function() C.rightClick() end, 0},                -- fire projectile
        {function() C.mouseMoveDelta(-300, 0) end, 0},    -- turn back
    })
end

-- ============================================================
-- 96. ITEM DROPPER TIMING
-- Drop items at precise intervals for hopper/dropper systems
-- AHK: Send {q}, Sleep 400, repeat
-- ============================================================

function redstone.toggleItemDropper()
    local on = C.toggle("itemDropper")
    C.alert("Item Dropper", on)
    if on then
        C.startTimer("itemDropper",
            function() return C.isOn("itemDropper") and C.isMinecraftFocused() end,
            function() C.keyPress("q") end,
            0.4  -- 4 redstone ticks between drops
        )
    else
        C.stopTimer("itemDropper")
    end
end

-- ============================================================
-- HOTKEY BINDINGS (Numpad keys)
-- ============================================================

C.bind({"ctrl", "alt"}, "pad1", redstone.repeater1, "Repeater 1")
C.bind({"ctrl", "alt"}, "pad2", redstone.repeater2, "Repeater 2")
C.bind({"ctrl", "alt"}, "pad3", redstone.repeater3, "Repeater 3")
C.bind({"ctrl", "alt"}, "pad4", redstone.repeater4, "Repeater 4")
C.bind({"ctrl", "alt"}, "pad5", redstone.comparatorToggle, "Comparator")
C.bind({"ctrl", "alt"}, "pad6", redstone.pistonSequence, "Piston Seq")
C.bind({"ctrl", "alt"}, "pad7", redstone.tntCannon, "TNT Cannon")
C.bind({"ctrl", "alt"}, "pad8", redstone.toggleItemDropper, "Item Dropper")

return redstone
