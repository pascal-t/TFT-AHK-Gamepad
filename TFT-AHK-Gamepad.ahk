; Bindings

joystickDeadzone = 3 ; range for when inputs are no longer ignored (to avoid drift)
moveSpeed := 0.3 ; mouse movementspeed, only applies to normal movement, not calousel movement
moveJoystick := 1 ; joystick to freely move the mouse around
carouselJoytick := 2 ; right Stick

ButtonLeft := 1
ButtonRight := 2

; SETUP
JoystickPrefix := 1Joy
Hotkey, %JoystickPrefix%%ButtonLeft%, ButtonLeft
Hotkey, %JoystickPrefix%%ButtonRight%, ButtonRight

SetTimer, moveMouse, 10
SetTimer, carouselMove, 10

carouselRadius := 100 ; outer radius of the carusel (how far the mouse if moved from the center)

; Store Points in Arrays, Order will be irrelevant, 
; because we will try to jump to the closest point in a direction when the DPad is pressed
; Switching Domains will however move to the first point in a Domain
; Display coordinates:
; 0,0---> x
; |
; |
; V y

HEXES := [
    { x: 100, y: 10},
    { x: 100, y: 20},
    { x: 100, y: 30},
    { x: 110, y: 10},
    { x: 110, y: 20},
    { x: 110, y: 30}
]

BENCH := [
    { x: 100, y: 50},
    { x: 100, y: 60},
    { x: 100, y: 70},
    { x: 110, y: 50},
    { x: 110, y: 60},
    { x: 110, y: 70}
]

SHOP := [
    { x: 100, y: 100},
    { x: 100, y: 110},
    { x: 100, y: 120},
    { x: 110, y: 100},
    { x: 110, y: 110},
    { x: 110, y: 120}
]

ITEMS := [
    { x: 10, y: 70},
    { x: 10, y: 80},
    { x: 10, y: 90},
    { x: 20, y: 70},
    { x: 20, y: 80},
    { x: 20, y: 90}
]

; Store the domains in an array, store the current domain, becasue there will be buttons to switch domains
currentDomain := 0;
DOMAINS := {
    HEXES, BENCH, SHOP, ITEMS
}

; direction: 1 or -1 to move left and right in the DOMAINS Array. (Clockwise, Counterclockwise)
switchDomain(direction) {
    currentDomain := Mod((currentDomain + direction), DOMAINS.Length())
    pos := DOMAINS[currentDomain][0]
    MouseMove, pos.x, pos.y
}

; axis: x or y for the axis you want to move on (up/down, left/right)
; direction: 1 or -1 for the direction you want to move (right, left)
move(axis, direction) {
    ; store current Mouse Position in currentPoint
    MouseGetPos, currentPoint.x, currentPoint.y 
    
    ; store result of our search
    closestPoint := {x: 0, y: 0}
    closestDistance := -1
    closestDomain := -1
    
    for d, domain in DOMAINS {
        
        for p, point in domain {
            
            ; check if we are moving in the right direction
            if ( (point[axis] - currentPoint[axis] * direction) > 0 ) {
                
                distanceX := Abs(point.x - currentPoint.x)
                distanceY := Abs(point.y - currentPoint.y)
                
                ; check if the point is no more than a 45 degree angle from the current position
                inCone := axis = "x" 
                    ? distanceX >= distanceY
                    : distanceY >= distanceX
                    
                if (inCone) {
                    distance := Sqrt(distanceX**2 + distanceY**2)
                    
                    if (distance < closestDistance) {
                        closestDistance := distance
                        closestPoint := point
                        closestDomain := d
                    }
                }
            }
        }
    }

    ; move the mouse if we found a point
    if (closestDistance > 0) {
        SetMouseDelay -1 ; Makes movement smoother.
        MouseMove, closestPoint.x, closestPoint.x
        currentDomain := closestDomain
    }
}
 
mouseMove:
GetKeyState, joyX, %moveJoystick%JoyX
GetKeyState, joyY, %moveJoystick%JoyY
deltaX = joyX - 50
deltaY = joyY - 50
if (Abs(deltaX) > joystickDeadzone || Abs(deltaY) > joystickDeadzone) {
    SetMouseDelay -1 ; Makes movement smoother.
    MoveMouse, deltaX * moveSpeed, deltaY * moveSpeed, 0, R
}
return
    
carouselMove:
GetKeyState, joyX, %carouselJoystick%JoyX
GetKeyState, joyY, %carouselJoystick%JoyY
deltaX = joyX - 50
deltaY = joyY - 50
if (Abs(deltaX) > joystickDeadzone || Abs(deltaY) > joystickDeadzone) {
    SetMouseDelay -1 ; Makes movement smoother.
    WinGetActiveStats, title, width, height
    mouseX = (width / 2) + carouselRadius * (deltaX / 50)
    mouseY = (height / 2) + carouselRadius * (deltaY / 50)
    MoveMouse, mouseX, mouseY
}
return

; From https://www.autohotkey.com/docs/scripts/JoystickMouse.htm 
ButtonLeft:
SetMouseDelay, -1 ; Makes movement smoother.
MouseClick, left,,, 1, 0, D ; Hold down the left mouse button.
SetTimer, WaitForLeftButtonUp, 10
return

ButtonRight:
SetMouseDelay, -1 ; Makes movement smoother.
MouseClick, right,,, 1, 0, D ; Hold down the right mouse button.
SetTimer, WaitForRightButtonUp, 10
return

WaitForLeftButtonUp:
if GetKeyState(JoystickPrefix . ButtonLeft)
    return ; The button is still, down, so keep waiting.
; Otherwise, the button has been released.
SetTimer, WaitForLeftButtonUp, Off
SetMouseDelay, -1 ; Makes movement smoother.
MouseClick, left,,, 1, 0, U ; Release the mouse button.
return

WaitForRightButtonUp:
if GetKeyState(JoystickPrefix . ButtonRight)
    return ; The button is still, down, so keep waiting.
; Otherwise, the button has been released.
SetTimer, WaitForRightButtonUp, Off
MouseClick, right,,, 1, 0, U ; Release the mouse button.
return
