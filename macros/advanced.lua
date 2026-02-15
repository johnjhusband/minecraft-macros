-- advanced.lua
-- Advanced macros for Minecraft (ported from AHK)
-- Requires mc_core.lua
--
-- INSTALL: Copy mc_core.lua and advanced.lua to ~/.hammerspoon/
--   In init.lua: require("advanced")

local C = require("mc_core")

local advanced = {}

-- ============================================================
-- 103. AFK MINING (Lock Click + Walk)
-- Hold left-click and walk forward for tunnel mining
-- AHK: pzaerial mineForwardRiskily
-- ============================================================

function advanced.toggleAFKMine()
    local on = C.toggle("afkMine")
    C.alert("AFK Mine", on)
    if on then
        C.leftDown()
        C.keyDown("w")
    else
        C.leftUp()
        C.keyUp("w")
    end
end

-- ============================================================
-- 104. LONG MOUSE CLICK
-- Hold LMB indefinitely until toggled off
-- AHK: pzaerial arbitrarilyLongMouseClicks
-- ============================================================

function advanced.toggleLongClick()
    local on = C.toggle("longClick")
    C.alert("Long Click", on)
    if on then
        C.leftDown()
    else
        C.leftUp()
    end
end

-- ============================================================
-- 105. SHIFT-TAP PVP (S-Tap)
-- Attack + brief shift tap for sprint reset
-- AHK: Vitrecan shiftClick
-- ============================================================

function advanced.shiftTap()
    C.leftClick()
    C.keyDown("shift")
    hs.timer.doAfter(0.02, function()
        C.keyUp("shift")
    end)
end

-- ============================================================
-- 106. S-TAP PVP
-- Attack + brief S tap for sprint reset
-- AHK: Vitrecan sClick
-- ============================================================

function advanced.sTap()
    C.leftClick()
    C.keyDown("s")
    hs.timer.doAfter(0.02, function()
        C.keyUp("s")
    end)
end

-- ============================================================
-- 107. CREATIVE FAST CLICKER
-- Hold for rapid right/left click
-- AHK: ItsMeBrille - XButton rapid click while held
-- ============================================================

function advanced.toggleFastRightClick()
    local on = C.toggle("fastRight")
    C.alert("Fast R-Click", on)
    if on then
        C.startTimer("fastRight",
            function() return C.isOn("fastRight") and C.isMinecraftFocused() end,
            function() C.rightClick() end,
            0.05
        )
    else
        C.stopTimer("fastRight")
    end
end

function advanced.toggleFastLeftClick()
    local on = C.toggle("fastLeft")
    C.alert("Fast L-Click", on)
    if on then
        C.startTimer("fastLeft",
            function() return C.isOn("fastLeft") and C.isMinecraftFocused() end,
            function() C.leftClick() end,
            0.125
        )
    else
        C.stopTimer("fastLeft")
    end
end

-- ============================================================
-- 108. RIGHT CLICK SPAM
-- Rapid right-click toggle
-- AHK: ybhaw right click spam
-- ============================================================

function advanced.toggleRightClickSpam()
    local on = C.toggle("rightSpam")
    C.alert("R-Click Spam", on)
    if on then
        C.startTimer("rightSpam",
            function() return C.isOn("rightSpam") and C.isMinecraftFocused() end,
            function() C.rightClick() end,
            0.005
        )
    else
        C.stopTimer("rightSpam")
    end
end

-- ============================================================
-- 109. TIMED SWORD (Background)
-- Attack at sword cooldown intervals
-- AHK: ztancrell ControlClick timed attack
-- ============================================================

function advanced.toggleTimedSword()
    local on = C.toggle("timedSword")
    C.alert("Timed Sword", on)
    if on then
        C.startTimer("timedSword",
            function() return C.isOn("timedSword") end,  -- works even unfocused
            function() C.leftClick() end,
            1.625  -- full sword cooldown cycle
        )
    else
        C.stopTimer("timedSword")
    end
end

-- ============================================================
-- 110. AUTO THROW OUT
-- Rapidly drop all stacks
-- AHK: pzaerial autoThrowOut Ctrl+Q spam
-- ============================================================

