#SingleInstance,Force

~CapsLock::
State:=GetKeyState("CapsLock","T")
While State
{
State:=GetKeyState("CapsLock","T")
If State
{
MouseGetPos,PosX,PosY
ToolTiP,大,% PosX+10,PosY+20,3
}
Else {
ToolTip,,,,3
Return
}
}
Return