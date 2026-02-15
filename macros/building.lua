-- building.lua
-- Building macros for Minecraft (ported from AHK)
-- Requires mc_core.lua
--
-- INSTALL: Copy mc_core.lua and building.lua to ~/.hammerspoon/
--   In init.lua: require("building")

local C = require("mc_core")

local building = {}

building.config = {
    bridgeCrouchMs   = 140,    -- Crouch duration at edge
    bridgeWalkMs     = 200,    -- Walk duration between placements
    bridgeUncrouchMs = 10,     -- Time uncrouched to place block
    pillarJumpMs     = 200,    -- Wait at jump peak before placing
    wallWidth        = 5,
    wallHeight       = 3,
    floorRowLength   = 10,
    floorNumRows     = 10,
    platformSize     = 5,
    lookDownDelta    = 600,
    lookStraightDown = 1000,
    turn90Delta      = 5500,
    turn180Delta     = 11000,
}

local cfg = building.config

-- ============================================================
-- 26. NINJA BRIDGE (Backward Bridge with Shift Toggle)
-- Walk backward, crouch at edge, place block, uncrouch, repeat
-- AHK: Petelax/Minecraft-Macros Home/End
-- ============================================================

function building.toggleNinjaBridge()
    local on = C.toggle("ninjaBridge")
    C.alert("Ninja Bridge", on)
    if on then
        C.keyDown("s")
        local function step()
            if not C.isOn("ninjaBridge") or not C.isMinecraftFocused() then
                C.keyUp("s")
                return
            end
            C.keyDown("shift")
            hs.timer.doAfter(cfg.bridgeCrouchMs / 1000, function()
                C.rightClick()
                hs.timer.doAfter(0.03, function()
                    C.keyUp("shift")
                    hs.timer.doAfter(cfg.bridgeWalkMs / 1000, step)
                end)
            end)
        end
        hs.timer.doAfter(0.225, step)
    else
        C.keyUp("s")
        C.keyUp("shift")
    end
end

-- ============================================================
-- 27. SPEED BRIDGE
-- Faster ninja bridge with tighter timing
-- AHK: Shift down, walk back, unshift-click-reshift quickly
-- ============================================================

function building.toggleSpeedBridge()
    local on = C.toggle("speedBridge")
    C.alert("Speed Bridge", on)
    if on then
        C.keyDown("s")
        C.keyDown("shift")
        local function step()
            if not C.isOn("speedBridge") or not C.isMinecraftFocused() then
                C.keyUp("s")
                C.keyUp("shift")
                return
            end
            C.keyUp("shift")
            hs.timer.doAfter(0.01, function()
                C.rightClick()
                hs.timer.doAfter(0.01, function()
                    C.keyDown("shift")
                    hs.timer.doAfter(0.15, step)
                end)
            end)
        end
        hs.timer.doAfter(0.05, step)
    else
        C.keyUp("s")
        C.keyUp("shift")
    end
end

-- ============================================================
-- 28. GOD BRIDGE (Forward Bridge, No Sneak)
-- Walk forward while placing blocks below at precise timing
-- AHK: S+D down, Click Right every ~120ms, jump every 8 blocks
-- ============================================================

function building.toggleGodBridge()
    local on = C.toggle("godBridge")
    C.alert("God Bridge", on)
    if on then
        C.keyDown("s")
        C.keyDown("d")
        local blockCount = 0
        C.startTimer("godBridge",
            function() return C.isOn("godBridge") and C.isMinecraftFocused() end,
            function()
                C.rightClick()
                blockCount = blockCount + 1
                if blockCount % 8 == 0 then
                    hs.timer.doAfter(0.03, function()
                        C.keyPress("space")
                    end)
                end
            end,
            0.12
        )
    else
        C.stopTimer("godBridge")
        C.keyUp("s")
        C.keyUp("d")
    end
end

-- ============================================================
-- 29. SCAFFOLD BRIDGE
-- Spam right-click while walking (hold movement yourself)
-- AHK: Loop { Click Right, Sleep 50 }
-- ============================================================

function building.toggleScaffold()
    local on = C.toggle("scaffold")
    C.alert("Scaffold", on)
    if on then
        C.startTimer("scaffold",
            function() return C.isOn("scaffold") and C.isMinecraftFocused() end,
            function() C.rightClick() end,
            0.05
        )
    else
        C.stopTimer("scaffold")
    end
end

-- ============================================================
-- 30. BREEZILY BRIDGE (Strafing Bridge)
-- Walk backward while alternating A/D strafe
-- AHK: Petelax breezily pt1.ahk
-- ============================================================