function advanced.toggleAutoThrow()
    local on = C.toggle("autoThrow")
    C.alert("Auto Throw", on)
    if on then
        C.startTimer("autoThrow",
            function() return C.isOn("autoThrow") and C.isMinecraftFocused() end,
            function() C.keyPress("q", {"ctrl"}) end,
            0.01
        )
    else
        C.stopTimer("autoThrow")
    end
end

-- ============================================================
-- 111. SIDE-TO-SIDE MOVEMENT
-- Move back and forth for mob spawning / cobble gen
-- AHK: A down, sleep, A up, D down, sleep, D up, repeat
-- ============================================================

function advanced.toggleSideToSide()
    local on = C.toggle("sideToSide")
    C.alert("Side-to-Side", on)
    if on then
        local goLeft = true
        local function step()
            if not C.isOn("sideToSide") or not C.isMinecraftFocused() then
                C.keyUp("a")
                C.keyUp("d")
                return
            end
            local key = goLeft and "a" or "d"
            C.keyDown(key)
            hs.timer.doAfter(0.5, function()
                C.keyUp(key)
                goLeft = not goLeft
                hs.timer.doAfter(0.05, step)
            end)
        end
        step()
    else
        C.keyUp("a")
        C.keyUp("d")
    end
end

-- ============================================================
-- 112. AUTO CHAT AFK
-- Send periodic chat message to avoid AFK kick
-- AHK: Send {t}, SendInput ".", Enter, Sleep 300000
-- ============================================================

function advanced.toggleChatAFK()
    local on = C.toggle("chatAFK")
    C.alert("Chat AFK", on)
    if on then
        C.startTimer("chatAFK",
            function() return C.isOn("chatAFK") end,
            function()
                if C.isMinecraftFocused() then
                    C.chat(".")
                end
            end,
            300  -- every 5 minutes
        )
    else
        C.stopTimer("chatAFK")
    end
end

-- ============================================================
-- 113. PIGLIN TRADING
-- Throw gold, wait, rotate to next piglin
-- AHK: Send {q}, Sleep 6000, mouse_event rotate
-- ============================================================

function advanced.togglePiglinTrade()
    local on = C.toggle("piglinTrade")
    C.alert("Piglin Trade", on)
    if on then
        local function step()
            if not C.isOn("piglinTrade") or not C.isMinecraftFocused() then return end
            C.keyPress("q")
            hs.timer.doAfter(0.1, function()
                C.keyPress("q")
                hs.timer.doAfter(6.0, function()
                    C.mouseMoveDelta(500, 0)  -- rotate to next piglin
                    hs.timer.doAfter(0.1, step)
                end)
            end)
        end
        step()
    end
end

-- ============================================================
-- 114. HEAD-HITTER JUMP (Parkour)
-- W + timed space for parkour sections
-- AHK: W down, Sleep delay, Space, W up
-- ============================================================

function advanced.headHitJump()
    C.keyDown("w")
    hs.timer.doAfter(0.15, function()
        C.keyPress("space")
        hs.timer.doAfter(0.2, function()
            C.keyUp("w")
        end)
    end)
end

-- ============================================================
-- 115. 45-DEGREE STRAFE JUMP
-- Sprint jump at 45-degree angle for max distance
-- AHK: Ctrl+W+A, Space, release
-- ============================================================

function advanced.strafeJump()
    C.keyDown("ctrl")
    C.keyDown("w")
    C.keyDown("a")
    hs.timer.doAfter(0.05, function()
        C.keyPress("space")
        hs.timer.doAfter(0.4, function()
            C.keyUp("w")
            C.keyUp("a")
            C.keyUp("ctrl")
        end)
    end)
end

-- ============================================================
-- 116. SOUP HEAL (Soup PvP Servers)
-- Right-click soup, drop empty bowl, next soup
-- AHK: Click Right, Send {q}, scroll
-- ============================================================

function advanced.soupHeal()
    C.rightClick()
    hs.timer.doAfter(0.03, function()
        C.keyPress("q")
    end)
end

