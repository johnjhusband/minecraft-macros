-- chat.lua
-- Chat and Command macros for Minecraft (ported from AHK)
-- Requires mc_core.lua
--
-- INSTALL: Copy mc_core.lua and chat.lua to ~/.hammerspoon/
--   In init.lua: require("chat")

local C = require("mc_core")

local chat = {}

-- ============================================================
-- CONFIGURATION
-- Customize these messages and commands for your server
-- ============================================================

chat.config = {
    -- Quick chat messages (bound to F1-F5 + Ctrl)
    messages = {
        "gg",
        "good game!",
        "nice shot",
        "brb",
        "lol",
    },

    -- Server commands (bound to numpad)
    commands = {
        home    = "/home",
        spawn   = "/spawn",
        back    = "/back",
        sethome = "/sethome",
        tpa     = "/tpa ",  -- trailing space for typing player name
    },

    -- Team callouts (bound to numpad with Ctrl)
    callouts = {
        "Enemy spotted!",
        "Need help!",
        "Rushing mid!",
        "Defending base!",
        "Low health, backing off",
    },

    -- GG variants for random selection
    ggMessages = {
        "gg",
        "gg wp",
        "good game!",
        "GG!",
        "gg well played",
    },
}

local cfg = chat.config

-- ============================================================
-- 74. QUICK CHAT MESSAGES
-- Send predefined messages with hotkeys
-- AHK: mc-binder SendChat()
-- ============================================================

function chat.sendMessage(idx)
    if cfg.messages[idx] then
        C.chat(cfg.messages[idx])
    end
end

-- ============================================================
-- 75. COMMAND MACROS (/home, /spawn, /tpa)
-- Execute server commands with one keypress
-- AHK: MinecraftOnline wiki toChat()
-- ============================================================

function chat.home()    C.chat(cfg.commands.home) end
function chat.spawn()   C.chat(cfg.commands.spawn) end
function chat.back()    C.chat(cfg.commands.back) end
function chat.sethome() C.chat(cfg.commands.sethome) end
function chat.tpa()     C.chat(cfg.commands.tpa) end

-- ============================================================
-- 76. COORDINATE BROADCAST
-- Copy coords with F3+C and paste to chat
-- AHK: F3+C clipboard, parse, send
-- Note: On Mac, F3+C copies /tp command to clipboard
-- ============================================================

function chat.broadcastCoords()
    C.alert("Coords", true)
    -- F3+C in Minecraft copies coordinates to clipboard
    C.keyDown("f3")
    hs.timer.doAfter(0.05, function()
        C.keyPress("c")
        hs.timer.doAfter(0.05, function()
            C.keyUp("f3")
            hs.timer.doAfter(0.2, function()
                local clip = hs.pasteboard.getContents() or ""
                -- Parse: /execute in minecraft:overworld run tp @s X.XX Y.XX Z.ZZ
                local x, y, z = clip:match("tp @s ([%d.-]+) ([%d.-]+) ([%d.-]+)")
                if x then
                    local msg = "My coords: " .. math.floor(tonumber(x)) .. ", " .. math.floor(tonumber(y)) .. ", " .. math.floor(tonumber(z))
                    C.chat(msg)
                else
                    C.alert("No coords found", false)
                end
            end)
        end)
    end)
end

-- ============================================================
-- 77. DEATH MESSAGE MACRO
-- Quick message after respawning
-- AHK: Send {t}, SendInput message, Enter
-- ============================================================

function chat.deathMessage()
    C.chat("I died! Coming back...")
end

-- ============================================================
-- 78. TEAM CALLOUTS
-- Quick team communication
-- AHK: Numpad keys send team messages
-- ============================================================

function chat.callout(idx)
    if cfg.callouts[idx] then
        C.chat(cfg.callouts[idx])
    end
end

-- ============================================================
-- 79. GG AUTO-TYPE
-- Random GG variant
-- AHK: Random pick from gg messages array
-- ============================================================

function chat.gg()
    local idx = math.random(1, #cfg.ggMessages)
    C.chat(cfg.ggMessages[idx])
end

-- ============================================================
-- HOTKEY BINDINGS
-- ============================================================

-- Quick messages: Ctrl+F1 through Ctrl+F5
for i = 1, 5 do
    C.bind({"ctrl"}, "F" .. i, function() chat.sendMessage(i) end, "Chat " .. i)
end

-- Commands: Ctrl+Alt+Shift + keys
C.bind({"ctrl", "alt", "shift"}, "1", chat.home, "Home")
C.bind({"ctrl", "alt", "shift"}, "2", chat.spawn, "Spawn")
C.bind({"ctrl", "alt", "shift"}, "3", chat.back, "Back")
C.bind({"ctrl", "alt", "shift"}, "4", chat.sethome, "Set Home")
C.bind({"ctrl", "alt", "shift"}, "5", chat.tpa, "TPA")

-- Callouts: Ctrl+Shift+F6 through Ctrl+Shift+F10
for i = 1, 5 do
    C.bind({"ctrl", "shift"}, "F" .. (i + 5), function() chat.callout(i) end, "Callout " .. i)
end

-- GG: Ctrl+Shift+G
C.bind({"ctrl", "shift"}, "G", chat.gg, "GG")

-- Coords: Ctrl+Shift+B (broadcast)
C.bind({"ctrl", "shift"}, "B", chat.broadcastCoords, "Broadcast Coords")

-- Death message: Ctrl+Shift+D
C.bind({"ctrl", "shift"}, "D", chat.deathMessage, "Death Message")

return chat
