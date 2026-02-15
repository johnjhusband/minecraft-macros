-- farming.lua
-- Mining and Farming macros for Minecraft (ported from AHK)
-- Requires mc_core.lua
--
-- INSTALL: Copy mc_core.lua and farming.lua to ~/.hammerspoon/
--   In init.lua: require("farming")

local C = require("mc_core")

local farming = {}

farming.config = {
    stoneBreakMs     = 1500,   -- Time to break stone block (ms)
    deepslateBreakMs = 5600,   -- Time to break deepslate (ms)
    walkStepMs       = 200,    -- Walk one block forward (ms)
    torchEvery       = 8,      -- Place torch every N blocks
    cropWalkMs       = 210,    -- Walk between crops
    fishReelMs       = 500,    -- AFK fishing reel interval
    cobbleRegenMs    = 2000,   -- Cobblestone regeneration wait
    boneMealDelayMs  = 100,    -- Between bonemeal applications
    xpThrowMs        = 50,     -- Between XP bottle throws
    lookDownDelta    = 600,
    lookUpDelta      = -600,
    lookBlockDelta   = 80,     -- Look down one block height
}

local cfg = farming.config

-- ============================================================
-- 49. STRIP MINE PATTERN
-- Mine 1x2 tunnel forward with torch placement
-- AHK: JangoDarkSaber strip mine script
-- ============================================================

function farming.toggleStripMine()
    local on = C.toggle("stripMine")
    C.alert("Strip Mine", on)
    if on then
        local blockCount = 0
        local function mineStep()
            if not C.isOn("stripMine") or not C.isMinecraftFocused() then
                C.leftUp()
                return
            end
            -- Mine top block
            C.leftDown()
            hs.timer.doAfter(cfg.stoneBreakMs / 1000, function()
                -- Mine bottom block
                C.mouseMoveDelta(0, cfg.lookBlockDelta)
                hs.timer.doAfter(cfg.stoneBreakMs / 1000, function()
                    C.leftUp()
                    C.mouseMoveDelta(0, -cfg.lookBlockDelta)
                    -- Walk forward
                    C.keyDown("w")
                    hs.timer.doAfter(cfg.walkStepMs / 1000, function()
                        C.keyUp("w")
                        blockCount = blockCount + 1
                        -- Place torch
                        if blockCount % cfg.torchEvery == 0 then
                            C.mouseMoveDelta(0, cfg.lookDownDelta)
                            hs.timer.doAfter(0.1, function()
                                C.rightClick()
                                hs.timer.doAfter(0.1, function()
                                    C.mouseMoveDelta(0, -cfg.lookDownDelta)
                                    mineStep()
                                end)
                            end)
                        else
                            mineStep()
                        end
                    end)
                end)
            end)
        end
        mineStep()
    else
        C.leftUp()
    end
end

-- ============================================================
-- 50. BRANCH MINE PATTERN
-- Main tunnel + side branches at intervals
-- AHK: Mine forward, turn 90, mine branch, return
-- ============================================================

function farming.toggleBranchMine()
    local on = C.toggle("branchMine")
    C.alert("Branch Mine", on)
    -- Note: This is complex positional macro. Toggle starts/stops.
    -- Uses strip mine in current facing direction.
    -- Recommended to combine with manual turns.
    if on then
        C.startTimer("branchMine",
            function() return C.isOn("branchMine") and C.isMinecraftFocused() end,
            function()
                C.leftDown()
                hs.timer.doAfter(cfg.stoneBreakMs / 1000, function()
                    C.mouseMoveDelta(0, cfg.lookBlockDelta)
                    hs.timer.doAfter(cfg.stoneBreakMs / 1000, function()
                        C.leftUp()
                        C.mouseMoveDelta(0, -cfg.lookBlockDelta)
                        C.keyDown("w")
                        hs.timer.doAfter(cfg.walkStepMs / 1000, function()
                            C.keyUp("w")
                        end)
                    end)
                end)
            end,
            (cfg.stoneBreakMs * 2 + cfg.walkStepMs + 100) / 1000
        )
    else
        C.stopTimer("branchMine")
        C.leftUp()
        C.keyUp("w")
    end
end

-- ============================================================
-- 51. AUTO-DIG DOWN (Staircase Mine)
-- Mine forward+down in safe staircase pattern
-- AHK: Mine eye level, feet level, below, walk forward
-- ============================================================

