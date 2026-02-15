-- combat.lua
-- PvP Combat macros for Minecraft (ported from AHK)
-- Requires mc_core.lua in the same directory
--
-- INSTALL: Copy mc_core.lua and combat.lua to ~/.hammerspoon/
--   In init.lua: require("combat")

local C = require("mc_core")

local combat = {}

-- ============================================================
-- CONFIG
-- ============================================================

combat.config = {
    jitterMinCPS     = 12,       -- Min CPS for jitter click
    jitterMaxCPS     = 20,       -- Max CPS for jitter click
    butterflyMinMs   = 25,       -- Butterfly click min delay
    butterflyMaxMs   = 50,       -- Butterfly click max delay
    blockHitDelayMs  = 50,       -- Delay between hit and block
    bowChargeMs      = 200,      -- Minimum bow charge time
    crystalDelayMs   = 30,       -- Delay between crystal actions
    eatGapMs         = 1610,     -- Golden apple eat duration
    swordSlot        = "1",
    axeSlot          = "2",
    rodSlot          = "2",
    bowSlot          = "3",
    crystalSlot      = "3",
    obsidianSlot     = "4",
    potionSlot       = "3",
    pearlSlot        = "4",
    totemSlot        = "3",
    foodSlot         = "2",
    crossbowSlot     = "2",
    maceSlot         = "1",
    tridentSlot      = "2",
}

local cfg = combat.config

-- ============================================================
-- 11. JITTER CLICK SIMULATOR
-- Randomized CPS to appear human-like
-- AHK: Random wait between clicks
-- ============================================================

function combat.toggleJitterClick()
    local on = C.toggle("jitterClick")
    C.alert("Jitter Click", on)
    if on then
        local function click()
            local minDelay = 1.0 / cfg.jitterMaxCPS
            local maxDelay = 1.0 / cfg.jitterMinCPS
            local delay = minDelay + math.random() * (maxDelay - minDelay)
            C.leftClick()
            -- Randomize next interval
            C.stopTimer("jitterClick")
            if C.isOn("jitterClick") and C.isMinecraftFocused() then
                C._timers["jitterClick"] = hs.timer.doAfter(delay, click)
            end
        end
        click()
    else
        C.stopTimer("jitterClick")
    end
end

-- ============================================================
-- 12. BUTTERFLY CLICK SIMULATOR
-- Alternates rapid double-clicks with timing variation
-- AHK: Click, Sleep(Random(25,40)), Click, Sleep(Random(30,50))
-- ============================================================

function combat.toggleButterflyClick()
    local on = C.toggle("butterflyClick")
    C.alert("Butterfly Click", on)
    if on then
        local function click()
            if not C.isOn("butterflyClick") or not C.isMinecraftFocused() then return end
            C.leftClick()
            local d1 = (cfg.butterflyMinMs + math.random() * (cfg.butterflyMaxMs - cfg.butterflyMinMs)) / 1000
            hs.timer.doAfter(d1, function()
                if not C.isOn("butterflyClick") then return end
                C.leftClick()
                local d2 = (cfg.butterflyMinMs + math.random() * (cfg.butterflyMaxMs - cfg.butterflyMinMs)) / 1000
                hs.timer.doAfter(d2, click)
            end)
        end
        click()
    end
end

-- ============================================================
-- 13. BLOCK-HIT COMBO (1.8 sword + block)
-- Attack then right-click to block with sword
-- AHK: Click, Sleep 50, Click Right, Sleep 50
-- ============================================================

function combat.toggleBlockHit()
    local on = C.toggle("blockHit")
    C.alert("Block-Hit", on)
    if on then
        C.startTimer("blockHit",
            function() return C.isOn("blockHit") and C.isMinecraftFocused() end,
            function()
                C.leftClick()
                hs.timer.doAfter(cfg.blockHitDelayMs / 1000, function()
                    C.rightClick()
                end)
            end,
            (cfg.blockHitDelayMs * 2 + 20) / 1000
        )
    else
        C.stopTimer("blockHit")
    end
end

-- ============================================================
-- 14. SHIELD BASH / AXE SWAP COMBO
-- Hit with axe to disable shield, swap to sword for follow-up
-- AHK: Send {2}, Click, Send {1}, Click
-- ============================================================

function combat.shieldBash()
    C.alert("Shield Bash", true)
    C.runSequence({
        {function() C.keyPress(cfg.axeSlot) end, 50},
        {function() C.leftClick() end, 50},
        {function() C.keyPress(cfg.swordSlot) end, 50},
        {function() C.leftClick() end, 0},
    })
end

