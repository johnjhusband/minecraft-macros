# Minecraft AHK Macro Research

Comprehensive collection of 120+ distinct Minecraft macros sourced from GitHub repos, AutoHotkey community forums, Reddit, and macro-sharing sites. Each entry includes AHK code (or clear pseudocode) and description for porting to Hammerspoon Lua.

**Sources searched:**
- GitHub repos: matthewlinton/MinecraftAHK, ztancrell/MinecraftAHK, Petelax/Minecraft-Macros, houdini101/AHK_Minecraft_Tools, histefanhere/XAHK, Scripter17/Minecraft-Hotkeys, ybhaw/MinecraftAHK, justinribeiro/minecraft-hackery-autohotkey, shock59/bedrock-sprint, ItsMeBrille/minecraft-ahk, pzaerial/minecraft_ahk, Vitrecan/minecraft-ahk-v2-script, rfoxxxy/mc-binder, Bernkastel10/Auto-clicker-Hypixel-, ruby3141/AFKFishing, JangoDarkSaber strip mining gist, BirkhoffLee AFK mining gist, DavidPx AFK fishing gist
- AutoHotkey Community Forums (autohotkey.com/boards)
- Hypixel Forums
- BotMek macro sharing
- Keyran macro sharing
- MinecraftOnline wiki
- Reddit r/AutoHotkey, r/CompetitiveMinecraft

---

## ALREADY IMPLEMENTED (10 macros in minecraft.lua)

1. Auto-clicker (left click repeat)
2. Hold left-click
3. Hold right-click
4. Auto-walk (hold W)
5. Toggle sprint (Ctrl+W)
6. Toggle crouch/sneak
7. W-tap (sprint reset)
8. Timed sword attack (1.9+ cooldown)
9. Auto-eat (swap, eat, swap back)
10. Anti-AFK

---

## PVP COMBAT MACROS