function farming.toggleStaircaseMine()
    local on = C.toggle("staircaseMine")
    C.alert("Staircase Mine", on)
    if on then
        local function step()
            if not C.isOn("staircaseMine") or not C.isMinecraftFocused() then
                C.leftUp()
                return
            end
            -- Mine eye level
            C.leftDown()
            hs.timer.doAfter(cfg.stoneBreakMs / 1000, function()
                C.leftUp()
                -- Mine feet level
                C.mouseMoveDelta(0, 400)
                C.leftDown()
                hs.timer.doAfter(cfg.stoneBreakMs / 1000, function()
                    C.leftUp()
                    -- Mine below feet
                    C.mouseMoveDelta(0, 400)
                    C.leftDown()
                    hs.timer.doAfter(cfg.stoneBreakMs / 1000, function()
                        C.leftUp()
                        C.mouseMoveDelta(0, -800)
                        -- Walk forward into hole
                        C.keyDown("w")
                        hs.timer.doAfter(0.3, function()
                            C.keyUp("w")
                            step()
                        end)
                    end)
                end)
            end)
        end
        step()
    else
        C.leftUp()
    end
end

-- ============================================================
-- 52. AFK FISH FARM
-- Simple: click every 500ms to reel and recast
-- AHK: DavidPx simple fishing
-- ============================================================

function farming.toggleAFKFish()
    local on = C.toggle("afkFish")
    C.alert("AFK Fish", on)
    if on then
        C.startTimer("afkFish",
            function() return C.isOn("afkFish") and C.isMinecraftFocused() end,
            function() C.rightClick() end,
            cfg.fishReelMs / 1000
        )
    else
        C.stopTimer("afkFish")
    end
end

-- ============================================================
-- 53. AFK CROP FARM (Break + Replant)
-- Walk forward, break crop, replant, advance
-- AHK: Petelax farming 1 line
-- ============================================================

function farming.toggleCropFarm()
    local on = C.toggle("cropFarm")
    C.alert("Crop Farm", on)
    if on then
        local function step()
            if not C.isOn("cropFarm") or not C.isMinecraftFocused() then
                C.keyUp("w")
                return
            end
            C.leftClick()              -- break crop
            hs.timer.doAfter(0.05, function()
                C.rightClick()         -- replant
                hs.timer.doAfter(0.05, function()
                    C.keyDown("w")
                    hs.timer.doAfter(cfg.cropWalkMs / 1000, function()
                        C.keyUp("w")
                        hs.timer.doAfter(0.2, step)
                    end)
                end)
            end)
        end
        step()
    else
        C.keyUp("w")
    end
end

-- ============================================================
-- 54. TREE FARM (Chop + Replant)
-- Look up, chop trunk, look down, replant sapling
-- AHK: Look up, hold click, look down, place sapling, walk
-- ============================================================

function farming.toggleTreeFarm()
    local on = C.toggle("treeFarm")
    C.alert("Tree Farm", on)
    if on then
        local function step()
            if not C.isOn("treeFarm") or not C.isMinecraftFocused() then return end
            -- Look up at trunk
            C.mouseMoveDelta(0, -600)
            hs.timer.doAfter(0.05, function()
                C.leftDown()
                hs.timer.doAfter(5.0, function()
                    C.leftUp()
                    -- Look down at ground
                    C.mouseMoveDelta(0, 1200)
                    hs.timer.doAfter(0.5, function()
                        -- Replant
                        C.keyPress("2")
                        hs.timer.doAfter(0.05, function()
                            C.rightClick()
                            hs.timer.doAfter(0.05, function()
                                C.keyPress("1")
                                C.mouseMoveDelta(0, -600)
                                -- Walk to next tree
                                C.keyDown("w")
                                hs.timer.doAfter(0.5, function()
                                    C.keyUp("w")
                                    hs.timer.doAfter(2.0, step)
                                end)
                            end)
                        end)
                    end)
                end)
            end)
        end
        step()
    else
        C.leftUp()
        C.keyUp("w")
    end
end

-- ============================================================
-- 55. MOB FARM AFK ATTACK
-- Sweep attack at cooldown interval with right-click held
-- AHK: XAHK - ControlClick Left every 1.2s, Right held
-- ============================================================

function farming.toggleMobFarm()
    local on = C.toggle("mobFarm")
    C.alert("Mob Farm", on)
    if on then
        C.rightDown()  -- hold right click to collect items
        C.startTimer("mobFarm",
            function() return C.isOn("mobFarm") and C.isMinecraftFocused() end,
            function() C.leftClick() end,
            1.2  -- sword cooldown
        )
    else
        C.stopTimer("mobFarm")
        C.rightUp()
    end
end

-- ============================================================
-- 56. SUGAR CANE FARM
-- Walk along and break middle blocks
-- AHK: W down, Click loop
-- ============================================================

function farming.toggleSugarCaneFarm()
    local on = C.toggle("sugarCane")
    C.alert("Sugar Cane Farm", on)
    if on then
        C.keyDown("w")
        C.startTimer("sugarCane",
            function() return C.isOn("sugarCane") and C.isMinecraftFocused() end,
            function() C.leftClick() end,
            0.1
        )
    else
        C.stopTimer("sugarCane")
        C.keyUp("w")
    end
