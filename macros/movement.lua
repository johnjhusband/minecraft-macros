-- movement.lua
-- Movement macros for Minecraft (ported from AHK)
-- Requires mc_core.lua
--
-- INSTALL: Copy mc_core.lua and movement.lua to ~/.hammerspoon/
--   In init.lua: require("movement")

local C = require("mc_core")

local movement = {}

movement.config = {
    bunnyHopMs       = 100,    -- Time between jumps
    strafeMs         = 100,    -- Strafe left/right duration
    strafePauseMs    = 20,     -- Pause between strafe switches
    swimSpamMs       = 50,     -- Swim key spam interval
}

local cfg = movement.config

-- ============================================================
-- 38. BUNNY HOP (Jump Spam While Moving)
-- Sprint + jump continuously
-- AHK: W+Ctrl down, Space spam
-- ============================================================

function movement.toggleBunnyHop()
    local on = C.toggle("bunnyHop")
    C.alert("Bunny Hop", on)
    if on then
        C.keyDown("w")
        C.keyDown("ctrl")
        C.startTimer("bunnyHop",
            function() return C.isOn("bunnyHop") and C.isMinecraftFocused() end,
            function() C.keyPress("space") end,
            cfg.bunnyHopMs / 1000
        )
    else
        C.stopTimer("bunnyHop")
        C.keyUp("w")
        C.keyUp("ctrl")
    end
end

-- ============================================================
-- 39. STRAFE PATTERN (A-D Alternating)
-- Dodge left-right while moving forward
-- AHK: W down, alternate A/D
-- ============================================================

function movement.toggleStrafe()
    local on = C.toggle("strafe")
    C.alert("Strafe", on)
    if on then
        C.keyDown("w")
        local goLeft = true
        local function step()
            if not C.isOn("strafe") or not C.isMinecraftFocused() then
                C.keyUp("w")
                C.keyUp("a")
                C.keyUp("d")
                return
            end
            local key = goLeft and "a" or "d"
            C.keyDown(key)
            hs.timer.doAfter(cfg.strafeMs / 1000, function()
                C.keyUp(key)
                goLeft = not goLeft
                hs.timer.doAfter(cfg.strafePauseMs / 1000, step)
            end)
        end
        step()
    else
        C.keyUp("w")
        C.keyUp("a")
        C.keyUp("d")
    end
end

-- ============================================================
-- 40. SPEED BRIDGE WALK
-- Walk backward with crouch timing for bridge building
-- AHK: S down, Shift toggle at optimal timing
-- ============================================================

function movement.toggleSpeedBridgeWalk()
    local on = C.toggle("speedBridgeWalk")
    C.alert("Speed Walk", on)
    if on then
        C.keyDown("s")
        C.startTimer("speedBridgeWalk",
            function() return C.isOn("speedBridgeWalk") and C.isMinecraftFocused() end,
            function()
                C.keyDown("shift")
                hs.timer.doAfter(0.1, function()
                    C.keyUp("shift")
                end)
            end,
            0.15
        )
    else
        C.stopTimer("speedBridgeWalk")
        C.keyUp("s")
        C.keyUp("shift")
    end
end

-- ============================================================
-- 41. SPRINT JUMP
-- Sprint + jump for maximum horizontal distance
-- AHK: Ctrl+W down, Space, release
-- ============================================================

function movement.sprintJump()
    C.runSequence({
        {function() C.keyDown("ctrl") end, 0},
        {function() C.keyDown("w") end, 50},
        {function() C.keyPress("space") end, 400},
        {function() C.keyUp("w") end, 0},
        {function() C.keyUp("ctrl") end, 0},
    })
end

-- ============================================================
-- 42. MLG WATER BUCKET
-- Look down, place water, pick up water
-- AHK: Send {5}, look down, Click Right x2, look up, Send {1}
-- ============================================================

function movement.mlgWater()
    C.alert("MLG!", true)
    C.runSequence({
        {function() C.keyPress("5") end, 30},
        {function() C.mouseMoveDelta(0, 1000) end, 50},
        {function() C.rightClick() end, 200},
        {function() C.rightClick() end, 30},
        {function() C.mouseMoveDelta(0, -1000) end, 0},
        {function() C.keyPress("1") end, 0},
    })
end

-- ============================================================
-- 43. BOAT CLUTCH
-- Place boat while falling, enter it
-- AHK: Send {6}, look down, Click Right x2, look up
-- ============================================================

