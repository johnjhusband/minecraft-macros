-- bedwars.lua
-- Bedwars / Skywars specific macros for Minecraft (ported from AHK)
-- Requires mc_core.lua
--
-- INSTALL: Copy mc_core.lua and bedwars.lua to ~/.hammerspoon/
--   In init.lua: require("bedwars")

local C = require("mc_core")

local bedwars = {}

bedwars.config = {
    tntSlot     = "4",
    pickSlot    = "1",
    woolSlot    = "2",
    swordSlot   = "1",
    blocksSlot  = "2",
    potSlot     = "3",
    fireballSlot = "4",
}

local cfg = bedwars.config

-- ============================================================
-- 97. BED BREAK COMBO (TNT + Rush)
-- Place TNT, swap to pickaxe, mine bed defense
-- AHK: Send {4}, Click Right, Send {1}, Click Down 4s
-- ============================================================

function bedwars.bedBreak()
    C.alert("Bed Break!", true)
    C.runSequence({
        {function() C.keyPress(cfg.tntSlot) end, 50},
        {function() C.rightClick() end, 50},
        {function() C.keyPress(cfg.pickSlot) end, 50},
        {function() C.leftDown() end, 4000},       -- mine while TNT fuse
        {function() end, 2000},                     -- continue mining after explosion
        {function() C.leftUp() end, 0},
    })
end

-- ============================================================
-- 98. WOOL BRIDGE + FIGHT SWAP
-- Bridge backward with wool, quick swap to sword on demand
-- AHK: S+Shift down, unshift-click-reshift loop
-- ============================================================

function bedwars.toggleWoolBridge()
    local on = C.toggle("woolBridge")
    C.alert("Wool Bridge", on)
    if on then
        C.keyPress(cfg.woolSlot)
        C.keyDown("s")
        C.keyDown("shift")
        local function step()
            if not C.isOn("woolBridge") or not C.isMinecraftFocused() then
                C.keyUp("s")
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
        C.keyUp("shift")
    end
end

function bedwars.bridgeToFight()
    -- Emergency swap from bridge to fight mode
    C.setOff("woolBridge")
    C.keyUp("s")
    C.keyUp("shift")
    C.keyPress(cfg.swordSlot)
    C.alert("FIGHT!", true)
end

-- ============================================================
-- 99. SHOP BUY SEQUENCE
-- Open shop NPC, click through purchase
-- Note: Coordinate-based, adjust for your resolution/shop layout
-- ============================================================

function bedwars.shopBuySword()
    C.alert("Buying Sword", true)
    C.runSequence({
        {function() C.rightClick() end, 300},                          -- open shop
        {function() hs.mouse.absolutePosition({x=500, y=250}); C.leftClick() end, 100},  -- weapons
        {function() hs.mouse.absolutePosition({x=400, y=350}); C.leftClick() end, 100},  -- sword
        {function() C.keyPress("e") end, 0},                          -- close
    })
end

function bedwars.shopBuyWool()
    C.alert("Buying Wool", true)
    C.runSequence({
        {function() C.rightClick() end, 300},
        {function() hs.mouse.absolutePosition({x=300, y=250}); C.leftClick() end, 100},  -- blocks
        {function() hs.mouse.absolutePosition({x=300, y=350}); C.leftClick() end, 100},  -- wool
        {function() C.keyPress("e") end, 0},
    })
end

-- ============================================================
-- 100. UPGRADE BUY SEQUENCE
-- Navigate team upgrade menu
-- Note: Coordinate-based
-- ============================================================

function bedwars.buyUpgrade()
    C.alert("Buying Upgrade", true)
    C.runSequence({
        {function() C.rightClick() end, 300},
        {function() hs.mouse.absolutePosition({x=400, y=300}); C.leftClick() end, 200},
        {function() C.keyPress("e") end, 0},
    })
end

-- ============================================================
-- 101. SPEED POT + BRIDGE COMBO
-- Drink speed potion then start bridging
-- AHK: Send {3}, RButton hold 1s, Send {2}, start bridge
-- ============================================================

function bedwars.speedBridge()
    C.alert("Speed Bridge!", true)
    C.runSequence({
        {function() C.keyPress(cfg.potSlot) end, 50},
        {function() C.rightDown() end, 1000},              -- drink speed pot
        {function() C.rightUp() end, 50},
        {function() C.keyPress(cfg.blocksSlot) end, 50},
        {function()
            -- Start bridging
            C.keyDown("s")
            C.keyDown("shift")
        end, 0},
    })
    -- Auto-bridge loop
    hs.timer.doAfter(1.2, function()
        C.toggle("speedBridgeLoop")
        local function step()
            if not C.isOn("speedBridgeLoop") or not C.isMinecraftFocused() then
                C.keyUp("s")
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
        step()
    end)
end

-- ============================================================
-- 102. FIREBALL + BRIDGE COMBO
-- Throw fireball then resume bridging
-- AHK: Pause bridge, throw fireball, resume
-- ============================================================

function bedwars.fireballBridge()
    C.alert("Fireball!", true)
    -- Pause walking but stay crouched
    C.keyUp("s")
    C.runSequence({
        {function() C.keyPress(cfg.fireballSlot) end, 50},
        {function() C.rightClick() end, 100},
        {function() C.keyPress(cfg.blocksSlot) end, 50},
        {function() C.keyDown("s") end, 0},                -- resume walking
    })
end

-- ============================================================
-- HOTKEY BINDINGS
-- ============================================================

C.bind({"ctrl", "alt"}, "F13", bedwars.bedBreak, "Bed Break")
C.bind({"ctrl", "alt"}, "F14", bedwars.toggleWoolBridge, "Wool Bridge")
C.bind({"ctrl", "alt"}, "F15", bedwars.bridgeToFight, "Bridge->Fight")
C.bind({"ctrl", "alt"}, "F16", bedwars.shopBuySword, "Buy Sword")
C.bind({"ctrl", "alt"}, "F17", bedwars.shopBuyWool, "Buy Wool")
C.bind({"ctrl", "alt"}, "F18", bedwars.buyUpgrade, "Buy Upgrade")
C.bind({"ctrl", "alt"}, "F19", bedwars.speedBridge, "Speed+Bridge")
C.bind({"ctrl", "alt"}, "F20", bedwars.fireballBridge, "Fireball+Bridge")

return bedwars