-- ============================================================
-- 15. ROD COMBO (Fishing Rod + Sword Swap)
-- Throw rod to knockback, swap to sword, attack
-- AHK: Send {2}, Click Right, Send {1}, Click, Click
-- ============================================================

function combat.rodCombo()
    C.alert("Rod Combo", true)
    C.runSequence({
        {function() C.keyPress(cfg.rodSlot) end, 30},
        {function() C.rightClick() end, 100},
        {function() C.keyPress(cfg.swordSlot) end, 30},
        {function() C.leftClick() end, 50},
        {function() C.leftClick() end, 0},
    })
end

-- ============================================================
-- 16. BOW SPAM / QUICK BOW
-- Rapid low-charge bow shots
-- AHK: RButton down, Sleep 200, RButton up, repeat
-- ============================================================

function combat.toggleBowSpam()
    local on = C.toggle("bowSpam")
    C.alert("Bow Spam", on)
    if on then
        local function shoot()
            if not C.isOn("bowSpam") or not C.isMinecraftFocused() then return end
            C.rightDown()
            hs.timer.doAfter(cfg.bowChargeMs / 1000, function()
                C.rightUp()
                hs.timer.doAfter(0.1, shoot)
            end)
        end
        shoot()
    else
        C.rightUp()
    end
end

-- ============================================================
-- 17. CRYSTAL PVP (Place + Hit)
-- Place end crystal then punch it for explosion damage
-- AHK: Send {4}, Click Right, Send {3}, Click Right, Send {1}, Click
-- ============================================================

function combat.crystalPlace()
    C.alert("Crystal", true)
    C.runSequence({
        {function() C.keyPress(cfg.obsidianSlot) end, 30},
        {function() C.rightClick() end, 50},
        {function() C.keyPress(cfg.crystalSlot) end, 30},
        {function() C.rightClick() end, 30},
        {function() C.keyPress(cfg.swordSlot) end, 30},
        {function() C.leftClick() end, 0},
    })
end

function combat.toggleCrystalSpam()
    local on = C.toggle("crystalSpam")
    C.alert("Crystal Spam", on)
    if on then
        C.startTimer("crystalSpam",
            function() return C.isOn("crystalSpam") and C.isMinecraftFocused() end,
            function()
                C.rightClick()
                hs.timer.doAfter(cfg.crystalDelayMs / 1000, function()
                    C.leftClick()
                end)
            end,
            (cfg.crystalDelayMs * 2 + 20) / 1000
        )
    else
        C.stopTimer("crystalSpam")
    end
end

-- ============================================================
-- 18. TOTEM SWAP (Offhand Totem Replacement)
-- Swap totem from hotbar to offhand via F key
-- AHK: Send {3}, Send {f}, Send {1}
-- ============================================================

function combat.totemSwap()
    C.alert("Totem Swap", true)
    C.runSequence({
        {function() C.keyPress(cfg.totemSlot) end, 30},
        {function() C.keyPress("f") end, 30},
        {function() C.keyPress(cfg.swordSlot) end, 0},
    })
end

-- ============================================================
-- 19. POT SPLASH (Throw Potion + Swap Back)
-- Look down, throw splash potion, look up, swap to sword
-- AHK: Send {3}, mouse_event down, Click Right, mouse_event up, Send {1}
-- ============================================================

function combat.potSplash()
    C.alert("Pot Splash", true)
    C.runSequence({
        {function() C.keyPress(cfg.potionSlot) end, 30},
        {function() C.mouseMoveDelta(0, 400) end, 50},
        {function() C.rightClick() end, 50},
        {function() C.mouseMoveDelta(0, -400) end, 30},
        {function() C.keyPress(cfg.swordSlot) end, 0},
    })
end

-- ============================================================
-- 20. FIREWORK CROSSBOW RAPID FIRE
-- Fire loaded crossbow, reload, repeat
-- AHK: Click Right, Sleep 100, Click Right, Sleep 1250
-- ============================================================

function combat.toggleCrossbowSpam()
    local on = C.toggle("crossbowSpam")
    C.alert("Crossbow Spam", on)
    if on then
        local function fire()
            if not C.isOn("crossbowSpam") or not C.isMinecraftFocused() then return end
            C.rightClick()  -- fire
            hs.timer.doAfter(0.1, function()
                C.rightDown()  -- start reload
                hs.timer.doAfter(1.25, function()
                    C.rightUp()  -- crossbow auto-loads
                    hs.timer.doAfter(0.1, fire)
                end)
            end)
        end
        fire()
    else
        C.rightUp()
    end
end

-- ============================================================
-- 21. MACE SMASH COMBO
-- Jump + time attack at landing for smash damage (1.21+)
-- AHK: Send Space, look down, Click on landing
-- ============================================================

