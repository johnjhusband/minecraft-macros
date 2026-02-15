-- utility.lua
-- Utility macros for Minecraft (ported from AHK)
-- Requires mc_core.lua
--
-- INSTALL: Copy mc_core.lua and utility.lua to ~/.hammerspoon/
--   In init.lua: require("utility")

local C = require("mc_core")

local utility = {}

-- ============================================================
-- 80. CLEAN SCREENSHOT
-- Hide GUI, take screenshot, restore GUI
-- AHK: F1, F2, F1
-- ============================================================

function utility.cleanScreenshot()
    C.runSequence({
        {function() C.keyPress("f1") end, 100},    -- hide HUD
        {function() C.keyPress("f2") end, 100},    -- screenshot
        {function() C.keyPress("f1") end, 0},      -- restore HUD
    })
    C.alert("Screenshot", true)
end

-- ============================================================
-- 81. F3 DEBUG + COPY COORDS
-- Toggle debug screen, copy coordinates, close debug
-- AHK: F3, F3+C, F3
-- ============================================================

function utility.debugCopyCoords()
    C.keyPress("f3")
    hs.timer.doAfter(0.5, function()
        C.keyDown("f3")
        hs.timer.doAfter(0.05, function()
            C.keyPress("c")
            C.keyUp("f3")
            hs.timer.doAfter(0.1, function()
                C.keyPress("f3")
                C.alert("Coords Copied", true)
            end)
        end)
    end)
end

-- ============================================================
-- 82. FULLBRIGHT TOGGLE
-- Toggle gamma in Minecraft options.txt
-- AHK: FileRead options.txt, replace gamma value
-- Note: macOS Minecraft directory is ~/Library/Application Support/minecraft
-- ============================================================

function utility.toggleFullbright()
    local mcDir = os.getenv("HOME") .. "/Library/Application Support/minecraft"
    local optionsPath = mcDir .. "/options.txt"
    local f = io.open(optionsPath, "r")
    if not f then
        C.alert("options.txt not found", false)
        return
    end
    local content = f:read("*a")
    f:close()

    local newContent
    if content:find("gamma:1%.0") then
        newContent = content:gsub("gamma:1%.0", "gamma:15.0")
        C.alert("FULL BRIGHT", true)
    else
        newContent = content:gsub("gamma:[%d.]+", "gamma:1.0")
        C.alert("Normal Bright", true)
    end

    local fw = io.open(optionsPath, "w")
    if fw then
        fw:write(newContent)
        fw:close()
    end
end

-- ============================================================
-- 83. FOV TOGGLE (Zoom)
-- No direct equivalent on Mac (AHK used SystemParametersInfo)
-- Instead: toggle between current FOV and low FOV via options.txt
-- ============================================================

function utility.toggleZoom()
    local mcDir = os.getenv("HOME") .. "/Library/Application Support/minecraft"
    local optionsPath = mcDir .. "/options.txt"
    local f = io.open(optionsPath, "r")
    if not f then
        C.alert("options.txt not found", false)
        return
    end
    local content = f:read("*a")
    f:close()

    local currentFov = content:match("fov:([%d.-]+)")
    local newContent
    if currentFov and tonumber(currentFov) > 40 then
        -- Save current and set low
        utility._savedFov = currentFov
        newContent = content:gsub("fov:[%d.-]+", "fov:30.0")
        C.alert("ZOOMED", true)
    else
        -- Restore
        local restore = utility._savedFov or "70.0"
        newContent = content:gsub("fov:[%d.-]+", "fov:" .. restore)
        C.alert("Normal FOV", true)
    end

    local fw = io.open(optionsPath, "w")
    if fw then
        fw:write(newContent)
        fw:close()
    end
end

-- ============================================================
-- 84. GUI SCALE TOGGLE
-- Cycle through GUI scale in options.txt
-- AHK: Modify guiScale in options.txt
-- ============================================================

local guiScaleIdx = 0
local guiScaleNames = {"Auto", "Small", "Normal", "Large"}

function utility.cycleGuiScale()
    guiScaleIdx = (guiScaleIdx + 1) % 4
    local mcDir = os.getenv("HOME") .. "/Library/Application Support/minecraft"
    local optionsPath = mcDir .. "/options.txt"
    local f = io.open(optionsPath, "r")
    if not f then return end
    local content = f:read("*a")
    f:close()

    local newContent = content:gsub("guiScale:%d+", "guiScale:" .. guiScaleIdx)
    local fw = io.open(optionsPath, "w")
    if fw then
        fw:write(newContent)
        fw:close()
    end
    C.alert("GUI: " .. guiScaleNames[guiScaleIdx + 1], true)
end

-- ============================================================
-- 85. PERSPECTIVE TOGGLE (F5 Cycling)
-- Quick toggle between 1st and 3rd person
-- AHK: F5 once or twice
-- ============================================================

local perspective = 1

function utility.togglePerspective()
    if perspective == 1 then
        C.keyPress("f5")
        perspective = 3
        C.alert("3rd Person", true)
    else
        C.keyPress("f5")
        C.keyPress("f5")
        perspective = 1
        C.alert("1st Person", true)
    end
end

-- ============================================================
-- 86. AUTO-RECONNECT
-- Check for disconnect and reconnect
-- Note: Image detection not available in Hammerspoon.
-- Instead, watches for Minecraft window title changes.
-- ============================================================

