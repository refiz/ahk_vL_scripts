#NoEnv
#SingleInstance,Force
Global IsCopy:=True

MButton &  WheelDown::
Send,^c
Return

MButton & WheelUp::
If(IsCopy)
{
Send,^v
IsCopy:=Flase
}
Sleep,600
If(!GetKeyState("MButton"))
{
IsCopy:=True
}
Return