function combat.maceSmash()
    C.alert("Mace Smash", true)
    C.runSequence({
        {function() C.keyPress(cfg.maceSlot) end, 30},
        {function() C.keyPress("space") end, 300},
        {function() C.mouseMoveDelta(0, 200) end, 200},
        {function() C.leftClick() end, 50},
        {function() C.mouseMoveDelta(0, -200) end, 0},
    })
end

-- ============================================================
-- 22. TRIDENT RIPTIDE COMBO
-- Charge trident, release for riptide, swap to sword mid-air
-- AHK: Send {2}, RButton hold, release, Send {1}, Click
-- ============================================================

function combat.riptideCombo()
    C.alert("Riptide", true)
    C.runSequence({
        {function() C.keyPress(cfg.tridentSlot) end, 50},
        {function() C.rightDown() end, 600},
        {function() C.rightUp() end, 200},
        {function() C.keyPress(cfg.swordSlot) end, 30},
        {function() C.leftClick() end, 0},
    })
end

-- ============================================================
-- 23. SWORD SWAP HOTBAR CYCLING
-- Cycle hotbar slots forward/backward
-- AHK: currentSlot++, Send {slot}
-- ============================================================

local currentSlot = 1

function combat.hotbarNext()
    currentSlot = (currentSlot % 9) + 1
    C.keyPress(tostring(currentSlot))
end

function combat.hotbarPrev()
    currentSlot = currentSlot - 1
    if currentSlot < 1 then currentSlot = 9 end
    C.keyPress(tostring(currentSlot))
end

-- ============================================================
-- 24. GOLDEN APPLE EAT + FIGHT
-- Eat golden apple then swap back to sword
-- AHK: Send {2}, RButton hold 1610ms, release, Send {1}
-- ============================================================

function combat.eatGap()
    C.alert("Eating Gap...", true)
    C.runSequence({
        {function() C.keyPress(cfg.foodSlot) end, 50},
        {function() C.rightDown() end, cfg.eatGapMs},
        {function() C.rightUp() end, 30},
        {function() C.keyPress(cfg.swordSlot) end, 0},
        {function() C.alert("Gap Done", false) end, 0},
    })
end

-- ============================================================
-- 25. PEARL CLUTCH (Throw Ender Pearl)
-- Quick pearl throw then swap back to weapon
-- AHK: Send {4}, Click Right, Send {1}
-- ============================================================

function combat.pearlThrow()
    C.alert("Pearl!", true)
    C.runSequence({
        {function() C.keyPress(cfg.pearlSlot) end, 50},
        {function() C.rightClick() end, 50},
        {function() C.keyPress(cfg.swordSlot) end, 0},
    })
end

-- ============================================================
-- DEFAULT HOTKEY BINDINGS
-- All use Ctrl+Alt prefix to avoid conflicts
-- ============================================================

C.bind({"ctrl", "alt"}, "J", combat.toggleJitterClick, "Jitter Click")
C.bind({"ctrl", "alt"}, "B", combat.toggleButterflyClick, "Butterfly Click")
C.bind({"ctrl", "alt"}, "G", combat.toggleBlockHit, "Block-Hit")
C.bind({"ctrl", "alt"}, "X", combat.shieldBash, "Shield Bash")
C.bind({"ctrl", "alt"}, "R", combat.rodCombo, "Rod Combo")
C.bind({"ctrl", "alt"}, "O", combat.toggleBowSpam, "Bow Spam")
C.bind({"ctrl", "alt"}, "Y", combat.crystalPlace, "Crystal Place")
C.bind({"ctrl", "alt"}, "U", combat.toggleCrystalSpam, "Crystal Spam")
C.bind({"ctrl", "alt"}, "T", combat.totemSwap, "Totem Swap")
C.bind({"ctrl", "alt"}, "P", combat.potSplash, "Pot Splash")
C.bind({"ctrl", "alt"}, "I", combat.toggleCrossbowSpam, "Crossbow Spam")
C.bind({"ctrl", "alt"}, "M", combat.maceSmash, "Mace Smash")
C.bind({"ctrl", "alt"}, "N", combat.riptideCombo, "Riptide Combo")
C.bind({"ctrl", "alt"}, ".", combat.hotbarNext, "Hotbar Next")
C.bind({"ctrl", "alt"}, ",", combat.hotbarPrev, "Hotbar Prev")
C.bind({"ctrl", "alt"}, "A", combat.eatGap, "Eat Gap")
C.bind({"ctrl", "alt"}, "E", combat.pearlThrow, "Pearl Throw")

return combat
