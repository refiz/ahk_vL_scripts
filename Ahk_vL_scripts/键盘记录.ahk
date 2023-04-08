#NoEnv
#SingleInstance,Force

Global InputString ;保存InputHook记录的输入
Global Flag

^Up:: ;开始记录
GetToolTip("Start",2000)
ih:=InputHook("C M V E")
ih.Start()
Flag:=True
Return

^Down:: ;结束记录
If(Flag)
{
GetToolTip("Over",2000)
InputString:=ih.Input
in.Stop()
Flag:=False
}
Return

#Enter:: ;播放记录
Send,%InputString%
ih:=""
Return

#Esc::
GetToolTip("KbRecorder_Exit",2000)
Sleep,2000
ExitApp
Return
;====================Func
GetToolTip(String,Time) ;显示ToolTip，参数为显示的文本和显示的持续时间
{
ToolTip,%String%
SetTimer,RemoveToolTip,%Time%
}
;====================Label
RemoveToolTip: ;移除ToolTip
ToolTip
Return
