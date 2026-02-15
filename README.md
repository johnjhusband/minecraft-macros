# Minecraft Combat Macros

OS-level combat macros for Minecraft Java Edition on Mac using [Hammerspoon](https://www.hammerspoon.org/).

Hammerspoon is a free, open-source macOS automation tool scripted in Lua. It sends keyboard and mouse events at the OS level, so no Minecraft mods are needed.

## Setup

### Prerequisites
- macOS
- Minecraft Java Edition
- [Hammerspoon](https://www.hammerspoon.org/) (free)

### Installation
1. Download and install [Hammerspoon](https://github.com/Hammerspoon/hammerspoon/releases/latest)
2. Grant Accessibility permissions when prompted (System Settings > Privacy & Security > Accessibility)
3. Copy the macro files from this repo into `~/.hammerspoon/`
4. Click the Hammerspoon menu bar icon > Reload Config (or press the reload hotkey)
5. Open Minecraft and use the hotkeys

## Macros

Macro scripts live in the `macros/` directory. Copy them to `~/.hammerspoon/` or `require` them from your `init.lua`.

## How It Works

Hammerspoon uses `hs.eventtap` to send keyboard and mouse events at the OS level. You bind a hotkey to trigger a sequence of timed actions (clicks, key presses, delays). Minecraft receives these as normal input.

### Key APIs
- `hs.hotkey.bind()` — bind a key combo to trigger a macro
- `hs.eventtap.keyStroke()` — send a key press
- `hs.eventtap.leftClick()` — send a mouse click
- `hs.timer.doAfter()` — delay between actions

## Notes
- These macros are intended for singleplayer and private servers
- Many public/competitive servers ban macro usage — check server rules first
- Hammerspoon requires Accessibility permissions to send input events