end

-- ============================================================
-- 57. XP BOTTLE SPAM
-- Look down + rapid right-click to throw XP bottles
-- AHK: Look down, Click Right spam at 50ms
-- ============================================================

function farming.toggleXPSpam()
    local on = C.toggle("xpSpam")
    C.alert("XP Spam", on)
    if on then
        C.mouseMoveDelta(0, 800)
        C.startTimer("xpSpam",
            function() return C.isOn("xpSpam") and C.isMinecraftFocused() end,
            function() C.rightClick() end,
            cfg.xpThrowMs / 1000
        )
    else
        C.stopTimer("xpSpam")
        C.mouseMoveDelta(0, -800)
    end
end

-- ============================================================
-- 58. ENCHANT CLICK PATTERN
-- Open enchant table, select level 3 enchant
-- Note: Coordinate-based. Adjust for your resolution.
-- ============================================================

function farming.enchant()
    C.alert("Enchanting...", true)
    C.runSequence({
        {function() C.rightClick() end, 300},              -- open table
        {function() hs.mouse.absolutePosition({x=350, y=350}); C.leftClick() end, 100},  -- lapis
        {function() hs.mouse.absolutePosition({x=450, y=300}); C.leftClick() end, 200},  -- level 3
        {function() C.keyPress("e") end, 0},               -- close
    })
end

-- ============================================================
-- 59. VILLAGER TRADING
-- Rapidly click trade slots
-- AHK: Mouse move delta, click, move back, click loop
-- ============================================================

function farming.toggleVillagerTrade()
    local on = C.toggle("villagerTrade")
    C.alert("Villager Trade", on)
    if on then
        C.startTimer("villagerTrade",
            function() return C.isOn("villagerTrade") and C.isMinecraftFocused() end,
            function()
                C.mouseMoveDelta(100, 0)
                hs.timer.doAfter(0.03, function()
                    C.leftClick()
                    hs.timer.doAfter(0.03, function()
                        C.mouseMoveDelta(-100, 0)
                        hs.timer.doAfter(0.03, function()
                            C.leftClick()
                        end)
                    end)
                end)
            end,
            0.12
        )
    else
        C.stopTimer("villagerTrade")
    end
end

-- ============================================================
-- 60. ANVIL REPAIR SEQUENCE
-- Shift-click item and material into anvil
-- Note: Coordinate-based. Adjust for your resolution.
-- ============================================================

function farming.anvilRepair()
    C.alert("Anvil Repair", true)
    C.runSequence({
        {function() C.rightClick() end, 300},                           -- open anvil
        {function() C.keyDown("shift"); C.keyPress("1"); C.keyUp("shift") end, 100},  -- item
        {function() C.keyDown("shift"); C.keyPress("2"); C.keyUp("shift") end, 100},  -- material
        {function() hs.mouse.absolutePosition({x=500, y=300}); C.leftClick() end, 100},  -- result
        {function() C.keyPress("e") end, 0},                           -- close
    })
end

-- ============================================================
-- 61. FURNACE LOADING
-- Shift-click items and fuel into furnace
-- ============================================================

function farming.furnaceLoad()
    C.alert("Loading Furnace", true)
    C.runSequence({
        {function() C.rightClick() end, 300},
        {function() C.keyDown("shift"); C.keyPress("1"); C.keyUp("shift") end, 50},
        {function() C.keyDown("shift"); C.keyPress("2"); C.keyUp("shift") end, 50},
        {function() C.keyDown("shift"); C.keyPress("3"); C.keyUp("shift") end, 100},
        {function() C.keyPress("e") end, 0},
    })
end

-- ============================================================
-- 62. CHEST SORT / QUICK MOVE ALL
-- Shift-click all inventory slots to move items to chest
-- AHK: Loop 36 slots, Shift+Click each
-- ============================================================

function farming.toggleQuickMoveAll()
    local on = C.toggle("quickMoveAll")
    C.alert("Quick Move", on)
    if on then
        -- Spam shift-click on all hotbar slots (1-9)
        local slot = 1
        local function moveNext()
            if slot > 9 or not C.isOn("quickMoveAll") then
                C.setOff("quickMoveAll")
                return
            end
            C.keyDown("shift")
            C.keyPress(tostring(slot))
            C.keyUp("shift")
            slot = slot + 1
            hs.timer.doAfter(0.05, moveNext)
        end
        moveNext()
    end
end

-- ============================================================
-- 63. COBBLESTONE GENERATOR
-- Mine, wait for regen, repeat
-- AHK: Scripter17 cobble gen
-- ============================================================

