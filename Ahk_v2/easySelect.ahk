#Requires AutoHotkey v2.0
#SingleInstance Force

CoordMode "ToolTip", "Window"
TraySetIcon A_Desktop "/Icon图集/Notepad.ico"

!h::Left
!j::Down
!k::Up
!l::Right
+Enter::Send "{Home}{Enter}{Up}"
^Enter::Send "{End}{Enter}"

flag := false

*![:: f(1)
*!]::
f(hk)
{
    global flag := !flag
    if flag {
        if hk = 1
            Send "{Home}{Shift Down}{End}"
        else
            Send "{Shift Down}"
        Sleep(50)
        if CaretGetPos(&x, &y)
            ToolTip("★", x, y)
        else
            ToolTip("☆")
    }
    else {
        ToolTip()
        Send "{Shift Up}"
    }
}
;Send "{Left}"
#HotIf flag
*h:: fu("{Left}")
*j:: fu("{Down}")
*k:: fu("{Up}")
*l:: fu("{Right}")
#HotIf

fu(arrow) {
    Send arrow
    Sleep(50)
    if CaretGetPos(&x, &y) {
        ToolTip("★", x, y)
    }
}

; class Rect extends GUi {
;     __New() {
;         super.__New("-Caption +Border +AlwaysOnTop",,this)
;         this.AddPicture("xm w10 h10",A_Desktop "/tempPic/sprite-0001.png")
;     }
; }
