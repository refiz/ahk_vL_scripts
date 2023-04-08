#Persistent
#SingleInstance,Force

Global MouseState:=Move

SetTimer,IsIdle,10
SetTimer,GetNowPos,10
;=======Label
IsIdle:
MouseGetPos,NowPosX,NowPosY
If(PriorPosX=NowPosX And PriorPosY=NowPosY)
MouseState:="Idle"
Else
MouseState:="Move"
ToolTip,%MouseState%
Return

GetNowPos:
MouseGetPos,PriorPosX,PriorPosY
Return