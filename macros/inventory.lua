-- inventory.lua
-- Inventory Management macros for Minecraft (ported from AHK)
-- Requires mc_core.lua
--
-- INSTALL: Copy mc_core.lua and inventory.lua to ~/.hammerspoon/
--   In init.lua: require("inventory")

local C = require("mc_core")

local inventory = {}

inventory.config = {
    swordSlot  = "1",
    pickSlot   = "2",
    shovelSlot = "3",
    axeSlot    = "4",
    shieldSlot = "5",
}

local cfg = inventory.config
local toolSlots = {cfg.pickSlot, cfg.shovelSlot, cfg.axeSlot}
local toolIndex = 1
local currentSlot = 1

-- ============================================================
-- 67. QUICK SLOT SWAP (1-9 Cycling)
-- Cycle through hotbar slots with a single key
-- AHK: currentSlot++, Send {slot}
-- ============================================================

function inventory.hotbarNext()
    currentSlot = (currentSlot % 9) + 1
    C.keyPress(tostring(currentSlot))
    C.alert("Slot " .. currentSlot, true)
end

function inventory.hotbarPrev()
    currentSlot = currentSlot - 1
    if currentSlot < 1 then currentSlot = 9 end
    C.keyPress(tostring(currentSlot))
    C.alert("Slot " .. currentSlot, true)
end

-- ============================================================
-- 68. DROP ALL ITEMS
-- Rapidly drop all stacks with Ctrl+Q
-- AHK: pzaerial autoThrowOut - Ctrl+Q spam
-- ============================================================

function inventory.toggleDropAll()
    local on = C.toggle("dropAll")
    C.alert("Drop All", on)
    if on then
        C.startTimer("dropAll",
            function() return C.isOn("dropAll") and C.isMinecraftFocused() end,
            function()
                C.keyPress("q", {"ctrl"})
            end,
            0.05
        )
    else
        C.stopTimer("dropAll")
    end
end

-- ============================================================
-- 69. HOTBAR PRESET SWAP
-- Open inventory and assign items to specific hotbar slots
-- AHK: Open inventory, hover item, press number key
-- Note: Coordinate-based, adjust for your resolution
-- ============================================================

function inventory.hotbarPreset()
    C.alert("Hotbar Preset", true)
    C.runSequence({
        {function() C.keyPress("e") end, 200},                         -- open inventory
        {function()
            hs.mouse.absolutePosition({x=300, y=300})
            C.keyPress("1")     -- sword to slot 1
        end, 50},
        {function()
            hs.mouse.absolutePosition({x=336, y=300})
            C.keyPress("2")     -- pick to slot 2
        end, 50},
        {function()
            hs.mouse.absolutePosition({x=372, y=300})
            C.keyPress("9")     -- food to slot 9
        end, 50},
        {function() C.keyPress("e") end, 0},                           -- close
    })
end

-- ============================================================
-- 70. OFFHAND SWAP TOGGLE
-- Swap current held item with offhand using F key
-- AHK: Send {f}
-- ============================================================

function inventory.offhandSwap()
    C.keyPress("f")
    C.alert("Offhand Swap", true)
end

function inventory.offhandCycle()
    -- Send current to offhand, switch slot, swap back
    C.runSequence({
        {function() C.keyPress("f") end, 30},
        {function() C.keyPress(cfg.swordSlot) end, 30},
        {function() C.keyPress("f") end, 0},
    })
end

-- ============================================================
-- 71. QUICK ARMOR EQUIP
-- Open inventory, shift-click armor pieces
-- AHK: Open inventory, shift-click each armor position
-- Note: Coordinate-based, adjust for your resolution
-- ============================================================

function inventory.quickArmor()
    C.alert("Equipping Armor", true)
    C.keyPress("e")
    local positions = {{300, 350}, {336, 350}, {372, 350}, {408, 350}}
    local idx = 1
    local function equipNext()
        if idx > #positions then
            C.keyPress("e")
            return
        end
        hs.timer.doAfter(0.1, function()
            hs.mouse.absolutePosition({x=positions[idx][1], y=positions[idx][2]})
            hs.timer.doAfter(0.03, function()
                C.keyDown("shift")
                C.leftClick()
                C.keyUp("shift")
                idx = idx + 1
                equipNext()
            end)
        end)
    end
    hs.timer.doAfter(0.2, equipNext)
end

-- ============================================================
-- 72. SHIELD SWAP
-- Quick swap shield to offhand from hotbar slot
-- AHK: Send {5}, Send {f}, Send {1}
-- ============================================================

function inventory.shieldSwap()
    C.alert("Shield Swap", true)
    C.runSequence({
        {function() C.keyPress(cfg.shieldSlot) end, 30},
        {function() C.keyPress("f") end, 30},
        {function() C.keyPress(cfg.swordSlot) end, 0},
    })
end

-- ============================================================
-- 73. TOOL SWAP (Pick/Shovel/Axe Cycle)
-- Cycle through tool hotbar slots
-- AHK: tools[toolIndex++], Send {slot}
-- ============================================================

function inventory.toolCycle()
    toolIndex = (toolIndex % #toolSlots) + 1
    local slot = toolSlots[toolIndex]
    C.keyPress(slot)
    local names = {"Pick", "Shovel", "Axe"}
    C.alert(names[toolIndex], true)
end

-- ============================================================
-- HOTKEY BINDINGS
-- ============================================================

C.bind({"ctrl", "alt", "shift"}, "]", inventory.hotbarNext, "Hotbar Next")
C.bind({"ctrl", "alt", "shift"}, "[", inventory.hotbarPrev, "Hotbar Prev")
C.bind({"ctrl", "alt", "shift"}, "Q", inventory.toggleDropAll, "Drop All")
C.bind({"ctrl", "alt", "shift"}, "H", inventory.hotbarPreset, "Hotbar Preset")
C.bind({"ctrl", "alt", "shift"}, "O", inventory.offhandSwap, "Offhand Swap")
C.bind({"ctrl", "alt", "shift"}, "A", inventory.quickArmor, "Quick Armor")
C.bind({"ctrl", "alt", "shift"}, "I", inventory.shieldSwap, "Shield Swap")
C.bind({"ctrl", "alt", "shift"}, "L", inventory.toolCycle, "Tool Cycle")

return inventory