function farming.toggleCobbleGen()
    local on = C.toggle("cobbleGen")
    C.alert("Cobble Gen", on)
    if on then
        local function step()
            if not C.isOn("cobbleGen") or not C.isMinecraftFocused() then
                C.leftUp()
                return
            end
            C.leftDown()
            hs.timer.doAfter(1.0, function()
                C.leftUp()
                hs.timer.doAfter(cfg.cobbleRegenMs / 1000, step)
            end)
        end
        step()
    else
        C.leftUp()
    end
end

-- ============================================================
-- 64. CONCRETE MAKER
-- Hold both right-click (place powder) and left-click (break)
-- AHK: XAHK - hold both mouse buttons
-- ============================================================

function farming.toggleConcreteMaker()
    local on = C.toggle("concreteMaker")
    C.alert("Concrete Maker", on)
    if on then
        C.startTimer("concreteMaker",
            function() return C.isOn("concreteMaker") and C.isMinecraftFocused() end,
            function()
                C.rightClick()
                hs.timer.doAfter(0.05, function()
                    C.leftClick()
                end)
            end,
            0.15
        )
    else
        C.stopTimer("concreteMaker")
    end
end

-- ============================================================
-- 65. BONEMEAL AUTO-FARM
-- Apply bonemeal, harvest, replant
-- AHK: Slot 2 bonemeal, right-click, slot 1, left-click, slot 3, right-click
-- ============================================================

function farming.toggleBoneMealFarm()
    local on = C.toggle("boneMealFarm")
    C.alert("Bonemeal Farm", on)
    if on then
        local function step()
            if not C.isOn("boneMealFarm") or not C.isMinecraftFocused() then return end
            C.keyPress("2")  -- bonemeal
            hs.timer.doAfter(0.05, function()
                C.rightClick()
                hs.timer.doAfter(cfg.boneMealDelayMs / 1000, function()
                    C.rightClick()
                    hs.timer.doAfter(cfg.boneMealDelayMs / 1000, function()
                        C.keyPress("1")  -- tool
                        hs.timer.doAfter(0.05, function()
                            C.leftClick()
                            hs.timer.doAfter(cfg.boneMealDelayMs / 1000, function()
                                C.keyPress("3")  -- seeds
                                hs.timer.doAfter(0.05, function()
                                    C.rightClick()
                                    hs.timer.doAfter(cfg.boneMealDelayMs / 1000, step)
                                end)
                            end)
                        end)
                    end)
                end)
            end)
        end
        step()
    else end
end

-- ============================================================
-- 66. AUTO MINE FORWARD
-- Hold left-click + W to mine tunnel
-- AHK: pzaerial mineForwardRiskily
-- ============================================================

function farming.toggleMineForward()
    local on = C.toggle("mineForward")
    C.alert("Mine Forward", on)
    if on then
        C.leftDown()
        C.keyDown("w")
    else
        C.leftUp()
        C.keyUp("w")
    end
end

-- ============================================================
-- HOTKEY BINDINGS (Ctrl+Alt prefix, function keys)
-- ============================================================

C.bind({"ctrl", "alt"}, "F1", farming.toggleStripMine, "Strip Mine")
C.bind({"ctrl", "alt"}, "F2", farming.toggleBranchMine, "Branch Mine")
C.bind({"ctrl", "alt"}, "F3", farming.toggleStaircaseMine, "Staircase Mine")
C.bind({"ctrl", "alt"}, "F4", farming.toggleAFKFish, "AFK Fish")
C.bind({"ctrl", "alt"}, "F5", farming.toggleCropFarm, "Crop Farm")
C.bind({"ctrl", "alt"}, "F6", farming.toggleTreeFarm, "Tree Farm")
C.bind({"ctrl", "alt"}, "F7", farming.toggleMobFarm, "Mob Farm")
C.bind({"ctrl", "alt"}, "F8", farming.toggleSugarCaneFarm, "Sugar Cane")
C.bind({"ctrl", "alt"}, "F9", farming.toggleXPSpam, "XP Spam")
C.bind({"ctrl", "alt"}, "F10", farming.enchant, "Enchant")
C.bind({"ctrl", "alt"}, "F11", farming.toggleVillagerTrade, "Villager Trade")
C.bind({"ctrl", "alt"}, "F12", farming.toggleCobbleGen, "Cobble Gen")
C.bind({"ctrl", "alt"}, "1", farming.toggleConcreteMaker, "Concrete")
C.bind({"ctrl", "alt"}, "2", farming.toggleBoneMealFarm, "Bonemeal Farm")
C.bind({"ctrl", "alt"}, "3", farming.toggleMineForward, "Mine Forward")
C.bind({"ctrl", "alt"}, "4", farming.anvilRepair, "Anvil Repair")
C.bind({"ctrl", "alt"}, "5", farming.furnaceLoad, "Furnace Load")
C.bind({"ctrl", "alt"}, "6", farming.toggleQuickMoveAll, "Quick Move")

return farming
