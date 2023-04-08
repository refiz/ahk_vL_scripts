#SingleInstance,Force

Global Flag:=True
Global Block
CoordMode,ToolTip,Screen

Esc & ~Ins::
If(Flag)
{
Block:=True
ToolTip,BLOCK,60,0,2
ih:=InputHook()
ih.Start()
Flag:=False
Return
}Else
{
Block:=False
GetToolTip("RESTORE",1000)`
ToolTip,,,,2
ih.Stop()
ih:=""
Flag:=True
}
Return

#If Block
LWin::
Alt::
Delete::
Home::
End::
PgUp::
PgDn::
PrintScreen::
AppsKey::
Return


GetToolTip(String,Time) ;显示ToolTip，参数为显示的文本和显示的持续时间
{
ToolTip,%String%
SetTimer,RemoveToolTip,%Time%
}
;====================Label
RemoveToolTip: ;移除ToolTip
ToolTip
Return