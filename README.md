# Hammerspoon Minecraft

Minecraft macros for Mac — ported from the popular AutoHotkey scripts Windows players use.

Built on [Hammerspoon](https://www.hammerspoon.org/), a free, open-source macOS automation tool. No Minecraft mods needed.

## Install Hammerspoon

1. Download from [hammerspoon.org](https://www.hammerspoon.org/) or install with Homebrew:
   ```bash
   brew install --cask hammerspoon
   ```
2. Open Hammerspoon — it appears as an icon in your menu bar
3. When prompted, grant **Accessibility** permissions:
   - System Settings > Privacy & Security > Accessibility > toggle Hammerspoon ON
4. Hammerspoon is now running. It loads scripts from `~/.hammerspoon/`

## Install the Macros

```bash
# Copy the macro file
cp macros/minecraft.lua ~/.hammerspoon/minecraft.lua

# Add it to your Hammerspoon config
echo 'require("minecraft")' >> ~/.hammerspoon/init.lua
```

Then click the Hammerspoon menu bar icon > **Reload Config** (or press the reload hotkey).

## Usage

**All macros are OFF by default.** Press `Ctrl+Shift+M` to enable the macro system. Macros only work when Minecraft is the focused window.

### Hotkeys

| Hotkey | Macro | What It Does |
|--------|-------|-------------|
| `Ctrl+Shift+M` | **Master Toggle** | Enable/disable all macros |
| | **Combat** | |
| `Ctrl+Shift+A` | Auto-Clicker | Rapid left-click (~12 CPS) for PvP |
| `Ctrl+Shift+T` | Timed Attack | Click on sword cooldown timer (1.9+) |
| `Ctrl+Shift+W` | W-Tap | Sprint reset for PvP knockback |
| `Ctrl+Shift+E` | Auto-Eat | Swap to food, eat, swap back to sword |
| | **Movement** | |
| `Ctrl+Shift+F` | Auto-Walk | Toggle holding W |
| `Ctrl+Shift+R` | Sprint | Toggle Ctrl+W sprint |
| `Ctrl+Shift+C` | Crouch | Toggle Shift sneak |
| `Ctrl+Shift+K` | Anti-AFK | Periodic movement to avoid server kick |
| | **Mouse** | |
| `Ctrl+Shift+L` | Left-Hold | Toggle holding left-click (mine/attack) |
| `Ctrl+Shift+H` | Right-Hold | Toggle holding right-click (eat/block/fish) |

### Configuration

Edit the config table at the top of `minecraft.lua` to customize:

```lua
M.config = {
    autoClickCPS      = 12,      -- Clicks per second for auto-clicker
    swordCooldownMs   = 625,     -- Sword cooldown (diamond sword in 1.9+)
    wtapDownMs        = 45,      -- W-tap timing
    wtapUpMs          = 45,      -- W-tap timing
    eatDurationMs     = 5000,    -- How long to hold right-click to eat
    foodSlot          = "2",     -- Hotbar slot for food
    swordSlot         = "1",     -- Hotbar slot for sword
    antiAfkIntervalS  = 60,      -- Seconds between anti-AFK movements
}
```

## AHK to Hammerspoon Porting Guide

This project ports Windows AutoHotkey macros to Hammerspoon Lua for Mac. The mapping:

| AHK | Hammerspoon |
|-----|-------------|
| `Click` | `hs.eventtap.leftClick(pos)` |
| `Click, right` | `hs.eventtap.rightClick(pos)` |
| `Send {LButton Down}` | `hs.eventtap.event.newMouseEvent(types.leftMouseDown, pos):post()` |
| `Send {w Down}` | `hs.eventtap.event.newKeyEvent("w", true):post()` |
| `Send {w Up}` | `hs.eventtap.event.newKeyEvent("w", false):post()` |
| `hs.hotkey.bind()` | `hs.hotkey.bind(mods, key, fn)` |
| `Sleep 100` | `hs.timer.doAfter(0.1, fn)` |
| `SetTimer` | `hs.timer.doWhile(pred, fn, interval)` |
| `#IfWinActive Minecraft` | `isMinecraftFocused()` helper |

## Notes

- These macros are for singleplayer and private servers
- Many public servers (Hypixel, etc.) ban macro usage — check server rules
- Hammerspoon requires macOS Accessibility permissions to send input
- Macros auto-disable when you switch away from Minecraft

## Credits

Ported from the AutoHotkey Minecraft community:
- [justinribeiro/minecraft-hackery-autohotkey](https://github.com/justinribeiro/minecraft-hackery-autohotkey)
- [ztancrell/MinecraftAHK](https://github.com/ztancrell/MinecraftAHK)
- [Petelax/Minecraft-Macros](https://github.com/Petelax/Minecraft-Macros)
- [benhovinga AFK Clicker](https://gist.github.com/benhovinga/8bd08d252957303d06e26b28b82b42a0)
- [AutoHotkey Community Forums](https://www.autohotkey.com/boards/)