-- ============================================================
-- 117. RAPID RIGHT-CLICK HOLD (Persistent)
-- Re-press right-click periodically to keep it held
-- AHK: RButton down, Sleep 1000, RButton up, Sleep 10, repeat
-- ============================================================

function advanced.togglePersistentRightClick()
    local on = C.toggle("persistRight")
    C.alert("Persist R-Click", on)
    if on then
        local function step()
            if not C.isOn("persistRight") or not C.isMinecraftFocused() then
                C.rightUp()
                return
            end
            C.rightDown()
            hs.timer.doAfter(1.0, function()
                C.rightUp()
                hs.timer.doAfter(0.01, step)
            end)
        end
        step()
    else
        C.rightUp()
    end
end

-- ============================================================
-- 118. TRIPLE-CLICK MACRO
-- Each click sends 3 clicks
-- AHK: ~LButton:: Send {LButton} x2
-- Note: Implemented as fast triple-click toggle
-- ============================================================

function advanced.toggleTripleClick()
    local on = C.toggle("tripleClick")
    C.alert("Triple Click", on)
    if on then
        C.startTimer("tripleClick",
            function() return C.isOn("tripleClick") and C.isMinecraftFocused() end,
            function()
                C.leftClick()
                hs.timer.doAfter(0.02, function()
                    C.leftClick()
                    hs.timer.doAfter(0.02, function()
                        C.leftClick()
                    end)
                end)
            end,
            0.15
        )
    else
        C.stopTimer("tripleClick")
    end
end

-- ============================================================
-- 119. WORLDEDIT COMMAND ALIASES
-- Quick commands for WorldEdit operations
-- AHK: Send {t}, SendInput //command, Enter
-- ============================================================

function advanced.weSet()     C.chat("//set stone") end
function advanced.weReplace() C.chat("//replace grass_block stone") end
function advanced.weCopy()    C.chat("//copy") end
function advanced.wePaste()   C.chat("//paste") end
function advanced.weUndo()    C.chat("//undo") end

-- ============================================================
-- 120. GIVE ITEM (OP/Admin)
-- Give item via chat command
-- AHK: justinribeiro give item GUI
-- ============================================================

function advanced.giveItem(item, count, player)
    item = item or "diamond"
    count = count or 64
    player = player or "@s"
    C.chat("/give " .. player .. " " .. item .. " " .. count)
end

-- ============================================================
-- HOTKEY BINDINGS
-- ============================================================

C.bind({"ctrl", "alt"}, "7", advanced.toggleAFKMine, "AFK Mine")
C.bind({"ctrl", "alt"}, "8", advanced.toggleLongClick, "Long Click")
C.bind({"ctrl", "alt"}, "9", advanced.shiftTap, "Shift-Tap")
C.bind({"ctrl", "alt"}, "0", advanced.sTap, "S-Tap")
C.bind({"ctrl", "alt"}, "-", advanced.toggleFastRightClick, "Fast R-Click")
C.bind({"ctrl", "alt"}, "=", advanced.toggleFastLeftClick, "Fast L-Click")
C.bind({"ctrl", "alt"}, "[", advanced.toggleRightClickSpam, "R-Click Spam")
C.bind({"ctrl", "alt"}, "]", advanced.toggleTimedSword, "Timed Sword")
C.bind({"ctrl", "alt"}, "\\", advanced.toggleAutoThrow, "Auto Throw")
C.bind({"ctrl", "alt"}, ";", advanced.toggleSideToSide, "Side-to-Side")
C.bind({"ctrl", "alt"}, "'", advanced.toggleChatAFK, "Chat AFK")
C.bind({"ctrl", "alt"}, "/", advanced.togglePiglinTrade, "Piglin Trade")
C.bind({"ctrl", "alt"}, ".", advanced.headHitJump, "Head-Hit Jump")
C.bind({"ctrl", "alt"}, "L", advanced.strafeJump, "Strafe Jump")
C.bind({"ctrl", "alt"}, "K", advanced.soupHeal, "Soup Heal")
C.bind({"ctrl", "alt"}, "H", advanced.togglePersistentRightClick, "Persist R-Click")
C.bind({"ctrl", "alt"}, "Q", advanced.toggleTripleClick, "Triple Click")

return advanced