### 11. Jitter Click Simulator (Randomized CPS)
**Source:** [AutoHotkey Forums](https://www.autohotkey.com/boards/viewtopic.php?t=89869), [Bernkastel10/Auto-clicker-Hypixel-](https://github.com/Bernkastel10/Auto-clicker-Hypixel-)
**Description:** Simulates jitter clicking with randomized click intervals to appear human-like. CPS varies between min/max range.
```ahk
; Simple randomized autoclicker
$LButton::
While GetKeyState("LButton", "P") {
    Click
    Random, wait, 50, 83  ; ~12-20 CPS range
    Sleep, wait
}
Return

; Advanced version with configurable CPS range (Bernkastel10)
; Uses GUI sliders for minCPS/maxCPS, stores settings in registry
; Core click loop:
ToggleClicker:
    toggle := !toggle
    if (toggle) {
        Loop {
            if (!toggle)
                break
            Random, delay, % Floor(1000/maxCPS), % Floor(1000/minCPS)
            Click
            ; Random mouse micro-movement to simulate jitter
            Random, moveChance, 1, 100
            if (moveChance <= movementChancePercentage) {
                Random, dx, % -movementStrengthPercent, % movementStrengthPercent
                Random, dy, % -movementStrengthPercent, % movementStrengthPercent
                DllCall("mouse_event", "UInt", 0x01, "Int", dx, "Int", dy)
            }
            Sleep, delay
        }
    }
Return
```

### 12. Butterfly Click Simulator
**Source:** AutoHotkey Forums, [Vitrecan/minecraft-ahk-v2-script](https://github.com/Vitrecan/minecraft-ahk-v2-script)
**Description:** Alternates between two fingers/buttons rapidly. Simulates butterfly clicking by alternating LButton events.
```ahk
; Butterfly click: alternate rapid clicks with slight timing variation
#HotIf WinActive("Minecraft")
CapsLock & LButton:: {
    static toggle := 0
    toggle := !toggle
    if (toggle) {
        SetTimer(butterflyClick, 1)
    } else {
        SetTimer(butterflyClick, 0)
    }
}

butterflyClick() {
    Click
    Sleep(Random(25, 40))  ; First finger
    Click
    Sleep(Random(30, 50))  ; Second finger
}
```

### 13. Block-Hit Combo (1.8 sword + block)
**Source:** [Vitrecan/minecraft-ahk-v2-script](https://github.com/Vitrecan/minecraft-ahk-v2-script), Hypixel Forums
**Description:** For 1.8 PvP - attacks then immediately right-clicks to block with sword, reducing incoming damage while dealing hits.
```ahk
; AHK v2 - Block-Hit from Vitrecan
#HotIf WinActive("Minecraft")
CapsLock & RButton:: {
    autoclick(rButtonClick)
}

rButtonClick() {
    Click                    ; Left click attack
    Send "{RButton}"         ; Right click to block
}

; AHK v1 version:
$XButton1::
toggle := !toggle
While toggle {
    Click                    ; Attack
    Sleep, 50
    Click, Right             ; Block with sword
    Sleep, 50
}
Return
```

### 14. Shield Bash / Axe Swap Combo
**Source:** Pseudocode based on community patterns
**Description:** For 1.9+ PvP - disables opponent's shield with axe hit, then swaps to sword for follow-up damage.
```ahk
; Shield disable combo: axe slot -> hit -> swap to sword -> combo
$XButton1::
    Send, {2}               ; Switch to axe (hotbar slot 2)
    Sleep, 50
    Click                    ; Hit to disable shield (5 second cooldown on shield)
    Sleep, 50
    Send, {1}               ; Switch to sword (hotbar slot 1)
    Sleep, 50
    Click                    ; Follow-up sword hit
Return
```

### 15. Rod Combo (Fishing Rod + Sword Swap)
**Source:** [AutoHotkey Forums - Autorod PvP](https://www.autohotkey.com/boards/viewtopic.php?t=88901)
**Description:** Throws fishing rod to knock back opponent, immediately swaps to sword for combo hits. Classic 1.8 PvP technique.
```ahk
; Rod combo: throw rod -> swap to sword -> attack
$XButton1::
    Send, {2}               ; Switch to rod (hotbar slot 2)
    Sleep, 30
    Click, Right             ; Cast rod
    Sleep, 100
    Send, {1}               ; Switch to sword
    Sleep, 30
    Click                    ; Attack
    Sleep, 50
    Click                    ; Second hit
Return
```

### 16. Bow Spam / Quick Bow
**Source:** [AutoHotkey Forums](https://www.autohotkey.com/board/topic/79980-help-with-minecraft-auto-bow-shoot-please/), [AutoHotkey Forums](https://www.autohotkey.com/boards/viewtopic.php?t=35330)
**Description:** Rapid low-charge bow shots. Holds right-click just long enough for minimum damage then releases.
```ahk
; Quick bow: charge briefly then release, repeat
$XButton2::
toggle := !toggle
While toggle {
    Send, {RButton down}     ; Start charging bow
    Sleep, 200               ; Minimum charge time for arrow to fire
    Send, {RButton up}       ; Release arrow
    Sleep, 100               ; Brief pause between shots
}
Return
```

### 17. Crystal PvP Macro (Place + Hit)
**Source:** [AutoHotkey Forums - Crystal PvP](https://www.autohotkey.com/boards/viewtopic.php?t=119437), BotMek
**Description:** Places end crystal on obsidian and immediately punches it for explosion damage. Core crystal PvP mechanic.
```ahk
; Crystal PvP: place crystal then hit it
; Hotbar: slot 3 = crystals, slot 4 = obsidian, slot 1 = sword
$XButton1::
    Send, {4}               ; Switch to obsidian
    Sleep, 30
    Click, Right             ; Place obsidian
    Sleep, 50
    Send, {3}               ; Switch to end crystals
    Sleep, 30
    Click, Right             ; Place crystal on obsidian
    Sleep, 30
    Send, {1}               ; Switch to sword/hand
    Sleep, 30
    Click                    ; Hit crystal to detonate
Return

; Rapid crystal spam (place + punch loop)
$XButton2::
toggle := !toggle
While toggle {
    Click, Right             ; Place crystal (crystals in hand)
    Sleep, 30
    Click                    ; Punch crystal
    Sleep, 50
}
Return
```

### 18. Totem Swap (Offhand Totem Replacement)
**Source:** Pseudocode based on community patterns, Keyran
**Description:** When totem pops in offhand, quickly opens inventory and moves a new totem to offhand slot. Critical for survival PvP.
```ahk
; Quick totem swap to offhand
; Assumes totem is in a known inventory position
$F::
    Send, {e}               ; Open inventory
    Sleep, 50
    ; Click the totem stack in inventory (position varies)
    MouseMove, 352, 320     ; Adjust coordinates to your totem position
    Sleep, 30
    Click                    ; Pick up totem
    Sleep, 30
    ; Move to offhand slot (shield slot position)
    MouseMove, 248, 280     ; Offhand/shield slot coordinates
    Sleep, 30
    Click                    ; Place totem in offhand
    Sleep, 30
    Send, {e}               ; Close inventory
Return

; Simpler version using F key (swap offhand)
$XButton1::
    Send, {1}               ; Make sure sword is selected
    Sleep, 30
    ; Hotbar totem -> offhand via F key
    Send, {3}               ; Select totem slot
    Sleep, 30
    Send, {f}               ; Swap to offhand
    Sleep, 30
    Send, {1}               ; Back to sword
Return
```

### 19. Pot Splash (Throw Potion + Swap Back)
**Source:** [AutoHotkey Forums - PvP healing](https://www.autohotkey.com/board/topic/84698-minecraft-pvp-server-automatic-healing-and-auto-protect-hit/)
**Description:** Switches to potion slot, looks down, throws splash potion, looks back up, switches to weapon.
```ahk
; Pot splash: look down, throw potion, look up, swap to sword
$XButton1::
    prevSlot := 1                          ; Remember current slot
    Send, {3}                              ; Switch to potion (slot 3)
    Sleep, 30
    DllCall("mouse_event", "UInt", 0x01, "Int", 0, "Int", 400)   ; Look down
    Sleep, 50
    Click, Right                           ; Throw splash potion
    Sleep, 50
    DllCall("mouse_event", "UInt", 0x01, "Int", 0, "Int", -400)  ; Look back up
    Sleep, 30
    Send, {1}                              ; Switch back to sword
Return

; Mushroom soup heal (for servers with soup PvP)
; Source: AutoHotkey Forums
$RButton::
    Click, Right             ; Eat/use soup
    Sleep, 30
    Send, {q}               ; Drop empty bowl
    Sleep, 30
    ; Scroll to next soup
Return
```

### 20. Firework Crossbow Rapid Fire
**Source:** Pseudocode based on community patterns
**Description:** For loaded crossbows with firework rockets - fires and reloads crossbow rapidly.
```ahk
; Rapid firework crossbow: fire loaded crossbow, reload, repeat
$XButton1::
toggle := !toggle
While toggle {
    Click, Right             ; Fire loaded crossbow
    Sleep, 100
    Click, Right             ; Start reloading (hold right click)
    Sleep, 1250              ; Crossbow charge time
    ; Crossbow auto-releases when fully charged
    Sleep, 100
}
Return
```

### 21. Mace Smash Combo
**Source:** Pseudocode based on 1.21+ mechanics
**Description:** Jump or fall from height, time mace attack for smash damage multiplier (1.21+).
```ahk
; Mace smash: jump + time attack at landing
$XButton1::
    Send, {1}               ; Ensure mace selected
    Sleep, 30
    Send, {Space}            ; Jump
    Sleep, 300               ; Wait for peak of jump
    DllCall("mouse_event", "UInt", 0x01, "Int", 0, "Int", 200)  ; Look slightly down
    Sleep, 200               ; Fall timing
    Click                    ; Attack at landing for smash damage
    Sleep, 50
    DllCall("mouse_event", "UInt", 0x01, "Int", 0, "Int", -200) ; Look back up
Return
```

### 22. Trident Riptide Combo
**Source:** Pseudocode based on community patterns
**Description:** Activates riptide trident in rain/water for mobility + attack combo.
```ahk
; Riptide launch + swap to weapon
$XButton1::
    Send, {2}               ; Switch to trident
    Sleep, 50
    Send, {RButton down}    ; Charge trident
    Sleep, 600              ; Charge time
    Send, {RButton up}      ; Release for riptide launch
    Sleep, 200              ; Brief flight time
    Send, {1}               ; Swap to sword mid-air
    Sleep, 30
    Click                    ; Attack while flying past
Return
```

### 23. Sword Swap Hotbar Cycling
**Source:** [AutoHotkey Forums](https://www.autohotkey.com/boards/viewtopic.php?t=118343)
**Description:** Cycles through hotbar slots with mouse side buttons. Used to switch weapons quickly in combat.
```ahk
; Mouse button 4/5 to cycle hotbar forward/backward
; Source: AHK Forums thread t=118343
currentSlot := 1

XButton1::
    currentSlot := Mod(currentSlot, 9) + 1
    Send, {%currentSlot%}
Return

XButton2::
    currentSlot := currentSlot - 1
    if (currentSlot < 1)
        currentSlot := 9
    Send, {%currentSlot%}
Return
```

### 24. Golden Apple Eat + Fight
**Source:** [AutoHotkey Forums](https://www.autohotkey.com/boards/viewtopic.php?t=77776)
**Description:** Eats golden apple while maintaining combat readiness. Swaps to food, eats, swaps back to sword on timer.
```ahk
; Gap (golden apple) + fight: eat then attack
$XButton1::
    Send, {2}               ; Switch to golden apple slot
    Sleep, 50
    Send, {RButton down}    ; Start eating
    Sleep, 1610              ; Golden apple eat time (~1.61 seconds)
    Send, {RButton up}      ; Done eating
    Sleep, 30
    Send, {1}               ; Switch back to sword
Return

; Timed eat + attack alternation for AFK
; Source: AHK Forums thread t=77776
SetTimer, SwingSword, 1500   ; Attack every 1.5 seconds
SetTimer, EatFood, 60000     ; Eat every 60 seconds

SwingSword:
    Send, {1}               ; Sword slot
    Sleep, 50
    Click
Return

EatFood:
    Send, {2}               ; Food slot
    Sleep, 100
    Send, {RButton down}
    Sleep, 1610
    Send, {RButton up}
    Sleep, 100
    Send, {1}               ; Back to sword
Return
```

### 25. Pearl Clutch (Throw Ender Pearl)
**Source:** [Keyran](https://keyran.net/en/games/minecraft/macro/13080), Hypixel Forums
**Description:** Quick ender pearl throw - switches to pearl, throws, switches back to weapon. Used for clutch saves when falling.
```ahk
; Quick pearl throw: swap to pearl, throw, swap back
$XButton1::
    Send, {4}               ; Switch to ender pearl slot
    Sleep, 50
    Click, Right             ; Throw pearl
    Sleep, 50
    Send, {1}               ; Switch back to sword
Return

; Pearl clutch sequence: pearl + block placement
$XButton2::
    Send, {4}               ; Pearl slot
    Sleep, 30
    Click, Right             ; Throw pearl at wall
    Sleep, 30
    Send, {5}               ; Switch to blocks
    Sleep, 200               ; Wait for pearl travel
    ; Look at wall base and spam right-click to place blocks
    DllCall("mouse_event", "UInt", 0x01, "Int", 0, "Int", 300)
    Loop, 5 {
        Click, Right
        Sleep, 50
    }
    DllCall("mouse_event", "UInt", 0x01, "Int", 0, "Int", -300)
Return
```

---

## BUILDING MACROS

### 26. Ninja Bridge (Backward Bridge with Shift Toggle)
**Source:** [Petelax/Minecraft-Macros](https://github.com/Petelax/Minecraft-Macros)
**Description:** Automates ninja bridging - walks backward, crouches at edge, places block, uncrouches, repeats. Stand at edge facing direction to bridge, look down at 80 degrees.
```ahk
; Ninja bridge from Petelax/Minecraft-Macros
; Start facing (0, 90, 180, -90), pitch 80 degrees down
Home::
    loopstop = 0
    Send {s down}
    Sleep 225
    Send {Lshift down}
    Sleep 120
    Click right
    Send {Lshift up}
    Loop, 1000 {
        Sleep 200
        Send {Lshift down}
        Sleep 140
        Click right
        Sleep 30
        Send {Lshift up}
        if loopstop = 1 {
            loopstop = 0
            break
        }
    }
    Send {s up}
Return
End::
    loopstop = 1
Return
```

### 27. Speed Bridge
**Source:** [AutoHotkey Forums](https://www.autohotkey.com/boards/viewtopic.php?t=84528), [Keyran](https://keyran.net/en/games/minecraft/macro/13297)
**Description:** Faster variant of ninja bridging with tighter timing. Hold shift, walk back, release+click+reshift rapidly.
```ahk
; Speed bridge: hold shift, walk backward, unshift-click-reshift quickly
$Home::
toggle := !toggle
if toggle {
    Send, {s down}
    Send, {Shift down}
    Loop {
        if !toggle
            break
        Sleep, 50
        Send, {Shift up}     ; Release shift briefly
        Sleep, 10
        Click, Right          ; Place block
        Sleep, 10
        Send, {Shift down}   ; Re-crouch before falling
        Sleep, 150            ; Walk to next edge
    }
    Send, {s up}
    Send, {Shift up}
}
Return
```

### 28. God Bridge (Forward Bridge, No Sneak)
**Source:** [AutoHotkey Forums](https://www.autohotkey.com/boards/viewtopic.php?t=79697)
**Description:** Walk forward while placing blocks below. Requires precise timing and looking slightly down. Uses S+D + jump every 8 blocks.
```ahk
; God bridge: walk forward, rapidly right-click to place blocks at precise timing
; Requires 45-degree look-down angle
$Home::
toggle := !toggle
if toggle {
    Send, {s down}
    Send, {d down}
    blockCount := 0
    Loop {
        if !toggle
            break
        Click, Right          ; Place block at edge
        Sleep, 50
        blockCount++
        if (Mod(blockCount, 8) = 0) {
            Send, {Space}     ; Jump every 8 blocks
            Sleep, 30
        }
        Sleep, 70             ; Timing between placements (~8-10 CPS)
    }
    Send, {s up}
    Send, {d up}
}
Return
```

### 29. Scaffold Bridge
**Source:** Pseudocode based on common patterns
**Description:** Rapidly places blocks while walking in any direction. Spams right-click while holding movement key.
```ahk
; Scaffold: hold movement + spam right click looking down
$Home::
toggle := !toggle
if toggle {
    Loop {
        if !toggle
            break
        Click, Right
        Sleep, 50             ; Fast right-click spam
    }
}
Return
```

### 30. Breezily Bridge (Strafing Bridge)
**Source:** [Petelax/Minecraft-Macros](https://github.com/Petelax/Minecraft-Macros)
**Description:** Bridges by walking backward while strafing left-right. Creates zigzag pattern, very fast but tricky.
```ahk
; Breezily bridge: alternate A/D strafe while walking backward
; From Petelax/Minecraft-Macros breezily pt1.ahk
Home::
    breakloop := 0
    i := 0
    Send {s down}
    Loop, 100 {
        i++
        Send {a down}
        Sleep, 132
        Send {a up}
        if (breakloop) {
            Send {s up}
            Break
        }
        Sleep, 1
        Send {d down}
        Sleep, 132
        Send {d up}
        if (breakloop) {
            Send {s up}
            Break
        }
    }
Return
End::
    breakloop := 1
    Send {s up}
    Send {d up}
    Send {a up}
Return
```

### 31. Staircase Builder
**Source:** Pseudocode based on community patterns
**Description:** Builds ascending stairs by jumping and placing blocks below.
```ahk
; Staircase builder: jump + place block below + move forward
$Home::
toggle := !toggle
if toggle {
    Loop {
        if !toggle
            break
        Send, {Space}         ; Jump
        Sleep, 100
        DllCall("mouse_event", "UInt", 0x01, "Int", 0, "Int", 500)  ; Look down
        Sleep, 50
        Click, Right          ; Place block below feet
        Sleep, 50
        DllCall("mouse_event", "UInt", 0x01, "Int", 0, "Int", -500) ; Look forward
        Sleep, 50
        Send, {w down}        ; Walk forward
        Sleep, 200
        Send, {w up}
        Sleep, 50
    }
}
Return
```

### 32. Wall Builder
**Source:** Pseudocode based on common building patterns
**Description:** Builds a vertical wall by looking at a surface and placing blocks upward using pillar + movement.
```ahk
; Wall builder: place block, move sideways, repeat for row; then pillar up
$Home::
toggle := !toggle
wallWidth := 5
wallHeight := 3
if toggle {
    Loop, %wallHeight% {
        Loop, %wallWidth% {
            Click, Right      ; Place block
            Sleep, 100
            Send, {d down}
            Sleep, 100
            Send, {d up}
        }
        ; Move up one block (pillar)
        Send, {Space}
        Sleep, 200
        DllCall("mouse_event", "UInt", 0x01, "Int", 0, "Int", 600)
        Click, Right
        DllCall("mouse_event", "UInt", 0x01, "Int", 0, "Int", -600)
        Sleep, 100
        ; Move back to start of row
        Send, {a down}
        Sleep, % wallWidth * 100
        Send, {a up}
    }
}
Return
```

### 33. Floor Filler
**Source:** Pseudocode based on common patterns
**Description:** Fills a flat area by walking in rows while placing blocks below.
```ahk
; Floor filler: walk in rows, place blocks below feet
$Home::
toggle := !toggle
rowLength := 10
numRows := 10
if toggle {
    DllCall("mouse_event", "UInt", 0x01, "Int", 0, "Int", 800)  ; Look straight down
    Loop, %numRows% {
        Send, {w down}
        Loop, %rowLength% {
            Click, Right      ; Place block
            Sleep, 100
        }
        Send, {w up}
        Sleep, 50
        ; Shift one column
        Send, {d down}
        Sleep, 100
        Send, {d up}
        ; Turn around 180 degrees
        DllCall("mouse_event", "UInt", 0x01, "Int", 11000, "Int", 0)
        Sleep, 50
    }
    DllCall("mouse_event", "UInt", 0x01, "Int", 0, "Int", -800)
}
Return
```

### 34. Pillar Up
**Source:** [AutoHotkey Forums](https://www.autohotkey.com/boards/viewtopic.php?t=82156)
**Description:** Jumps and places blocks below feet to build a tower upward.
```ahk
; Pillar up: look down, jump and place block below
$Home::
toggle := !toggle
if toggle {
    DllCall("mouse_event", "UInt", 0x01, "Int", 0, "Int", 1000)  ; Look straight down
    Loop {
        if !toggle
            break
        Send, {Space}         ; Jump
        Sleep, 200            ; Wait until near peak of jump
        Click, Right          ; Place block below feet
        Sleep, 200
    }
    DllCall("mouse_event", "UInt", 0x01, "Int", 0, "Int", -1000)
}
Return
```

### 35. Pillar Down (Mine Below)
**Source:** Pseudocode based on common patterns
**Description:** Mines straight down in a safe staircase pattern (not straight drop).
```ahk
; Pillar down / staircase mine: mine block below, drop, repeat
$Home::
toggle := !toggle
if toggle {
    DllCall("mouse_event", "UInt", 0x01, "Int", 0, "Int", 1000)  ; Look down
    Loop {
        if !toggle
            break
        Send, {Shift down}   ; Crouch for safety
        Click, Down           ; Start mining
        Sleep, 1500           ; Time to break stone
        Click, Up
        Sleep, 500            ; Fall into hole
        Send, {Shift up}
    }
    DllCall("mouse_event", "UInt", 0x01, "Int", 0, "Int", -1000)
}
Return
```

### 36. Diagonal Bridge
**Source:** Pseudocode combining bridge patterns
**Description:** Bridges diagonally by walking at 45-degree angle while placing blocks.
```ahk
; Diagonal bridge: walk S+A or S+D while crouching and placing
$Home::
toggle := !toggle
if toggle {
    Send, {s down}
    Send, {a down}           ; Walk diagonally backward-left
    Send, {Shift down}       ; Crouch
    Loop {
        if !toggle
            break
        Sleep, 50
        Send, {Shift up}
        Sleep, 10
        Click, Right
        Sleep, 10
        Send, {Shift down}
        Sleep, 200
    }
    Send, {s up}
    Send, {a up}
    Send, {Shift up}
}
Return
```

### 37. Platform Builder (NxN)
**Source:** Pseudocode based on building patterns
**Description:** Builds an NxN platform by systematically placing blocks in a grid pattern.
```ahk
; Platform builder: build NxN platform at current position
; Look down at block edge, crouch
$Home::
    platformSize := 5
    Send, {Shift down}       ; Crouch to not fall
    DllCall("mouse_event", "UInt", 0x01, "Int", 0, "Int", 600)  ; Look down at edge
    Loop, %platformSize% {
        Loop, %platformSize% {
            Click, Right      ; Place block
            Sleep, 80
            Send, {d down}
            Sleep, 80
            Send, {d up}
        }
        ; Move to next row
        Send, {s down}
        Sleep, 80
        Send, {s up}
        ; Go back to start of row
        Send, {a down}
        Sleep, % platformSize * 80
        Send, {a up}
    }
    Send, {Shift up}
    DllCall("mouse_event", "UInt", 0x01, "Int", 0, "Int", -600)
Return
```

---

## MOVEMENT MACROS

### 38. Bunny Hop (Jump Spam While Moving)
**Source:** [AutoHotkey Forums](https://www.autohotkey.com/boards/viewtopic.php?t=81785)
**Description:** Continuously jumps while moving forward for maximum speed.
```ahk
; Bunny hop: hold forward + spam jump
$Home::
toggle := !toggle
if toggle {
    Send, {w down}
    Send, {Ctrl down}        ; Sprint
    Loop {
        if !toggle
            break
        Send, {Space}         ; Jump
        Sleep, 100            ; Timing between jumps
    }
    Send, {w up}
    Send, {Ctrl up}
}
Return
```

### 39. Strafe Pattern (A-D Alternating)
**Source:** [AutoHotkey Forums - 45 degree strafe](https://www.autohotkey.com/boards/viewtopic.php?t=83313)
**Description:** Alternates strafing left and right while moving forward. Used for PvP dodging.
```ahk
; Strafe pattern: alternate A-D while holding W
$Home::
toggle := !toggle
if toggle {
    Send, {w down}
    Loop {
        if !toggle
            break
        Send, {a down}
        Sleep, 100
        Send, {a up}
        Sleep, 20
        Send, {d down}
        Sleep, 100
        Send, {d up}
        Sleep, 20
    }
    Send, {w up}
}
Return
```

### 40. Speed Bridge Walk
**Source:** Based on speed bridge patterns
**Description:** Walks backward while crouching at optimal speed for bridge building.
```ahk
; Speed bridge walk: backward + crouch at optimal timing
$Home::
toggle := !toggle
if toggle {
    Send, {s down}
    Loop {
        if !toggle
            break
        Send, {Shift down}
        Sleep, 100
        Send, {Shift up}
        Sleep, 50
    }
    Send, {s up}
}
Return
```

### 41. Sprint Jump
**Source:** [AutoHotkey Forums](https://www.autohotkey.com/board/topic/110127-minecraft-sprint-button-macro/)
**Description:** Double-tap W to sprint then jump for maximum horizontal distance.
```ahk
; Sprint jump: double-tap W + jump for max distance
$XButton1::
    Send, {w down}
    Sleep, 30
    Send, {w up}
    Sleep, 30
    Send, {w down}           ; Double-tap triggers sprint
    Sleep, 50
    Send, {Space}             ; Jump while sprinting
    Sleep, 400
    Send, {w up}
Return

; Alternative: Ctrl+W+Space
$XButton1::
    Send, {Ctrl down}
    Send, {w down}
    Sleep, 50
    Send, {Space}
    Sleep, 400
    Send, {w up}
    Send, {Ctrl up}
Return
```

### 42. MLG Water Bucket
**Source:** Pseudocode based on community techniques
**Description:** When falling, quickly switches to water bucket, places at feet right before landing, then picks up.
```ahk
; MLG water bucket: look down, place water, pick up water
$XButton1::
    Send, {5}               ; Switch to water bucket slot
    Sleep, 30
    DllCall("mouse_event", "UInt", 0x01, "Int", 0, "Int", 1000)  ; Look straight down
    Sleep, 50
    Click, Right             ; Place water
    Sleep, 200               ; Brief delay
    Click, Right             ; Pick water back up
    Sleep, 30
    DllCall("mouse_event", "UInt", 0x01, "Int", 0, "Int", -1000) ; Look back forward
    Send, {1}               ; Switch back to main slot
Return
```

### 43. Boat Clutch
**Source:** Pseudocode based on community techniques
**Description:** Places boat while falling and right-clicks to enter it, canceling fall damage.
```ahk
; Boat clutch: place boat at feet while falling
$XButton1::
    Send, {6}               ; Switch to boat slot
    Sleep, 30
    DllCall("mouse_event", "UInt", 0x01, "Int", 0, "Int", 800)   ; Look down
    Sleep, 30
    Click, Right             ; Place boat
    Sleep, 100
    Click, Right             ; Enter boat
    DllCall("mouse_event", "UInt", 0x01, "Int", 0, "Int", -800)
Return
```

### 44. Ladder Clutch
**Source:** Pseudocode based on community techniques
**Description:** While falling near a wall, quickly places ladder to grab and stop fall.
```ahk
; Ladder clutch: place ladder on wall while falling
$XButton1::
    Send, {7}               ; Switch to ladder slot
    Sleep, 30
    ; Look at wall (horizontal, not down)
    Loop, 3 {
        Click, Right         ; Spam place ladder
        Sleep, 50
    }
    Send, {1}               ; Switch back
Return
```

### 45. Toggle Fly (Creative)
**Source:** [justinribeiro/minecraft-hackery-autohotkey](https://github.com/justinribeiro/minecraft-hackery-autohotkey)
**Description:** Double-taps space to toggle creative flight mode.
```ahk
; Toggle creative fly: double-tap space
$XButton1::
    Send, {Space down}
    Sleep, 75
    Send, {Space up}
    Sleep, 200
    Send, {Space down}
    Sleep, 75
    Send, {Space up}
Return
```

### 46. Elytra Boost (Firework + Elytra)
**Source:** [Scripter17/Minecraft-Hotkeys](https://github.com/Scripter17/Minecraft-Hotkeys), [histefanhere/XAHK](https://github.com/histefanhere/XAHK)
**Description:** Activates elytra by double-jumping then fires a firework rocket for boost.
```ahk
; Elytra boost: double jump to activate elytra + fire rocket
; From Scripter17/Minecraft-Hotkeys and XAHK
!Space::
    Send {Space down}
    Sleep 75
    Send {Space up}
    Sleep 200
    Send {Space down}        ; Double tap to activate elytra
    Sleep 75
    Send {Space up}
    Sleep 50
    Click, Right             ; Fire rocket (must be in hand/offhand)
Return
```

### 47. Crawl Toggle
**Source:** Pseudocode based on game mechanics
**Description:** Uses trapdoor or piston to enter crawling state, or sprint into 1-block gap.
```ahk
; Crawl toggle: place trapdoor above, open it, enter crawl
; Assumes trapdoor in hotbar
$XButton1::
    Send, {8}               ; Switch to trapdoor
    Sleep, 50
    ; Look up at block above
    DllCall("mouse_event", "UInt", 0x01, "Int", 0, "Int", -800)
    Sleep, 50
    Click, Right             ; Place trapdoor above head
    Sleep, 50
    Click, Right             ; Open trapdoor (forces crawl)
    DllCall("mouse_event", "UInt", 0x01, "Int", 0, "Int", 800)   ; Look forward
Return
```

### 48. Swim Spam
**Source:** Pseudocode based on mechanics
**Description:** Rapidly taps space while in water for fast swimming. Also useful for going up in water.
```ahk
; Swim spam: rapidly press space while in water
$Home::
toggle := !toggle
if toggle {
    Send, {w down}           ; Move forward
    Send, {Ctrl down}        ; Sprint swim
    Loop {
        if !toggle
            break
        Send, {Space}         ; Swim up/forward
        Sleep, 50
    }
    Send, {w up}
    Send, {Ctrl up}
}
Return
```

---

## MINING / FARMING MACROS

### 49. Strip Mine Pattern
**Source:** [GitHub Gist - JangoDarkSaber](https://gist.github.com/JangoDarkSaber/cf9f956c2451b01cc7a40fb03b4fa88c)
**Description:** Mines a 1x2 tunnel forward with torch placement every 8 blocks. Full AHK v2 script.
```ahk
; Strip mine from JangoDarkSaber - AHK v2
#Requires AutoHotkey v2.0
StonePick := 5600       ; Time to break deepslate with stone pick (ms)

mine(pick) {
    Send "{Click Down}"
    Sleep pick
    Send "{Shift down}"
    DllCall("mouse_event", "UInt", 0x01, "UInt", 0, "UInt", 80)  ; Look down to mine bottom block
    Sleep pick
    Send "{Click Up}"
    Send "{Shift Up}"
    DllCall("mouse_event", "UInt", 0x01, "UInt", 0, "UInt", -80) ; Look back up
}

placetorch() {
    DllCall("mouse_event", "UInt", 0x01, "UInt", 0, "UInt", 600)  ; Look down at feet
    Sleep 100
    Click "Right"
    Sleep 100
    DllCall("mouse_event", "UInt", 0x01, "UInt", 0, "UInt", -600) ; Look back up
}

walk() {
    Send "{W Down}"
    Sleep 1300
    Send "{W Up}"
}

mineTorchLoop() {
    loop 2 {
        mine(StonePick)
        walk()
    }
    placetorch()
}

Z:: {
    loop {
        mineTorchLoop()
    }
}
```

### 50. Branch Mine Pattern
**Source:** Pseudocode based on strip mine extension
**Description:** Mines a main tunnel, then branches off at intervals. Classic Y=11 branch mining.
```ahk
; Branch mine: main tunnel + side branches every 4 blocks
$Home::
    branchLength := 20       ; Blocks per branch
    branchInterval := 4      ; Blocks between branches
    numBranches := 5

    Loop, %numBranches% {
        ; Mine forward in main tunnel
        Loop, %branchInterval% {
            Click, Down       ; Mine forward (top block)
            Sleep, 1500
            ; Mine bottom block
            DllCall("mouse_event", "UInt", 0x01, "Int", 0, "Int", 80)
            Sleep, 1500
            DllCall("mouse_event", "UInt", 0x01, "Int", 0, "Int", -80)
            Click, Up
            Send, {w down}
            Sleep, 200
            Send, {w up}
        }
        ; Turn right for branch
        DllCall("mouse_event", "UInt", 0x01, "Int", 5500, "Int", 0)  ; Turn 90 right
        Sleep, 50
        ; Mine branch
        Loop, %branchLength% {
            Click, Down
            Sleep, 1500
            DllCall("mouse_event", "UInt", 0x01, "Int", 0, "Int", 80)
            Sleep, 1500
            DllCall("mouse_event", "UInt", 0x01, "Int", 0, "Int", -80)
            Click, Up
            Send, {w down}
            Sleep, 200
            Send, {w up}
        }
        ; Turn around and go back
        DllCall("mouse_event", "UInt", 0x01, "Int", 11000, "Int", 0)  ; Turn 180
        Send, {w down}
        Sleep, % branchLength * 200
        Send, {w up}
        ; Turn left to continue main tunnel
        DllCall("mouse_event", "UInt", 0x01, "Int", -5500, "Int", 0)  ; Turn 90 left
    }
Return
```

### 51. Auto-Dig Down (Staircase Mine)
**Source:** Based on strip mine patterns
**Description:** Mines downward in a safe staircase pattern - mine 2 blocks forward, mine 1 block down, step forward.
```ahk
; Staircase mine: mine forward+down in safe staircase pattern
$Home::
toggle := !toggle
if toggle {
    Loop {
        if !toggle
            break
        ; Mine forward (eye level)
        Click, Down
        Sleep, 1500
        Click, Up
        ; Mine block at feet level
        DllCall("mouse_event", "UInt", 0x01, "Int", 0, "Int", 400)
        Click, Down
        Sleep, 1500
        Click, Up
        ; Mine block below feet
        DllCall("mouse_event", "UInt", 0x01, "Int", 0, "Int", 400)
        Click, Down
        Sleep, 1500
        Click, Up
        DllCall("mouse_event", "UInt", 0x01, "Int", 0, "Int", -800)  ; Look back to eye level
        ; Walk forward into the hole
        Send, {w down}
        Sleep, 300
        Send, {w up}
    }
}
Return
```

### 52. AFK Fish Farm
**Source:** [houdini101/AHK_Minecraft_Tools](https://github.com/houdini101/AHK_Minecraft_Tools), [ruby3141/AFKFishing](https://github.com/ruby3141/AFKFishing), [DavidPx Gist](https://gist.github.com/DavidPx/0434b13452ee17d0524d4c58c210dec3)
**Description:** Automated fishing - detects when fish is caught via image/pixel search, reels in and recasts.
```ahk
; Simple AFK fishing from DavidPx - click every 500ms
^!f::
    BreakLoop = 0
    Loop {
        if (BreakLoop = 1) {
            BreakLoop = 0
            break
        }
        Sleep 500
        MouseClick, Right     ; Right-click to reel in and recast
    }
Return
Pause::
    BreakLoop = 1
Return

; Advanced AFK fishing with image detection from houdini101
; Uses ImageSearch to detect fish hook bobbing
; Reels in only when fish is caught, recasts automatically
; Tracks catch count and elapsed time
!c::
    Fishing := "Auto"
    FishCount := 0
    Send {RButton}            ; Initial cast
    Loop {
        if Fishing != Auto
            break
        ImageSearch, , , 1005, 555, 1085, 655, *40 *TransBlack fishHookImage
        if ErrorLevel = 0 {
            Send {RButton}    ; Reel in
            Sleep, 300
            Send {RButton}    ; Recast
            FishCount += 1
            Sleep, 2000
        }
        Sleep, 100
    }
Return

; AFK fishing with auto-restart from ruby3141/AFKFishing
; F11 toggles right-click hold for fishing
; F12 enables auto-restart timer that detects disconnect screen
*F11::
    AfkToggle := !AfkToggle
    If (AfkToggle)
        ControlClick,, Minecraft,, right,, D
    else
        ControlClick,, Minecraft,, right,, U
Return
```

### 53. AFK Crop Farm (Break + Replant)
**Source:** [Petelax/Minecraft-Macros](https://github.com/Petelax/Minecraft-Macros)
**Description:** Walks forward, breaks crops (left click), replants (right click), advances to next row.
```ahk
; Crop farm: break crop + replant from Petelax
; farming 1 line.ahk
Home::
    b := 0
    While, (i < 100 && !GetKeyState("Insert")) {
        i++
        if (b)
            Break
        MouseClick                ; Left click to break crop
        MouseClick, Right         ; Right click to replant seed
        Send {w down}
        Sleep, 210                ; Walk to next crop
        Send {w up}
        Sleep, 500                ; Wait for replanting
    }
    Send {w up}
Return
Insert::b := 1

; Multi-row farming from Petelax (farming 4line.ahk)
; Harvests 4 rows: breaks, replants, moves mouse to next row, repeats
Home::
    b := 0
    While, (i < 100 && !GetKeyState("Insert")) {
        i++
        DllCall("mouse_event", uint, 1, int, 235, int, 0)  ; Look to row 2
        Sleep, 10
        MouseClick              ; Break
        Sleep, 10
        MouseClick, Right       ; Replant
        Sleep, 100
        DllCall("mouse_event", uint, 1, int, -235, int, 0) ; Look back to row 1
        Sleep, 10
        MouseClick
        Sleep, 10
        MouseClick, Right
        Sleep, 20
        Send {w down}
        Sleep, 195
        Send {w up}
        Sleep, 100
    }
Return
```

### 54. Tree Farm (Chop + Replant)
**Source:** Pseudocode based on farming patterns
**Description:** Chops tree by holding left-click looking up, picks up saplings, replants by right-clicking on ground.
```ahk
; Tree farm: look up, chop trunk, collect drops, replant
$Home::
toggle := !toggle
if toggle {
    Loop {
        if !toggle
            break
        ; Look up at tree trunk
        DllCall("mouse_event", "UInt", 0x01, "Int", 0, "Int", -600)
        ; Hold left-click to chop
        Send, {LButton down}
        Sleep, 5000           ; Time to break logs
        Send, {LButton up}
        ; Look down at ground
        DllCall("mouse_event", "UInt", 0x01, "Int", 0, "Int", 1200)
        Sleep, 500            ; Wait for items to fall
        ; Replant sapling
        Send, {2}             ; Switch to sapling slot
        Sleep, 50
        Click, Right
        Sleep, 50
        Send, {1}             ; Switch to axe
        ; Look back to neutral
        DllCall("mouse_event", "UInt", 0x01, "Int", 0, "Int", -600)
        ; Move to next tree
        Send, {w down}
        Sleep, 500
        Send, {w up}
        Sleep, 2000           ; Wait for tree to grow (with bone meal, less time)
    }
}
Return
```

### 55. Mob Farm AFK Attack
**Source:** [histefanhere/XAHK](https://github.com/histefanhere/XAHK), [Scripter17/Minecraft-Hotkeys](https://github.com/Scripter17/Minecraft-Hotkeys)
**Description:** Periodically attacks mobs at a mob grinder while holding right-click to collect. Sweep attack timing for 1.9+.
```ahk
; Mob farm AFK attack from XAHK - sweeps every 1.2 seconds
; with right-click held to collect items/XP
!m::
    BreakLoop := 0
    Delay := 0
    ; Hold right-click for item collection
    ControlClick, , ahk_class GLFW30, , Right, , NAD
    While (BreakLoop = 0) {
        Sleep 100
        If (Delay >= 12) {      ; 100ms * 12 = 1.2 second sword cooldown
            Delay := 0
            ControlClick, , ahk_class GLFW30, , Left, , NAD
            Sleep 50
            ControlClick, , ahk_class GLFW30, , Left, , NAU
        } Else {
            Delay++
        }
    }
    ControlClick, , ahk_class GLFW30, , Right, , NAU
    ControlClick, , ahk_class GLFW30, , Left, , NAU
Return
!s::BreakLoop := 1
```

### 56. Sugar Cane Farm Click
**Source:** Pseudocode based on farming patterns
**Description:** Walks along sugar cane farm, breaking middle blocks (leaving bottom to regrow).
```ahk
; Sugar cane farm: walk along and break middle blocks
$Home::
toggle := !toggle
if toggle {
    ; Look at sugar cane middle height
    Send, {w down}
    Loop {
        if !toggle
            break
        Click                 ; Break sugar cane
        Sleep, 100
    }
    Send, {w up}
}
Return
```

### 57. XP Bottle Spam
**Source:** Pseudocode based on common use
**Description:** Rapidly throws XP bottles by spam right-clicking. Used to quickly gain XP levels.
```ahk
; XP bottle spam: look down + rapid right-click
$Home::
toggle := !toggle
if toggle {
    DllCall("mouse_event", "UInt", 0x01, "Int", 0, "Int", 800)  ; Look down
    Loop {
        if !toggle
            break
        Click, Right          ; Throw XP bottle
        Sleep, 50             ; Rapid throwing
    }
    DllCall("mouse_event", "UInt", 0x01, "Int", 0, "Int", -800)
}
Return
```

### 58. Enchant Click Pattern
**Source:** Pseudocode based on enchanting workflow
**Description:** Automates enchanting - clicks enchantment table, selects level 30 enchant, retrieves item.
```ahk
; Enchant pattern: click table, select lapis, click level 3 enchant
$XButton1::
    Click, Right             ; Open enchanting table
    Sleep, 300
    ; Click lapis slot (adjust coordinates for your resolution)
    MouseMove, 350, 350
    Click
    Sleep, 100
    ; Click level 3 enchantment option
    MouseMove, 450, 300      ; Bottom enchant option
    Click
    Sleep, 200
    Send, {e}                ; Close menu
Return
```

### 59. Villager Trading Click Pattern
**Source:** [AutoHotkey Forums](https://www.autohotkey.com/boards/viewtopic.php?t=122278)
**Description:** Rapidly clicks to trade with villagers. Moves mouse between offer and confirm button.
```ahk
; Villager trading macro: click trade slots rapidly
; From AHK Forums - crafting/trading macro
; Uses configurable mouse movement delta
dx := 100   ; Mouse movement horizontal
dy := 0     ; Mouse movement vertical
$Ins::
toggle := !toggle
While toggle {
    DllCall("mouse_event", "UInt", 0x01, "Int", dx, "Int", dy)   ; Move to buy button
    Sleep, 30
    Click                     ; Click trade
    Sleep, 30
    DllCall("mouse_event", "UInt", 0x01, "Int", -dx, "Int", -dy) ; Move back
    Sleep, 30
    Click                     ; Click trade item
    Sleep, 30
}
Return
```

### 60. Anvil Repair Sequence
**Source:** Pseudocode based on anvil workflow
**Description:** Places item in first anvil slot, material in second slot, retrieves repaired item.
```ahk
; Anvil repair: place item, place material, collect result
$XButton1::
    Click, Right             ; Open anvil
    Sleep, 300
    ; Move item from hotbar to first slot (shift-click)
    Send, {Shift down}
    Sleep, 30
    Send, {1}                ; Hotbar slot 1 item
    Send, {Shift up}
    Sleep, 100
    ; Move repair material to second slot
    Send, {Shift down}
    Send, {2}                ; Hotbar slot 2 material
    Send, {Shift up}
    Sleep, 100
    ; Click result slot to collect repaired item
    MouseMove, 500, 300      ; Result slot coordinates
    Click
    Sleep, 100
    Send, {e}                ; Close anvil
Return
```

### 61. Furnace Loading Sequence
**Source:** [AutoHotkey Forums - Minecraft Utilities](https://www.autohotkey.com/board/topic/78565-minecraft-utilities-fishing-bot-chest-xfer-auto-furnace/)
**Description:** Loads items into furnace top slot and fuel into bottom slot via shift-clicks.
```ahk
; Furnace loading: shift-click items and fuel into furnace
$XButton1::
    Click, Right             ; Open furnace
    Sleep, 300
    ; Shift-click smeltable items into top slot
    Loop, 3 {
        MouseMove, 300, 400  ; Inventory item position (adjust per resolution)
        Send, {Shift down}
        Click
        Send, {Shift up}
        Sleep, 50
    }
    ; Add fuel to bottom slot
    MouseMove, 300, 450      ; Fuel position
    Send, {Shift down}
    Click
    Send, {Shift up}
    Sleep, 100
    Send, {e}                ; Close
Return
```

### 62. Crafting Table Patterns
**Source:** [AutoHotkey Forums - Minecraft Helper](https://www.autohotkey.com/board/topic/88560-minecraft-helper-quick-block-placement-faster-way-to-craft-and-more/)
**Description:** Fills crafting grid in specific patterns for common recipes.
```ahk
; Craft specific recipe: fill 3x3 grid pattern
; Example: craft sticks (2 planks vertically)
$XButton1::
    Click, Right             ; Open crafting table
    Sleep, 300
    ; Pick up planks from inventory
    MouseMove, 350, 450      ; Plank stack in inventory
    Click
    Sleep, 50
    ; Place in top-center slot
    MouseMove, 370, 250      ; Slot position (4,2 in grid)
    Click, Right             ; Right click to place 1
    Sleep, 50
    ; Place in middle-center slot
    MouseMove, 370, 280      ; Slot position (5,2 in grid)
    Click, Right
    Sleep, 50
    ; Collect result
    MouseMove, 450, 270      ; Result slot
    Click
    Sleep, 50
    Send, {e}
Return
```

### 63. Chest Sort / Quick Move All
**Source:** [AutoHotkey Forums](https://www.autohotkey.com/boards/viewtopic.php?t=21644), [AutoHotkey Forums](https://www.autohotkey.com/board/topic/148636-minecraft-chest-sorter/)
**Description:** Shift-clicks all items from inventory to chest (or vice versa) rapidly.
```ahk
; Quick move all items from inventory to chest
; Shift-click each inventory slot
$XButton1::
    ; Assumes chest is already open
    ; Inventory slots are in a 9x3 grid + hotbar 9x1
    ; Shift-click each slot to move to chest
    startX := 280            ; First inventory slot X
    startY := 400            ; First inventory slot Y
    slotSize := 36           ; Pixels between slots

    Loop, 4 {                ; 4 rows (3 inventory + 1 hotbar)
        row := A_Index
        Loop, 9 {
            col := A_Index
            posX := startX + (col - 1) * slotSize
            posY := startY + (row - 1) * slotSize
            MouseMove, %posX%, %posY%
            Sleep, 20
            Send, {Shift down}
            Click
            Send, {Shift up}
            Sleep, 20
        }
    }
Return
```

### 64. Cobblestone Generator Mining
**Source:** [Scripter17/Minecraft-Hotkeys](https://github.com/Scripter17/Minecraft-Hotkeys), [AutoHotkey Forums](https://www.autohotkey.com/boards/viewtopic.php?t=21289)
**Description:** Mines cobblestone from a generator, waits for regen, mines again. Optionally cycles pickaxes.
```ahk
; Cobblestone generator: mine, wait for regen, repeat
; From Scripter17/Minecraft-Hotkeys
!M::
    stopCurrent := false
    while (stopCurrent <> true) {
        Sleep, 1000
        ControlClick, , ahk_pid %WindowPID%, , Left, , NAD    ; Start mining
        Sleep, 1000
        ControlClick, , ahk_pid %WindowPID%, , Left, , NAU    ; Stop mining
        if (SkyblockMode) {
            Send, {WheelDown}    ; Cycle to next pickaxe if current one is low
        }
        Sleep, 2000              ; Wait for cobble to regenerate
    }
Return
```

### 65. Concrete Maker
**Source:** [histefanhere/XAHK](https://github.com/histefanhere/XAHK), [Scripter17/Minecraft-Hotkeys](https://github.com/Scripter17/Minecraft-Hotkeys)
**Description:** Holds right-click (place concrete powder in water) and left-click (break hardened concrete) simultaneously.
```ahk
; Concrete maker: hold both right and left click
; From XAHK
!C::
    BreakLoop := 0
    While (BreakLoop = 0) {
        ControlClick, , ahk_class GLFW30, , Right, , NAD     ; Place powder
        Sleep 500
        ControlClick, , ahk_class GLFW30, , Left, , NAD      ; Break concrete
        Sleep 100
    }
    ControlClick, , ahk_class GLFW30, , Left, , NAU
    ControlClick, , ahk_class GLFW30, , Right, , NAU
Return
```

### 66. Bonemeal Auto-Farm
**Source:** [AutoHotkey Forums](https://www.autohotkey.com/boards/viewtopic.php?t=98404)
**Description:** Right-clicks to apply bonemeal, left-clicks to harvest, right-clicks to replant. For manual bonemeal farming.
```ahk
; Bonemeal farm: apply bonemeal, harvest, replant
$Home::
toggle := !toggle
if toggle {
    Loop {
        if !toggle
            break
        Send, {2}             ; Switch to bonemeal
        Sleep, 50
        Click, Right          ; Apply bonemeal
        Sleep, 100
        Click, Right          ; Apply more bonemeal
        Sleep, 100
        Send, {1}             ; Switch to tool/hand
        Sleep, 50
        Click                 ; Harvest crop
        Sleep, 100
        Send, {3}             ; Switch to seeds
        Sleep, 50
        Click, Right          ; Replant
        Sleep, 100
    }
}
Return
```

---

## INVENTORY MANAGEMENT MACROS

### 67. Quick Slot Swap (1-9 Cycling)
**Source:** [AutoHotkey Forums](https://www.autohotkey.com/boards/viewtopic.php?t=118343)
**Description:** Mouse wheel or side buttons cycle through hotbar slots 1-9.
```ahk
; Hotbar cycling with mouse side buttons
currentSlot := 1
#IfWinActive Minecraft

XButton1::
    currentSlot++
    if (currentSlot > 9)
        currentSlot := 1
    Send, {%currentSlot%}
Return

XButton2::
    currentSlot--
    if (currentSlot < 1)
        currentSlot := 9
    Send, {%currentSlot%}
Return
```

### 68. Drop All Items
**Source:** [pzaerial/minecraft_ahk](https://github.com/pzaerial/minecraft_ahk)
**Description:** Rapidly drops all items by holding Ctrl+Q (drop stack) on each hotbar slot.
```ahk
; Drop all items: Ctrl+Q on each slot from pzaerial
; autoThrowOut.ahk
^x::
    break := -1
    while break < 0 {
        Send, ^q              ; Drop entire stack
        Sleep, 1
    }
Return
^c::
    break++                   ; Stop dropping
Return
```

### 69. Hotbar Preset Swap
**Source:** Pseudocode based on inventory management
**Description:** Saves and restores hotbar configurations by cycling through inventory with number keys.
```ahk
; Hotbar preset swap: quickly rearrange hotbar to preset
; Opens inventory and moves specific items to hotbar slots
$F6::
    Send, {e}                ; Open inventory
    Sleep, 200
    ; Move sword to slot 1
    MouseMove, 300, 300      ; Sword location in inventory
    Send, {1}                ; Assign to hotbar 1
    Sleep, 50
    ; Move pickaxe to slot 2
    MouseMove, 336, 300      ; Pickaxe location
    Send, {2}
    Sleep, 50
    ; Move food to slot 9
    MouseMove, 372, 300      ; Food location
    Send, {9}
    Sleep, 50
    Send, {e}                ; Close inventory
Return
```

### 70. Offhand Swap Toggle
**Source:** Based on Minecraft F key mechanic
**Description:** Swaps current held item with offhand item using F key.
```ahk
; Offhand swap: press F to swap main hand and offhand
$XButton1::
    Send, {f}                ; Swap main/offhand
Return

; Quick offhand cycle: swap item to offhand, switch slot, swap back
$XButton2::
    Send, {f}                ; Send current to offhand
    Sleep, 30
    Send, {1}                ; Switch to slot 1
    Sleep, 30
    Send, {f}                ; Swap slot 1 to offhand (returns previous offhand to slot 1)
Return
```

### 71. Quick Armor Equip
**Source:** Based on Minecraft shift-click mechanic
**Description:** Opens inventory and shift-clicks armor pieces to quickly equip a full set.
```ahk
; Quick armor equip: open inventory, shift-click each armor piece
$F7::
    Send, {e}                ; Open inventory
    Sleep, 200
    ; Shift-click each armor piece (adjust positions for your inventory layout)
    armorPositions := [{x: 300, y: 350}, {x: 336, y: 350}, {x: 372, y: 350}, {x: 408, y: 350}]
    for index, pos in armorPositions {
        MouseMove, pos.x, pos.y
        Sleep, 30
        Send, {Shift down}
        Click
        Send, {Shift up}
        Sleep, 50
    }
    Send, {e}                ; Close inventory
Return
```

### 72. Shield Swap
**Source:** Based on offhand mechanics
**Description:** Quickly swaps between shield and totem/other offhand items.
```ahk
; Shield swap: swap shield to offhand from specific hotbar slot
$XButton1::
    Send, {5}                ; Switch to shield slot
    Sleep, 30
    Send, {f}                ; Swap to offhand
    Sleep, 30
    Send, {1}                ; Switch back to weapon
Return
```

### 73. Tool Swap (Pick/Shovel/Axe Cycle)
**Source:** Based on common keybind patterns
**Description:** Cycles through pick, shovel, and axe on specific hotbar slots.
```ahk
; Tool cycle: rotate between pickaxe, shovel, axe
tools := [2, 3, 4]          ; Hotbar slots for pick, shovel, axe
toolIndex := 1

$XButton1::
    toolIndex := Mod(toolIndex, tools.Length()) + 1
    slot := tools[toolIndex]
    Send, {%slot%}
Return
```

---

## CHAT / COMMAND MACROS

### 74. Quick Chat Messages
**Source:** [rfoxxxy/mc-binder](https://github.com/rfoxxxy/mc-binder), [MinecraftOnline Wiki](https://minecraftonline.com/wiki/AutoHotkey)
**Description:** Send predefined chat messages with a single hotkey. Configurable per-key bindings.
```ahk
; Quick chat from mc-binder - GUI-based chat binder
; Core function:
SendChat(message) {
    IfWinActive, Minecraft.* {
        Send, {T}             ; Open chat
        Sleep, 100
        SendInput, %message%{ENTER}
    }
}

; Example bindings:
^1::SendChat("gg")
^2::SendChat("good game!")
^3::SendChat("nice shot")
^4::SendChat("brb")
```

### 75. Command Macros (/home, /spawn, /tpa)
**Source:** [MinecraftOnline Wiki](https://minecraftonline.com/wiki/AutoHotkey), [AutoHotkey Forums](https://www.autohotkey.com/boards/viewtopic.php?t=24010)
**Description:** Executes common server commands with a single keypress.
```ahk
; Command macros from MinecraftOnline wiki
SetKeyDelay, 0, 50           ; Prevent commands entering too quickly

; Function to send chat command
toChat(text) {
    Send, t
    Sleep, 200
    Send, %text%
    Send, {Enter}
}

^q::toChat("/home")
^e::toChat("/spawn")
^r::toChat("/tpa friend_name")
^t::toChat("/sethome")
^y::toChat("/back")
^u::toChat("/msg friend_name hello")

; Arrow key navigation (custom warps)
Up::toChat("/home base")
Down::toChat("/spawn")
Left::toChat("/warp shop")
Right::toChat("/warp farm")
```

### 76. Coordinate Broadcast
**Source:** [houdini101/AHK_Minecraft_Tools](https://github.com/houdini101/AHK_Minecraft_Tools)
**Description:** Copies current coordinates from F3 screen and pastes into chat. Uses clipboard from F3+C.
```ahk
; Coordinate broadcast: grab coords with F3+C, send to chat
; Adapted from houdini101's portal calculator
$XButton1::
    ; F3+C copies coordinate command to clipboard
    Clipboard := ""
    Send {F3 down}{c}{F3 up}
    ClipWait, 1
    ; Parse coordinates from clipboard
    ; Clipboard format: /execute in minecraft:overworld run tp @s X.XX Y.XX Z.ZZ
    RegExMatch(Clipboard, "tp @s ([\d.-]+) ([\d.-]+) ([\d.-]+)", coords)
    ; Send to chat
    Send, {t}
    Sleep, 200
    message := "My coords: " . Round(coords1) . ", " . Round(coords2) . ", " . Round(coords3)
    SendInput, %message%
    Send, {Enter}
Return
```

### 77. Death Message Macro
**Source:** Pseudocode based on chat macros
**Description:** Sends a preset message in chat on death, like coordinates of death location.
```ahk
; Death message: quick message after respawning
$F8::
    Send, {t}
    Sleep, 200
    SendInput, I died! Coming back...
    Send, {Enter}
Return
```

### 78. Team Callouts
**Source:** Pseudocode based on chat macros
**Description:** Quick team communication messages bound to numpad keys.
```ahk
; Team callouts on numpad
Numpad1::
    Send, {t}
    Sleep, 200
    SendInput, Enemy spotted!
    Send, {Enter}
Return

Numpad2::
    Send, {t}
    Sleep, 200
    SendInput, Need help!
    Send, {Enter}
Return

Numpad3::
    Send, {t}
    Sleep, 200
    SendInput, Rushing mid!
    Send, {Enter}
Return

Numpad4::
    Send, {t}
    Sleep, 200
    SendInput, Defending base!
    Send, {Enter}
Return

Numpad5::
    Send, {t}
    Sleep, 200
    SendInput, Low health, backing off
    Send, {Enter}
Return
```

### 79. GG Auto-Type
**Source:** Common across all chat macro collections
**Description:** Types "gg" in chat with a single keypress.
```ahk
; GG auto-type
$F9::
    Send, {t}
    Sleep, 200
    SendInput, gg
    Send, {Enter}
Return

; Extended: random GG variants
$F9::
    messages := ["gg", "gg wp", "good game!", "GG!", "gg well played"]
    Random, idx, 1, messages.Length()
    Send, {t}
    Sleep, 200
    SendInput, % messages[idx]
    Send, {Enter}
Return
```

---

## UTILITY MACROS

### 80. Screenshot Macro
**Source:** Pseudocode based on F2 key
**Description:** Takes screenshot, optionally with GUI hidden for clean shots.
```ahk
; Clean screenshot: hide GUI, take screenshot, restore GUI
$PrintScreen::
    Send, {F1}               ; Toggle HUD off
    Sleep, 100
    Send, {F2}               ; Take screenshot
    Sleep, 100
    Send, {F1}               ; Toggle HUD back on
Return
```

### 81. F3 Debug Toggle with Action
**Source:** Based on F3 key combinations
**Description:** Toggles debug screen and performs an action (like copying coordinates).
```ahk
; F3 debug + copy coords
$F10::
    Send, {F3}               ; Toggle debug screen
    Sleep, 500               ; Wait for it to render
    Send, {F3 down}{c}{F3 up}  ; Copy coords to clipboard
    Sleep, 100
    Send, {F3}               ; Toggle debug screen off
    ToolTip, Coordinates copied!
    SetTimer, RemoveToolTip, 2000
Return
RemoveToolTip:
    ToolTip
Return
```

### 82. Gamma/Brightness Toggle (Fullbright)
**Source:** Based on options.txt editing, [AutoHotkey Forums](https://www.autohotkey.com/boards/viewtopic.php?t=122278)
**Description:** Toggles gamma between normal (1.0) and max (15.0) in Minecraft's options.txt for fullbright effect.
```ahk
; Fullbright toggle: modify options.txt gamma value
; Requires knowing Minecraft directory
mcDir := A_AppData . "\.minecraft"

$F10::
    FileRead, options, %mcDir%\options.txt
    if InStr(options, "gamma:1.0") {
        StringReplace, options, options, gamma:1.0, gamma:15.0
        brightness := "FULL BRIGHT"
    } else {
        ; Reset to normal
        RegExReplace(options, "gamma:[\d.]+", "gamma:1.0")
        brightness := "NORMAL"
    }
    FileDelete, %mcDir%\options.txt
    FileAppend, %options%, %mcDir%\options.txt
    ToolTip, Brightness: %brightness%
    SetTimer, RemoveToolTip, 2000
Return
```

### 83. FOV Toggle (Zoom)
**Source:** [AutoHotkey Forums](https://www.autohotkey.com/boards/viewtopic.php?t=24193)
**Description:** Temporarily changes FOV for zoom effect by modifying sensitivity/FOV.
```ahk
; Zoom toggle: lower FOV while held
; Modifies mouse sensitivity via DPI or mouse_event scaling
zoomed := false

$XButton2::
    zoomed := !zoomed
    if (zoomed) {
        ; Lower mouse sensitivity for zoom feel
        DllCall("SystemParametersInfo", "UInt", 0x71, "UInt", 0, "UInt", 2, "UInt", 0)
        ToolTip, ZOOMED
    } else {
        ; Restore normal sensitivity
        DllCall("SystemParametersInfo", "UInt", 0x71, "UInt", 0, "UInt", 10, "UInt", 0)
        ToolTip
    }
Return
```

### 84. GUI Scale Toggle
**Source:** Pseudocode based on options modification
**Description:** Cycles through GUI scale options (auto, small, normal, large).
```ahk
; GUI scale cycle
guiScale := 0  ; 0=auto, 1=small, 2=normal, 3=large

$F11::
    guiScale := Mod(guiScale + 1, 4)
    scales := ["Auto", "Small", "Normal", "Large"]
    ; Would need to modify options.txt or use keybind mod
    ToolTip, % "GUI Scale: " . scales[guiScale + 1]
    SetTimer, RemoveToolTip, 2000
Return
```

### 85. Perspective Toggle (F5 Cycling)
**Source:** Based on F5 key
**Description:** Cycles through first-person, third-person back, third-person front.
```ahk
; Perspective cycle
$F12::
    Send, {F5}               ; Cycle perspective
Return

; Quick toggle between 1st and 3rd person only
perspective := 1

$F12::
    if (perspective = 1) {
        Send, {F5}            ; To 3rd person back
        perspective := 3
    } else {
        Send, {F5}
        Send, {F5}            ; Skip 3rd person front, back to 1st
        perspective := 1
    }
Return
```

### 86. Auto-Reconnect After Disconnect
**Source:** [ruby3141/AFKFishing](https://github.com/ruby3141/AFKFishing), [GitHub - Mx772/AutoJoin](https://github.com/Mx772/AutoJoin)
**Description:** Detects disconnect screen using ImageSearch and automatically clicks to reconnect.
```ahk
; Auto-reconnect using image detection from ruby3141/AFKFishing
SetTimer, AutoRestartTimer, 300000  ; Check every 5 minutes

AutoRestartTimer:
    ; Search for disconnect/back button on screen
    ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, back.png
    if (ErrorLevel = 0) {
        ; Found disconnect screen - click reconnect
        MouseClick, left, FoundX+200, FoundY+20
        Sleep, 300000         ; Wait 5 min for server to be ready
        ; Look for server in list
        ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, server.png
        While (ErrorLevel > 0) {
            Sleep, 60000
            ImageSearch, FoundX, FoundY, 0, 0, A_ScreenWidth, A_ScreenHeight, server.png
        }
        MouseClick, Left, FoundX+291, FoundY+32, 2  ; Double-click server to join
        Sleep, 60000
    }
Return
```

### 87. Server Hop Macro
**Source:** Pseudocode based on server join patterns
**Description:** Disconnects from current server and connects to another server quickly.
```ahk
; Server hop: disconnect and join a different server
$F8::
    Send, {Escape}           ; Open pause menu
    Sleep, 200
    ; Click "Disconnect" button (coordinates vary by resolution)
    MouseMove, 960, 500      ; Disconnect button
    Click
    Sleep, 2000              ; Wait for multiplayer screen
    ; Click server in list (adjust position for target server)
    MouseMove, 960, 300      ; Server entry
    Click
    Click                    ; Double-click to join
Return
```

### 88. Countdown Timer Overlay
**Source:** [AutoHotkey Forums](https://www.autohotkey.com/boards/viewtopic.php?t=58444)
**Description:** Displays countdown timer as overlay on screen. Useful for timing events.
```ahk
; Countdown timer overlay
$F7::
    countdownSeconds := 5

    Gui, Timer:New, +AlwaysOnTop -Caption +ToolWindow
    Gui, Timer:Font, s40, Arial
    Gui, Timer:Color, 000000
    Gui, Timer:Add, Text, cFFFFFF vCountdownText w100 Center, %countdownSeconds%
    Gui, Timer:Show, x960 y50 NoActivate

    Loop, %countdownSeconds% {
        remaining := countdownSeconds - A_Index + 1
        GuiControl, Timer:, CountdownText, %remaining%
        Sleep, 1000
    }
    GuiControl, Timer:, CountdownText, GO!
    Sleep, 1000
    Gui, Timer:Destroy
Return
```

### 89. Click Counter Overlay
**Source:** [AutoHotkey Forums](https://www.autohotkey.com/boards/viewtopic.php?t=89869)
**Description:** Counts and displays clicks per second in an always-on-top overlay.
```ahk
; CPS counter overlay
clickCount := 0
cpsDisplay := 0

SetTimer, UpdateCPS, 1000    ; Update every second

; Count clicks
~LButton::
    clickCount++
Return

UpdateCPS:
    cpsDisplay := clickCount
    clickCount := 0
    ToolTip, CPS: %cpsDisplay%, 10, 10
Return
```

### 90. CPS Display
**Source:** [Bernkastel10/Auto-clicker-Hypixel-](https://github.com/Bernkastel10/Auto-clicker-Hypixel-)
**Description:** GUI-based clicks per second display with both left and right mouse tracking.
```ahk
; CPS display GUI
leftClicks := 0
rightClicks := 0
leftCPS := 0
rightCPS := 0

Gui, CPS:New, +AlwaysOnTop -Caption +ToolWindow
Gui, CPS:Font, s14, Consolas
Gui, CPS:Color, 000000
Gui, CPS:Add, Text, cWhite vCPSText w150, L: 0 | R: 0
Gui, CPS:Show, x10 y10 NoActivate

SetTimer, CalcCPS, 1000

~LButton::leftClicks++
~RButton::rightClicks++

CalcCPS:
    leftCPS := leftClicks
    rightCPS := rightClicks
    leftClicks := 0
    rightClicks := 0
    GuiControl, CPS:, CPSText, L: %leftCPS% | R: %rightCPS%
Return
```

### 91. Recording Toggle
**Source:** Pseudocode based on external tool integration
**Description:** Starts/stops screen recording with OBS or similar via hotkey.
```ahk
; Recording toggle via OBS hotkey
$F9::
    ; Send OBS recording hotkey (must match OBS settings)
    Send, ^!r                 ; Ctrl+Alt+R for OBS record toggle
    recording := !recording
    if (recording)
        ToolTip, RECORDING
    else
        ToolTip
Return
```

---

## REDSTONE / TECHNICAL MACROS

### 92. Repeater Delay Cycling
**Source:** Pseudocode based on right-click mechanics
**Description:** Right-clicks a repeater a specific number of times to set desired delay (1-4 ticks).
```ahk
; Set repeater to specific tick delay
; 1 right-click = 1 tick, 2 = 2 ticks, etc.
$Numpad1::
    Click, Right             ; 1 tick
Return

$Numpad2::
    Click, Right
    Sleep, 50
    Click, Right             ; 2 ticks
Return

$Numpad3::
    Loop, 3 {
        Click, Right
        Sleep, 50
    }                         ; 3 ticks
Return

$Numpad4::
    Loop, 4 {
        Click, Right
        Sleep, 50
    }                         ; 4 ticks (max)
Return
```

### 93. Comparator Toggle
**Source:** Pseudocode based on game mechanics
**Description:** Right-clicks comparator to toggle between comparison and subtraction mode.
```ahk
; Comparator toggle mode
$XButton1::
    Click, Right             ; Toggle comparator mode
Return
```

### 94. Piston Timing Sequence
**Source:** Pseudocode based on redstone timing
**Description:** Activates multiple levers/buttons in sequence with specific timing for piston door or mechanism.
```ahk
; Piston timing: activate buttons in sequence with delays
$F6::
    ; Sequence for a 3-wide piston door
    ; Looking at button 1
    Click, Right             ; Activate first button
    Sleep, 100               ; 1 redstone tick
    ; Turn to button 2
    DllCall("mouse_event", "UInt", 0x01, "Int", 200, "Int", 0)
    Click, Right             ; Second button
    Sleep, 100
    ; Turn to button 3
    DllCall("mouse_event", "UInt", 0x01, "Int", 200, "Int", 0)
    Click, Right             ; Third button
    ; Return view
    DllCall("mouse_event", "UInt", 0x01, "Int", -400, "Int", 0)
Return
```

### 95. TNT Cannon Firing Sequence
**Source:** Based on redstone cannon mechanics
**Description:** Activates TNT cannon by pressing buttons/levers in the correct order and timing.
```ahk
; TNT cannon fire: charge propellant then fire projectile
$F6::
    ; Step 1: Activate charge TNT dispensers (look at button/lever)
    Click, Right             ; Dispense charge TNT
    Sleep, 2000              ; Wait for charge TNT to fall into water
    ; Step 2: Activate projectile TNT
    DllCall("mouse_event", "UInt", 0x01, "Int", 300, "Int", 0)  ; Turn to projectile button
    Click, Right             ; Fire projectile TNT
    DllCall("mouse_event", "UInt", 0x01, "Int", -300, "Int", 0) ; Turn back
Return
```

### 96. Item Dropper Timing
**Source:** Pseudocode based on redstone item systems
**Description:** Drops items at precise intervals for hopper/dropper timing mechanisms.
```ahk
; Item dropper: drop items at timed intervals
$Home::
toggle := !toggle
if toggle {
    Loop {
        if !toggle
            break
        Send, {q}             ; Drop one item
        Sleep, 400            ; 4 redstone ticks between drops
    }
}
Return
```

---

## BEDWARS / SKYWARS SPECIFIC MACROS

### 97. Bed Break Combo (TNT + Rush)
**Source:** Based on Bedwars strategies, [ImADev-101/BW-Macro](https://github.com/ImADev-101/BW-Macro)
**Description:** Places TNT near bed, lights it, and swaps to pickaxe to break bed defense blocks.
```ahk
; Bed break: place TNT + start mining bed defense
$XButton1::
    Send, {4}               ; Switch to TNT
    Sleep, 50
    Click, Right             ; Place TNT
    Sleep, 50
    Send, {1}               ; Switch to pickaxe
    Sleep, 50
    ; Start mining the bed defense blocks
    Click, Down               ; Hold left click to mine
    Sleep, 4000               ; TNT fuse (4 seconds)
    ; TNT explodes and clears blocks, continue mining bed
    Sleep, 2000
    Click, Up
Return
```

### 98. Wool Bridge + Fight Swap
**Source:** [Keyran](https://keyran.net/en/games/minecraft/macro/6426), BotMek
**Description:** Bridges with wool, then quickly swaps to sword when enemy approaches.
```ahk
; Wool bridge + fight: bridge backward, swap to sword on demand
; Default: bridging mode
$Home::
toggle := !toggle
if toggle {
    Send, {2}               ; Switch to wool
    Send, {s down}
    Send, {Shift down}
    Loop {
        if !toggle
            break
        Sleep, 50
        Send, {Shift up}
        Sleep, 10
        Click, Right         ; Place wool
        Sleep, 10
        Send, {Shift down}
        Sleep, 200
    }
    Send, {s up}
    Send, {Shift up}
}
Return

; Quick swap to sword mid-bridge
$XButton1::
    toggle := false          ; Stop bridging
    Send, {s up}
    Send, {Shift up}
    Send, {1}               ; Switch to sword
Return
```

### 99. Shop Buy Sequence
**Source:** Pseudocode based on Bedwars shop patterns
**Description:** Opens shop NPC and clicks through purchase sequence for specific items.
```ahk
; Bedwars shop buy: iron sword purchase sequence
$F6::
    Click, Right             ; Open shop (right-click NPC)
    Sleep, 300
    ; Click weapon category
    MouseMove, 500, 250      ; Weapons tab (adjust coordinates)
    Click
    Sleep, 100
    ; Click iron sword
    MouseMove, 400, 350      ; Iron sword slot
    Click
    Sleep, 100
    Send, {e}                ; Close shop
Return

; Quick buy wool stack
$F7::
    Click, Right             ; Open shop
    Sleep, 300
    MouseMove, 300, 250      ; Blocks tab
    Click
    Sleep, 100
    MouseMove, 300, 350      ; Wool slot
    Click
    Sleep, 100
    Send, {e}
Return
```

### 100. Upgrade Buy Sequence
**Source:** Pseudocode based on Bedwars upgrade mechanics
**Description:** Navigates team upgrade menu and purchases specific upgrades.
```ahk
; Bedwars upgrade purchase
$F8::
    Click, Right             ; Open upgrade NPC
    Sleep, 300
    ; Click desired upgrade (e.g., Protection)
    MouseMove, 400, 300      ; Protection upgrade slot
    Click
    Sleep, 200
    Send, {e}                ; Close
Return
```

### 101. Speed Pot + Bridge Combo
**Source:** Pseudocode based on Bedwars strategies
**Description:** Drinks speed potion then immediately starts bridging for fast rush.
```ahk
; Speed pot + bridge: drink speed then bridge
$XButton1::
    Send, {3}               ; Switch to speed potion
    Sleep, 50
    Send, {RButton down}    ; Start drinking
    Sleep, 1000              ; Drink time
    Send, {RButton up}
    Send, {2}               ; Switch to blocks
    Sleep, 50
    ; Start bridging
    Send, {s down}
    Send, {Shift down}
    Loop, 30 {
        Sleep, 50
        Send, {Shift up}
        Sleep, 10
        Click, Right
        Sleep, 10
        Send, {Shift down}
        Sleep, 200
    }
    Send, {s up}
    Send, {Shift up}
Return
```

### 102. Fireball + Bridge Combo
**Source:** BotMek, Bedwars community
**Description:** Throws fireball to knock enemy off bridge, then continues bridging.
```ahk
; Fireball + bridge: throw fireball then resume bridging
$XButton2::
    ; Pause bridging momentarily
    Send, {Shift down}       ; Stay crouched
    Send, {s up}             ; Stop walking
    Sleep, 50
    Send, {4}               ; Switch to fireball
    Sleep, 50
    Click, Right             ; Throw fireball
    Sleep, 100
    Send, {2}               ; Switch back to blocks
    Sleep, 50
    Send, {s down}           ; Resume walking backward
    Send, {Shift up}         ; Resume bridge timing
Return
```

---

## ADDITIONAL MACROS (103-120+)

### 103. AFK Mining (Lock Click + Mouse)
**Source:** [BirkhoffLee Gist](https://gist.github.com/BirkhoffLee/ace777be9516a9cb4a89a83564defc25)
**Description:** Locks mouse movement and holds left-click for AFK mining. Toggle with Z key.
```ahk
; AFK mining toggle from BirkhoffLee
z::
    if GetKeyState("LButton") {
        Send % "{Click Up}"
        BlockInput, MouseMoveOff
    } else {
        Send % "{Click Down}"
        BlockInput, MouseMove     ; Lock mouse position
    }
Return
```

### 104. Auto Mine Forward
**Source:** [pzaerial/minecraft_ahk](https://github.com/pzaerial/minecraft_ahk)
**Description:** Holds left-click and walks forward simultaneously for tunnel mining.
```ahk
; Mine forward: hold LMB + W from pzaerial
; mineForwardRiskily.ahk
^x::
    MouseClick, left,,, 1, 0, D    ; Hold left click
    Send, {w down}                  ; Walk forward
Return

^c::
    MouseClick, left,,, 1, 0, U    ; Release left click
    Send, {w up}                    ; Stop walking
Return
```

### 105. Arbitrarily Long Mouse Click
**Source:** [pzaerial/minecraft_ahk](https://github.com/pzaerial/minecraft_ahk)
**Description:** Press one key to start holding LMB, another to release. For obsidian mining etc.
```ahk
; Long click toggle from pzaerial
^x:: MouseClick, left,,, 1, 0, D   ; Press LMB down
^c:: MouseClick, left,,, 1, 0, U   ; Release LMB
```

### 106. MCMMO Acrobatics Leveling
**Source:** [ztancrell/MinecraftAHK](https://github.com/ztancrell/MinecraftAHK)
**Description:** Teleports home, walks forward, falls to take damage, then teleports back to repeat.
```ahk
; MCMMO Acrobatics leveling from ztancrell
`::
    Loop, 100 {
        Send t
        Sleep 100
        Send /home a{Enter}      ; Teleport to home (high place)
        Send {W down}
        Sleep 1000                ; Walk off edge
        Send {W up}
        Sleep 11750               ; Wait for fall + regen
    }
Return
```

### 107. Auto Sweep Attack (Image Detection)
**Source:** [houdini101/AHK_Minecraft_Tools](https://github.com/houdini101/AHK_Minecraft_Tools)
**Description:** Detects when attack cooldown indicator is full using ImageSearch, then attacks. Perfect 1.9+ timing.
```ahk
; Auto sweep attack with cooldown detection from houdini101
; Uses crosshair attack indicator image to detect full charge
!v::
    AutoAttack := !AutoAttack
    if (AutoAttack) {
        Loop {
            if (!AutoAttack || !WinActive("ahk_class GLFW30"))
                break
            ; Search for full attack indicator near crosshair
            ImageSearch, , , 637, 385, 644, 392, *90 *TransBlack crosshairImage
            if (ErrorLevel = 0) {
                Send {LButton}    ; Attack when indicator is full
                Sleep, 500
            }
            Sleep, 50
        }
    }
Return
```

### 108. Auto Timed Sword (Background)
**Source:** [ztancrell/MinecraftAHK](https://github.com/ztancrell/MinecraftAHK)
**Description:** Attacks at sword cooldown intervals using ControlClick, works even when alt-tabbed.
```ahk
; Background auto sword attack from ztancrell
$F6::
    toggle := !toggle
    While toggle {
        wTitle = Minecraft
        ControlClick, x-8 y-8, %wTitle%,,,, D
        Sleep, 1000                ; Sword cooldown
        ControlClick, X-8 Y-8, %wTitle%,,,, U
        Sleep, 625
    }
Return
```

### 109. Creative Mode Fast Clicker
**Source:** [ItsMeBrille/minecraft-ahk](https://github.com/ItsMeBrille/minecraft-ahk)
**Description:** Mouse side buttons for rapid left/right clicks. Designed for creative building.
```ahk
; Creative fast clicker from ItsMeBrille
SetTitleMatchMode, 2
#IfWinActive Minecraft

; XButton1 = rapid right-click (place blocks fast)
*XButton1::
    While GetKeyState("XButton1", "P") {
        MouseClick, right
        Sleep 50
    }
Return

; XButton2 = rapid left-click (break blocks fast)
*XButton2::
    While GetKeyState("XButton2", "P") {
        MouseClick, left
        Sleep 125
    }
Return
```

### 110. Right Click Spam
**Source:** [ybhaw/MinecraftAHK](https://github.com/ybhaw/MinecraftAHK)
**Description:** Holds Z to rapidly right-click. Useful for placing blocks, eating, using items.
```ahk
; Right click spam while holding Z from ybhaw
z::
    Loop {
        Click, R
        Sleep 5
        If (!GetKeyState("z","p"))
            break
    }
Return
```

### 111. Toggle Right Click Hold
**Source:** [ybhaw/MinecraftAHK](https://github.com/ybhaw/MinecraftAHK)
**Description:** F9 toggles holding the right mouse button. F10 toggles left mouse button.
```ahk
; Toggle RButton hold from ybhaw
F9::SendInput,% "{RButton " ((toggle:=!toggle) ? "Down" : "Up") "}"
; Toggle LButton hold
F10::SendInput,% "{LButton " ((toggle2:=!toggle2) ? "Down" : "Up") "}"
```

### 112. Auto Clicker with Toggle
**Source:** [ybhaw/MinecraftAHK](https://github.com/ybhaw/MinecraftAHK)
**Description:** Ctrl+Z toggles auto-clicking. Configurable speed via Sleep value.
```ahk
; Toggle autoclicker from ybhaw
#MaxThreadsPerHotkey 3
^z::
    Toggle := !Toggle
    Loop {
        If (!Toggle)
            Break
        Click
        Sleep 83              ; ~12 CPS
    }
Return
```

### 113. Nether Portal Calculator + Chat
**Source:** [houdini101/AHK_Minecraft_Tools](https://github.com/houdini101/AHK_Minecraft_Tools)
**Description:** Calculates overworld/nether portal coordinates and broadcasts result in chat.
```ahk
; Portal calculator from houdini101 (simplified)
; Press Alt+Z to calculate corresponding coordinates
!z::
    Clipboard := ""
    Send {F3 down}{c}{F3 up}
    ClipWait, 1
    ; Parse coordinates and dimension from clipboard
    if InStr(Clipboard, "overworld") {
        ; Overworld -> Nether: divide X and Z by 8
        ; Parse X, Z from clipboard
        netherX := Floor(overworldX / 8)
        netherZ := Floor(overworldZ / 8)
        msg := "Nether portal at: " . netherX . ", ~, " . netherZ
    } else {
        ; Nether -> Overworld: multiply by 8
        overworldX := netherX * 8
        overworldZ := netherZ * 8
        msg := "Overworld portal at: " . overworldX . ", ~, " . overworldZ
    }
    Send {t}
    Sleep, 100
    Send {Text}%msg%
    Send {Enter}
Return
```

### 114. Auto Chat AFK
**Source:** [AutoHotkey Forums](https://www.autohotkey.com/boards/viewtopic.php?t=27716)
**Description:** Periodically sends a chat message to prevent AFK kick on servers.
```ahk
; Auto chat to prevent AFK kick
$Home::
toggle := !toggle
if toggle {
    Loop {
        if !toggle
            break
        Send, {t}
        Sleep, 200
        SendInput, .            ; Send minimal message (just a period)
        Send, {Enter}
        Sleep, 300000            ; Wait 5 minutes
    }
}
Return
```

### 115. Shift-Tap PvP (S-Tap)
**Source:** [Vitrecan/minecraft-ahk-v2-script](https://github.com/Vitrecan/minecraft-ahk-v2-script)
**Description:** Briefly taps shift during combat for sprint reset without losing much speed.
```ahk
; Shift-tap / S-tap from Vitrecan
CapsLock & LButton:: {
    autoclick(shiftClick)
}

shiftClick() {
    Click                     ; Attack
    Send "{Shift down}"
    Send "{Shift Up}"         ; Quick shift tap to reset sprint
}

; S-tap variant
CapsLock & s:: {
    autoclick(sClick)
}

sClick() {
    Click
    Send "{s}"                ; Quick backward tap to reset sprint
}
```

### 116. Middle-Click Autoclicker
**Source:** [Scripter17/Minecraft-Hotkeys](https://github.com/Scripter17/Minecraft-Hotkeys)
**Description:** Holding middle mouse button + left/right mouse autoclicks left/right at configurable speed.
```ahk
; Middle + L/R mouse autoclicker from Scripter17
~MButton & LButton::
    while (getKeyState("LButton", "P")) {
        Click
        Sleep, %SpamInterval%   ; Configurable via GUI slider
    }
Return

~MButton & RButton::
    while (getKeyState("RButton", "P")) {
        Click, Right
        Sleep, %SpamInterval%
    }
Return
```

### 117. Mob Grinder with Slot Swapping
**Source:** [Scripter17/Minecraft-Hotkeys](https://github.com/Scripter17/Minecraft-Hotkeys)
**Description:** AFK mob grinding that cycles through weapon slots to use XP on different tools.
```ahk
; Mob grinder with tool cycling from Scripter17
; Cycles through selected hotbar slots, attacking with each
; Allows distributing XP across multiple Mending items
!G::
    while (!stopCurrent) {
        for slot in [1,2,3,4,5,6,7,8,9] {
            if (SwapSlot%slot% && slot <> weaponSlot) {
                SetKeyDelay, 50, 10
                ControlSend, , %slot%f%weaponSlot%   ; Swap with offhand
                Sleep, 1620                           ; Wait for cooldown
                ControlSend, , %slot%f%weaponSlot%   ; Swap back
            }
        }
    }
Return
```

### 118. Toggle Sprint/Crouch with GUI Indicator
**Source:** [shock59/bedrock-sprint](https://github.com/shock59/bedrock-sprint)
**Description:** Adds toggle sprint and toggle crouch with on-screen GUI showing current state.
```ahk
; Toggle sprint/crouch with GUI from shock59/bedrock-sprint
global Sprinting = "false"
global Crouching = "false"

; GUI overlay
Gui, Font, s20
Gui, Add, Text, cWhite vSprintIndicator w200,
Gui, Add, Text, cWhite vCrouchIndicator w200,
Gui, Color, 0x000000
Gui, Show, w200 h40 x10 y10
Gui, +alwaysontop -caption

; When W is pressed, automatically hold sprint/crouch key
*w::
    if (Sprinting = "true")
        Send, {Ctrl down}
    if (Crouching = "true")
        Send, {Shift down}
    Send, {w down}
    KeyWait, w
    if (Sprinting = "true")
        Send, {Ctrl up}
    if (Crouching = "true")
        Send, {Shift up}
    Send, {w up}
Return

; Toggle hotkeys
F6::
    if (Sprinting = "false") {
        Sprinting := "true"
        GuiControl,, SprintIndicator, Sprinting
    } else {
        Sprinting := "false"
        GuiControl,, SprintIndicator,
    }
Return
```

### 119. Give Item GUI (OP/Admin)
**Source:** [justinribeiro/minecraft-hackery-autohotkey](https://github.com/justinribeiro/minecraft-hackery-autohotkey)
**Description:** GUI that lets server OPs give items to players by entering item ID, quantity, and player name.
```ahk
; Give item GUI from justinribeiro (simplified)
F4::
    InputBox, itemid, Give Item, Enter item ID:
    InputBox, quantity, Give Item, Enter quantity (1-64):,,,,,,,, 64
    InputBox, player, Give Item, Enter player name:,,,,,,,, %myUsername%
    ; Send give command
    SendInput t
    SendInput /give %player% %itemid% %quantity% {Enter}
Return
```

### 120. WorldEdit Command Aliases
**Source:** [PlanetMinecraft](https://www.planetminecraft.com/mod/windows-autohotkey-command-aliases-for-minecraft/), [Minecraft Forum](https://www.minecraftforum.net/forums/mapping-and-modding-java-edition/minecraft-mods/mods-discussion/1341660-autohotkey-scripts-new-worldedit-script)
**Description:** Short aliases for common WorldEdit commands like //set, //replace, //fill.
```ahk
; WorldEdit aliases
; /set <block> - uses current selection
^1::
    Send, {t}
    Sleep, 200
    SendInput, //set stone{Enter}
Return

^2::
    Send, {t}
    Sleep, 200
    SendInput, //replace grass_block stone{Enter}
Return

^3::
    Send, {t}
    Sleep, 200
    SendInput, //copy{Enter}
Return

^4::
    Send, {t}
    Sleep, 200
    SendInput, //paste{Enter}
Return

^5::
    Send, {t}
    Sleep, 200
    SendInput, //undo{Enter}
Return
```

### 121. Piglin Trading Automation
**Source:** [AutoHotkey Forums](https://www.autohotkey.com/boards/viewtopic.php?t=98404)
**Description:** Throws gold ingots to piglins and waits for trade items. Auto-rotates to look at different piglins.
```ahk
; Piglin trading: throw gold, rotate to next piglin
$Home::
toggle := !toggle
if toggle {
    Loop {
        if !toggle
            break
        Send, {q}             ; Throw gold ingot
        Sleep, 100
        Send, {q}
        Sleep, 6000           ; Wait for piglin to examine
        ; Rotate slightly to face next piglin
        DllCall("mouse_event", "UInt", 0x01, "Int", 500, "Int", 0)
        Sleep, 100
    }
}
Return
```

### 122. Side-to-Side Movement (Mob Farm/Generator)
**Source:** [AutoHotkey Forums](https://www.autohotkey.com/boards/viewtopic.php?t=98404)
**Description:** Moves back and forth continuously. Used at cobblestone generators or mob farms to stay active.
```ahk
; Side-to-side movement for AFK
$Home::
toggle := !toggle
if toggle {
    Loop {
        if !toggle
            break
        Send, {a down}
        Sleep, 500
        Send, {a up}
        Sleep, 50
        Send, {d down}
        Sleep, 500
        Send, {d up}
        Sleep, 50
    }
}
Return
```

### 123. Pause on Lost Focus Toggle
**Source:** [ztancrell/MinecraftAHK](https://github.com/ztancrell/MinecraftAHK)
**Description:** Press F3+P to toggle "Pause on Lost Focus" so macros work when Minecraft isn't the active window.
```ahk
; Toggle pause on lost focus (needed for background macros)
$F5::
    Send, {F3 down}{p}{F3 up}
    ToolTip, Toggled Pause on Lost Focus
    SetTimer, RemoveToolTip, 2000
Return
```

### 124. Auto-Eat with Pixel Detection
**Source:** [AutoHotkey Forums](https://www.autohotkey.com/boards/viewtopic.php?t=116554)
**Description:** Monitors hunger bar pixels and automatically eats when hunger gets low.
```ahk
; Auto-eat with pixel detection
SetTimer, CheckHunger, 1000

CheckHunger:
    if (!WinActive("ahk_class GLFW30"))
        Return
    ; Check hunger bar color at specific position
    PixelGetColor, color, 1149, 920    ; Hunger bar position (adjust for resolution)
    if (color = 0x000000) {            ; Dark color = missing hunger
        ; Eat food
        Send, {2}                      ; Switch to food slot
        Sleep, 50
        Send, {RButton down}
        Sleep, 1610                    ; Eat duration
        Send, {RButton up}
        Sleep, 50
        Send, {1}                      ; Switch back to sword
    }
Return
```

### 125. Auto Health Pot (PvP Server)
**Source:** [AutoHotkey Forums](https://www.autohotkey.com/board/topic/84698-minecraft-pvp-server-automatic-healing-and-auto-protect-hit/)
**Description:** Monitors health hearts and auto-heals using soup/potions when health drops.
```ahk
; Auto heal with health pixel detection
SetTimer, CheckHealth, 500

CheckHealth:
    if (!WinActive("Minecraft"))
        Return
    PixelGetColor, heartColor, 841, 909    ; Heart bar position
    if (heartColor != 0xFF0000) {          ; Not red = damaged
        ; Heal with soup/potion
        Send, {3}                          ; Switch to healing item
        Sleep, 50
        Click, Right                       ; Use item
        Sleep, 50
        Send, {q}                          ; Drop empty bowl (for soup)
        Sleep, 50
        Send, {1}                          ; Back to weapon
    }
Return
```

### 126. Rapid Right-Click Hold
**Source:** [AutoHotkey Forums](https://www.autohotkey.com/boards/viewtopic.php?t=84184)
**Description:** Holds right-click continuously with periodic re-presses to ensure it stays active.
```ahk
; Persistent right-click hold (re-presses to prevent release)
$F6::
toggle := !toggle
if toggle {
    Loop {
        if !toggle
            break
        Send, {RButton down}
        Sleep, 1000
        Send, {RButton up}
        Sleep, 10
    }
} else {
    Send, {RButton up}
}
Return
```

### 127. Inventory Number Key Shortcuts
**Source:** [GitHub Gist](https://gist.github.com/ff4f36ccfdc08c890c882fed65a65318)
**Description:** When inventory is open, pressing 1-9 moves hovered item to/from that hotbar slot.
```ahk
; Inventory slot shortcuts: hover item + press number to move to hotbar
; This is built into Java Edition but not Bedrock
#IfWinActive Minecraft
$1::Send, {1}
$2::Send, {2}
$3::Send, {3}
; ... through 9
; Works by sending the number key which Minecraft interprets as hotbar swap
```

### 128. Head Hit Jump (Parkour)
**Source:** [AutoHotkey Forums](https://www.autohotkey.com/boards/viewtopic.php?t=43221)
**Description:** Jumps with precise timing for head-hitter parkour sections. Configurable delay via GUI slider.
```ahk
; Head-hitter jump: W + timed space from AHK Forums
$XButton1::
    Send, {w down}
    Sleep, jumpDelay          ; Configurable timing
    Send, {Space}
    Sleep, 200
    Send, {w up}
Return
```

### 129. 45-Degree Strafe Jump
**Source:** [AutoHotkey Forums](https://www.autohotkey.com/boards/viewtopic.php?t=83313)
**Description:** Sprint jump at 45-degree angle for maximum horizontal distance. Used in parkour.
```ahk
; 45-degree strafe jump
$XButton1::
    Send, {Ctrl down}        ; Sprint
    Send, {w down}
    Send, {a down}            ; Strafe 45 degrees
    Sleep, 50
    Send, {Space}             ; Jump
    Sleep, 400
    Send, {w up}
    Send, {a up}
    Send, {Ctrl up}
Return
```

### 130. Background Auto-Mine (ControlClick)
**Source:** [ztancrell/MinecraftAHK](https://github.com/ztancrell/MinecraftAHK)
**Description:** Mines using ControlClick so it works even when Minecraft isn't the focused window.
```ahk
; Background mining using ControlClick from ztancrell
; Press F4 to toggle, works even when alt-tabbed
F4:: {
    Static toggle := False
    if (toggle := !toggle) {
        SetTimer(MineLoop, 1)
        SoundBeep(1500)
    } else {
        SetTimer(MineLoop, 0)
        SoundBeep(1000)
        ; Release click
        ControlClick("x-8 y-8", "Minecraft",, "Left",, "U")
    }
}

MineLoop() {
    SetControlDelay -1
    ControlClick("x-8 y-8", "Minecraft",, "Left",, "D")
}
```

---

## Summary Statistics

- **Total macros documented:** 130 (120 new + 10 already implemented)
- **With real AHK code from repos:** ~50 macros with exact source code
- **With adapted/pseudocode AHK:** ~70 macros with clear pseudocode
- **Categories covered:** PvP Combat (15), Building (12), Movement (11), Mining/Farming (18), Inventory (7), Chat/Commands (6), Utility (12), Redstone (5), Bedwars/Skywars (6), Additional (18)

## Key GitHub Repos Referenced

| Repository | Stars | Key Features |
|---|---|---|
| [matthewlinton/MinecraftAHK](https://github.com/matthewlinton/MinecraftAHK) | - | Click repeat, hold buttons, auto-walk |
| [ztancrell/MinecraftAHK](https://github.com/ztancrell/MinecraftAHK) | - | Auto-mine (v1/v2), timed sword, acrobatics |
| [Petelax/Minecraft-Macros](https://github.com/Petelax/Minecraft-Macros) | - | Ninja bridge, breezily bridge, crop farming |
| [houdini101/AHK_Minecraft_Tools](https://github.com/houdini101/AHK_Minecraft_Tools) | - | AFK fishing (image detection), auto sweep attack, portal calculator |
| [histefanhere/XAHK](https://github.com/histefanhere/XAHK) | - | Fishing, concrete, mob grinder, cobblestone, elytra launch |
| [Scripter17/Minecraft-Hotkeys](https://github.com/Scripter17/Minecraft-Hotkeys) | - | GUI-based: fishing, mob grinding, cobblestone, concrete, elytra, autoclicker |
| [shock59/bedrock-sprint](https://github.com/shock59/bedrock-sprint) | - | Toggle sprint/crouch with GUI overlay |
| [Vitrecan/minecraft-ahk-v2-script](https://github.com/Vitrecan/minecraft-ahk-v2-script) | - | AHK v2: autoclicker, block-hit, w-tap, s-tap, shift-tap |
| [Bernkastel10/Auto-clicker-Hypixel-](https://github.com/Bernkastel10/Auto-clicker-Hypixel-) | - | Advanced GUI autoclicker with CPS control, mouse jitter |
| [ruby3141/AFKFishing](https://github.com/ruby3141/AFKFishing) | - | AFK fishing with auto-reconnect |
| [ItsMeBrille/minecraft-ahk](https://github.com/ItsMeBrille/minecraft-ahk) | - | Creative building fast clicker |
| [pzaerial/minecraft_ahk](https://github.com/pzaerial/minecraft_ahk) | - | Drop all items, mine forward, long click hold |
| [rfoxxxy/mc-binder](https://github.com/rfoxxxy/mc-binder) | - | GUI chat command binder with configurable hotkeys |
| [justinribeiro/minecraft-hackery-autohotkey](https://github.com/justinribeiro/minecraft-hackery-autohotkey) | - | Hold click, auto walk/back, crouch, give item GUI |