function building.toggleBreezilyBridge()
    local on = C.toggle("breezilyBridge")
    C.alert("Breezily Bridge", on)
    if on then
        C.keyDown("s")
        local strafeLeft = true
        local function step()
            if not C.isOn("breezilyBridge") or not C.isMinecraftFocused() then
                C.keyUp("s")
                C.keyUp("a")
                C.keyUp("d")
                return
            end
            local key = strafeLeft and "a" or "d"
            C.keyDown(key)
            hs.timer.doAfter(0.132, function()
                C.keyUp(key)
                strafeLeft = not strafeLeft
                hs.timer.doAfter(0.001, step)
            end)
        end
        step()
    else
        C.keyUp("s")
        C.keyUp("a")
        C.keyUp("d")
    end
end

-- ============================================================
-- 31. STAIRCASE BUILDER
-- Jump + place block below + move forward
-- AHK: Space, look down, Click Right, look forward, W
-- ============================================================

function building.toggleStaircase()
    local on = C.toggle("staircase")
    C.alert("Staircase", on)
    if on then
        local function step()
            if not C.isOn("staircase") or not C.isMinecraftFocused() then return end
            C.keyPress("space")
            hs.timer.doAfter(0.1, function()
                C.mouseMoveDelta(0, 500)
                hs.timer.doAfter(0.05, function()
                    C.rightClick()
                    hs.timer.doAfter(0.05, function()
                        C.mouseMoveDelta(0, -500)
                        hs.timer.doAfter(0.05, function()
                            C.keyDown("w")
                            hs.timer.doAfter(0.2, function()
                                C.keyUp("w")
                                hs.timer.doAfter(0.05, step)
                            end)
                        end)
                    end)
                end)
            end)
        end
        step()
    end
end

-- ============================================================
-- 32. WALL BUILDER
-- Place blocks in a row, move up, repeat
-- AHK: Click Right, move sideways, pillar up, repeat rows
-- ============================================================

function building.buildWall()
    C.alert("Building Wall...", true)
    local row = 0
    local function buildRow()
        if row >= cfg.wallHeight then
            C.alert("Wall Done", false)
            return
        end
        local col = 0
        local function placeBlock()
            if col >= cfg.wallWidth then
                -- Move up
                C.keyPress("space")
                hs.timer.doAfter(0.2, function()
                    C.mouseMoveDelta(0, cfg.lookDownDelta)
                    hs.timer.doAfter(0.05, function()
                        C.rightClick()
                        hs.timer.doAfter(0.05, function()
                            C.mouseMoveDelta(0, -cfg.lookDownDelta)
                            -- Move back to start
                            C.keyDown("a")
                            hs.timer.doAfter((cfg.wallWidth * 100) / 1000, function()
                                C.keyUp("a")
                                row = row + 1
                                buildRow()
                            end)
                        end)
                    end)
                end)
                return
            end
            C.rightClick()
            hs.timer.doAfter(0.1, function()
                C.keyDown("d")
                hs.timer.doAfter(0.1, function()
                    C.keyUp("d")
                    col = col + 1
                    placeBlock()
                end)
            end)
        end
        placeBlock()
    end
    buildRow()
end

-- ============================================================
-- 33. FLOOR FILLER
-- Walk in rows placing blocks below
-- AHK: Look down, W + Click Right in rows
-- ============================================================

function building.toggleFloorFill()
    local on = C.toggle("floorFill")
    C.alert("Floor Fill", on)
    if on then
        C.mouseMoveDelta(0, 800)
        C.keyDown("w")
        C.startTimer("floorFill",
            function() return C.isOn("floorFill") and C.isMinecraftFocused() end,
            function() C.rightClick() end,
            0.1
        )
    else
        C.stopTimer("floorFill")
        C.keyUp("w")
        C.mouseMoveDelta(0, -800)
    end
end

-- ============================================================
-- 34. PILLAR UP
-- Jump and place block below feet to tower up
-- AHK: Look down, Space + Click Right, repeat
-- ============================================================

function building.togglePillarUp()
    local on = C.toggle("pillarUp")
    C.alert("Pillar Up", on)
    if on then
        C.mouseMoveDelta(0, cfg.lookStraightDown)
        C.startTimer("pillarUp",
            function() return C.isOn("pillarUp") and C.isMinecraftFocused() end,
            function()
                C.keyPress("space")
                hs.timer.doAfter(cfg.pillarJumpMs / 1000, function()
                    C.rightClick()
                end)
            end,
            0.4
        )
    else
        C.stopTimer("pillarUp")
        C.mouseMoveDelta(0, -cfg.lookStraightDown)
    end
end

-- ============================================================
-- 35. PILLAR DOWN (Mine Below)
-- Mine straight down in safe pattern
-- AHK: Look down, Shift + Click Down, wait, repeat
-- ============================================================