function movement.boatClutch()
    C.alert("Boat!", true)
    C.runSequence({
        {function() C.keyPress("6") end, 30},
        {function() C.mouseMoveDelta(0, 800) end, 30},
        {function() C.rightClick() end, 100},
        {function() C.rightClick() end, 0},
        {function() C.mouseMoveDelta(0, -800) end, 0},
    })
end

-- ============================================================
-- 44. LADDER CLUTCH
-- Place ladder on wall while falling
-- AHK: Send {7}, Click Right x3
-- ============================================================

function movement.ladderClutch()
    C.alert("Ladder!", true)
    C.runSequence({
        {function() C.keyPress("7") end, 30},
        {function() C.rightClick() end, 50},
        {function() C.rightClick() end, 50},
        {function() C.rightClick() end, 0},
        {function() C.keyPress("1") end, 0},
    })
end

-- ============================================================
-- 45. TOGGLE FLY (Creative)
-- Double-tap space for creative flight
-- AHK: Space, Sleep 200, Space
-- ============================================================

function movement.toggleFly()
    C.runSequence({
        {function() C.keyDown("space") end, 75},
        {function() C.keyUp("space") end, 200},
        {function() C.keyDown("space") end, 75},
        {function() C.keyUp("space") end, 0},
    })
end

-- ============================================================
-- 46. ELYTRA BOOST (Firework + Elytra)
-- Double-jump to activate elytra, fire rocket
-- AHK: Space x2, Click Right (rocket)
-- ============================================================

function movement.elytraBoost()
    C.alert("Elytra!", true)
    C.runSequence({
        {function() C.keyDown("space") end, 75},
        {function() C.keyUp("space") end, 200},
        {function() C.keyDown("space") end, 75},
        {function() C.keyUp("space") end, 50},
        {function() C.rightClick() end, 0},
    })
end

-- ============================================================
-- 47. CRAWL TOGGLE
-- Place trapdoor above head to force crawl
-- AHK: Send {8}, look up, Click Right x2, look forward
-- ============================================================

function movement.crawlToggle()
    C.runSequence({
        {function() C.keyPress("8") end, 50},
        {function() C.mouseMoveDelta(0, -800) end, 50},
        {function() C.rightClick() end, 50},
        {function() C.rightClick() end, 0},
        {function() C.mouseMoveDelta(0, 800) end, 0},
    })
end

-- ============================================================
-- 48. SWIM SPAM
-- Rapidly press space while in water
-- AHK: W+Ctrl down, Space spam at 50ms
-- ============================================================

function movement.toggleSwimSpam()
    local on = C.toggle("swimSpam")
    C.alert("Swim Spam", on)
    if on then
        C.keyDown("w")
        C.keyDown("ctrl")
        C.startTimer("swimSpam",
            function() return C.isOn("swimSpam") and C.isMinecraftFocused() end,
            function() C.keyPress("space") end,
            cfg.swimSpamMs / 1000
        )
    else
        C.stopTimer("swimSpam")
        C.keyUp("w")
        C.keyUp("ctrl")
    end
end

-- ============================================================
-- HOTKEY BINDINGS (Ctrl+Shift prefix, number row)
-- ============================================================

C.bind({"ctrl", "shift"}, "1", movement.toggleBunnyHop, "Bunny Hop")
C.bind({"ctrl", "shift"}, "2", movement.toggleStrafe, "Strafe")
C.bind({"ctrl", "shift"}, "3", movement.toggleSpeedBridgeWalk, "Speed Walk")
C.bind({"ctrl", "shift"}, "4", movement.sprintJump, "Sprint Jump")
C.bind({"ctrl", "shift"}, "5", movement.mlgWater, "MLG Water")
C.bind({"ctrl", "shift"}, "6", movement.boatClutch, "Boat Clutch")
C.bind({"ctrl", "shift"}, "7", movement.ladderClutch, "Ladder Clutch")
C.bind({"ctrl", "shift"}, "8", movement.toggleFly, "Toggle Fly")
C.bind({"ctrl", "shift"}, "9", movement.elytraBoost, "Elytra Boost")
C.bind({"ctrl", "shift"}, "0", movement.crawlToggle, "Crawl Toggle")
C.bind({"ctrl", "shift"}, "-", movement.toggleSwimSpam, "Swim Spam")

return movement
