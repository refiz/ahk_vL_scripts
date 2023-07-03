#Requires AutoHotkey v2.0
#SingleInstance Force

SetKeyDelay 0
CoordMode "ToolTip", "Window"

states := { close: false, normal: 'N', insert: 'I', visual: 'V', replace: 'R' }
state := states.close
flag := false

!h::Left
!j::Down
!k::Up
!l::Right
+Enter:: Send "{Home}{Enter}{Up}"
^Enter:: Send "{End}{Enter}"

*![::
{
    global flag := !flag
    if flag {
        Open()
    }
    else {
        CLose()
    }
}

#HotIf flag and state !='I'
*Tab:: Send "^z"
#HotIf

#HotIf flag and state = 'N'
*h:: Nor("{Left}")
*j:: Nor("{Down}")
*k:: Nor("{Up}")
*l:: Nor("{Right}")
*x:: Nor("{Del}")
*+g::
{
    Send "{PgDn}"
    Sleep(50)
    UpdateTip()
}
*g:: ;dobule g
{
    KeyWait("g")
    if KeyWait("g", "D T0.3")
    {
        Send "{PgUp}"
        Sleep(50)
        UpdateTip()
    }
}
;===============switch mode
*r::
{
    KeyWait("r")
    Send "{Ins}" ;maybe work
    global state := 'R'
    UpdateTip()
    SetTimer UpdateTip, 1000
}
*Esc:: CLose()
#HotIf

#HotIf flag and state != 'R' and state != 'I'
*a:: Ins("{Right}")
*i:: Ins("{Left}")
*o:: Ins("{End}{Enter}")
*+A:: Ins("{End}")
*+I:: Ins("{Home}")
*+O:: Ins("{Home}{Enter}{Up}")

*d::
{
    KeyWait("d")
    if KeyWait("d", "D T0.3")
        Send "{Home}{Shift Down}{End}{Del}{Shift Up}"
    UpdateTip()
}
*h:: Vis("{Left}")
*j:: Vis("{Down}")
*k:: Vis("{Up}")
*l:: Vis("{Right}")
*v:: Vis('')
*+v:: Vis("{Home}{Shift Down}{End}")
*^v:: Vis("{Shift Up}^{Left}^+{Right}")
*Esc::
{
    global state := 'N'
    Send "{Shift Up}"
    UpdateTip()
}
#HotIf

#HotIf flag and state = 'R'
*Esc::
{
    Send "{Ins}"
    SetTimer UpdateTip, 0
    global state := 'N'
    UpdateTip()
}
#HotIf
#HotIf flag and state ='I'
*Esc::
{
    global state := 'N'
    Send "{Shift Up}"
    UpdateTip()
}
#HotIf

Open() {
    global state := 'N'
    UpdateTip()
}

CLose() {
    global flag := false
    global state := states.close
    ToolTip()
    Send "{Shift Up}"
    SetTimer UpdateTip, 0
}

Ins(hk)
{
    global state := 'I'
    Send "{Shift Up}"
    Send hk
    UpdateTip()
}

Nor(hk) {
    global state := 'N'
    Send hk
    Sleep(50)
    UpdateTip()
}

Vis(hk) {
    global state := 'V'
    Send "{Shift Down}"
    Send hk
    Sleep(50)
    UpdateTip()
}

UpdateTip() {
    global
    ToolTip()
    if CaretGetPos(&x, &y) {
        ToolTip(state, x, y)
    } else
        ToolTip(state)
}