function building.togglePillarDown()
    local on = C.toggle("pillarDown")
    C.alert("Pillar Down", on)
    if on then
        C.mouseMoveDelta(0, cfg.lookStraightDown)
        local function step()
            if not C.isOn("pillarDown") or not C.isMinecraftFocused() then
                C.mouseMoveDelta(0, -cfg.lookStraightDown)
                C.keyUp("shift")
                C.leftUp()
                return
            end
            C.keyDown("shift")
            C.leftDown()
            hs.timer.doAfter(1.5, function()
                C.leftUp()
                hs.timer.doAfter(0.5, function()
                    C.keyUp("shift")
                    step()
                end)
            end)
        end
        step()
    else
        C.leftUp()
        C.keyUp("shift")
        C.mouseMoveDelta(0, -cfg.lookStraightDown)
    end
end

-- ============================================================
-- 36. DIAGONAL BRIDGE
-- Walk S+A (or S+D) while crouching and placing
-- AHK: S+A down, Shift toggle + Click Right
-- ============================================================

function building.toggleDiagonalBridge()
    local on = C.toggle("diagBridge")
    C.alert("Diagonal Bridge", on)
    if on then
        C.keyDown("s")
        C.keyDown("a")
        C.keyDown("shift")
        local function step()
            if not C.isOn("diagBridge") or not C.isMinecraftFocused() then
                C.keyUp("s")
                C.keyUp("a")
                C.keyUp("shift")
                return
            end
            C.keyUp("shift")
            hs.timer.doAfter(0.01, function()
                C.rightClick()
                hs.timer.doAfter(0.01, function()
                    C.keyDown("shift")
                    hs.timer.doAfter(0.2, step)
                end)
            end)
        end
        hs.timer.doAfter(0.05, step)
    else
        C.keyUp("s")
        C.keyUp("a")
        C.keyUp("shift")
    end
end

-- ============================================================
-- 37. PLATFORM BUILDER (NxN)
-- Build NxN platform by placing blocks in grid
-- AHK: Look down, place + strafe in rows
-- ============================================================

function building.buildPlatform()
    C.alert("Platform " .. cfg.platformSize .. "x" .. cfg.platformSize, true)
    C.keyDown("shift")
    C.mouseMoveDelta(0, cfg.lookDownDelta)
    local row = 0
    local function buildRow()
        if row >= cfg.platformSize then
            C.keyUp("shift")
            C.mouseMoveDelta(0, -cfg.lookDownDelta)
            C.alert("Platform Done", false)
            return
        end
        local col = 0
        local function placeCol()
            if col >= cfg.platformSize then
                -- Next row
                C.keyDown("s")
                hs.timer.doAfter(0.08, function()
                    C.keyUp("s")
                    -- Return to start of row
                    C.keyDown("a")
                    hs.timer.doAfter((cfg.platformSize * 80) / 1000, function()
                        C.keyUp("a")
                        row = row + 1
                        buildRow()
                    end)
                end)
                return
            end
            C.rightClick()
            hs.timer.doAfter(0.08, function()
                C.keyDown("d")
                hs.timer.doAfter(0.08, function()
                    C.keyUp("d")
                    col = col + 1
                    placeCol()
                end)
            end)
        end
        placeCol()
    end
    buildRow()
end

-- ============================================================
-- HOTKEY BINDINGS (Ctrl+Alt+Shift prefix)
-- ============================================================

C.bind({"ctrl", "alt", "shift"}, "N", building.toggleNinjaBridge, "Ninja Bridge")
C.bind({"ctrl", "alt", "shift"}, "S", building.toggleSpeedBridge, "Speed Bridge")
C.bind({"ctrl", "alt", "shift"}, "G", building.toggleGodBridge, "God Bridge")
C.bind({"ctrl", "alt", "shift"}, "C", building.toggleScaffold, "Scaffold")
C.bind({"ctrl", "alt", "shift"}, "B", building.toggleBreezilyBridge, "Breezily")
C.bind({"ctrl", "alt", "shift"}, "T", building.toggleStaircase, "Staircase")
C.bind({"ctrl", "alt", "shift"}, "W", building.buildWall, "Wall Builder")
C.bind({"ctrl", "alt", "shift"}, "F", building.toggleFloorFill, "Floor Fill")
C.bind({"ctrl", "alt", "shift"}, "U", building.togglePillarUp, "Pillar Up")
C.bind({"ctrl", "alt", "shift"}, "D", building.togglePillarDown, "Pillar Down")
C.bind({"ctrl", "alt", "shift"}, "X", building.toggleDiagonalBridge, "Diagonal")
C.bind({"ctrl", "alt", "shift"}, "P", building.buildPlatform, "Platform")

return building
