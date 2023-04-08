#SingleInstance,Force

Global Flag:=True

^Up::
If(Flag)
{
WinGetTitle,Title,A
WinMinimize,%Title%
Flag:=Flase
}
Else{
WinRestore,%Title%
Flag:=True
}
Return

^Down::
WinGetTitle,Title,A
WinClose,%Title%
Return