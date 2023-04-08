#SingleInstance,Force

CoordMode,ToolTip,Screen ;坐标相对屏幕

Global Flag:=True
;==============HotKey
^`::
WinSet,AlwaysOnTop,Toggle,A
If(Flag)
{
	GetToolTip("已设为总在最前喵~",1500)
	Flag:=False
}
Else{
	GetToolTip("已取消总在最前喵~",1500)
	Flag:=True
}
Return
;==============Function
GetToolTip(String,Time) ;显示ToolTip，参数显示的文本和显示的持续时间
{
	ToolTip,%String%
	SetTimer,RemoveToolTip,%Time%
}
;==============Label
RemoveToolTip: ;移除ToolTip
ToolTip
Return