function utility.toggleAutoReconnect()
    local on = C.toggle("autoReconnect")
    C.alert("Auto-Reconnect", on)
    if on then
        C.startTimer("autoReconnect",
            function() return C.isOn("autoReconnect") end,
            function()
                -- Check if Minecraft lost focus or title changed
                -- Basic implementation: just click reconnect area
                local app = hs.application.find("Minecraft")
                if app then
                    local wins = app:allWindows()
                    if #wins > 0 then
                        local title = wins[1]:title() or ""
                        if title:find("Disconnect") or title:find("disconnect") then
                            C.alert("Reconnecting...", true)
                            C.leftClick()
                        end
                    end
                end
            end,
            30  -- check every 30 seconds
        )
    else
        C.stopTimer("autoReconnect")
    end
end

-- ============================================================
-- 87. SERVER HOP
-- Disconnect and join another server
-- AHK: Esc, click Disconnect, click server, double-click
-- Note: Coordinate-based, adjust for your resolution
-- ============================================================

function utility.serverHop()
    C.alert("Server Hop", true)
    C.runSequence({
        {function() C.keyPress("escape") end, 200},
        {function()
            hs.mouse.absolutePosition({x=960, y=500})
            C.leftClick()   -- Disconnect
        end, 2000},
        {function()
            hs.mouse.absolutePosition({x=960, y=300})
            C.leftClick()   -- Select server
            hs.timer.doAfter(0.1, function()
                C.leftClick()   -- Double-click to join
            end)
        end, 0},
    })
end

-- ============================================================
-- 88. COUNTDOWN TIMER
-- Display countdown overlay on screen
-- AHK: GUI timer with AlwaysOnTop
-- ============================================================

function utility.countdown(seconds)
    seconds = seconds or 5
    local remaining = seconds
    local function tick()
        if remaining <= 0 then
            C.alert("GO!", true)
            return
        end
        C.alert(tostring(remaining), true)
        remaining = remaining - 1
        hs.timer.doAfter(1, tick)
    end
    tick()
end

-- ============================================================
-- 89. CLICK COUNTER / CPS DISPLAY
-- Count clicks per second
-- AHK: ~LButton::clickCount++, timer updates display
-- ============================================================

local clickCount = 0
local cpsDisplay = 0
local clickWatcher = nil

function utility.toggleCPSCounter()
    local on = C.toggle("cpsCounter")
    C.alert("CPS Counter", on)
    if on then
        clickCount = 0
        -- Watch for left clicks
        clickWatcher = hs.eventtap.new({hs.eventtap.event.types.leftMouseDown}, function()
            clickCount = clickCount + 1
            return false  -- don't consume the event
        end)
        clickWatcher:start()
        -- Update CPS every second
        C.startTimer("cpsCounter",
            function() return C.isOn("cpsCounter") end,
            function()
                cpsDisplay = clickCount
                clickCount = 0
                C.alert("CPS: " .. cpsDisplay, true)
            end,
            1.0
        )
    else
        C.stopTimer("cpsCounter")
        if clickWatcher then
            clickWatcher:stop()
            clickWatcher = nil
        end
    end
end

-- ============================================================
-- 90. RECORDING TOGGLE
-- Toggle screen recording via OBS hotkey
-- AHK: Send Ctrl+Alt+R (OBS default)
-- ============================================================

local recording = false

function utility.toggleRecording()
    recording = not recording
    C.keyPress("r", {"ctrl", "alt"})
    C.alert(recording and "RECORDING" or "Stopped", true)
end

-- ============================================================
-- 91. PAUSE ON LOST FOCUS TOGGLE
-- F3+P toggles pause on lost focus
-- AHK: Send F3+P
-- ============================================================

function utility.togglePauseOnLostFocus()
    C.keyDown("f3")
    hs.timer.doAfter(0.05, function()
        C.keyPress("p")
        C.keyUp("f3")
        C.alert("Pause Toggle", true)
    end)
end

-- ============================================================
-- HOTKEY BINDINGS
-- ============================================================

C.bind({"ctrl", "alt", "shift"}, "F1", utility.cleanScreenshot, "Screenshot")
C.bind({"ctrl", "alt", "shift"}, "F2", utility.debugCopyCoords, "Copy Coords")
C.bind({"ctrl", "alt", "shift"}, "F3", utility.toggleFullbright, "Fullbright")
C.bind({"ctrl", "alt", "shift"}, "F4", utility.toggleZoom, "Zoom")
C.bind({"ctrl", "alt", "shift"}, "F5", utility.cycleGuiScale, "GUI Scale")
C.bind({"ctrl", "alt", "shift"}, "F6", utility.togglePerspective, "Perspective")
C.bind({"ctrl", "alt", "shift"}, "F7", utility.toggleAutoReconnect, "Auto-Reconnect")
C.bind({"ctrl", "alt", "shift"}, "F8", utility.serverHop, "Server Hop")
C.bind({"ctrl", "alt", "shift"}, "F9", function() utility.countdown(5) end, "Countdown")
C.bind({"ctrl", "alt", "shift"}, "F10", utility.toggleCPSCounter, "CPS Counter")
C.bind({"ctrl", "alt", "shift"}, "F11", utility.toggleRecording, "Recording")
C.bind({"ctrl", "alt", "shift"}, "F12", utility.togglePauseOnLostFocus, "Pause Toggle")

return utility
