RemoveRepeadChar(String) ;去除字符串中连续重复的字符
{
    NewString:=""
    LastField:=SubStr(String,1,1)
    Loop,Parse,String
    {
        If(InStr(NewString,A_LoopField)) 
        {
            If (A_LoopField=LastField)
                Continue
            Else NewString.=A_LoopField
            }
        Else {
            NewString.=A_LoopField
        }
        LastField:=A_LoopField
    }
    Return,NewString
}
;=========================
PopUpStr(String,PosX,PosY,Weight,Speed:=0)
{
    ClipLenth:=2
    Loop,% StrLen(StrReplace(String, A_Space, ""))
    {
        SplitStr:=SubStr(String,1,ClipLenth)
        ToolTip,%SplitStr%,%PosX%,%PosY%,%Weight%
        ClipLenth+=1
        Sleep,60
    }
    Sleep,% StrLen(String)*Speed
Return
}
;========================
GetToolTip(String,Time) ;显示ToolTip，参数显示的文本和显示的持续时间
{
  ToolTip,%String%
  SetTimer,RemoveToolTip,-%Time% ;自备Label
}
;=======================更换图标
Global IsOn:=True
Global M_Open:="Open"
Global M_Close:="Close"
;====
Menu,Tray,Icon,%A_Desktop%/Icon图集/MidMenu_Open.ico
Menu,Tray,NoStandard
Menu,Tray,Add,%M_Close%,M_Toggle
Menu,Tray,Default,%M_Close%
Menu,Tray,Click,2
Menu,Tray,Add,&Exit,M_MenuExit
;====
M_Toggle:
    If(IsOn) ;关闭
    {
        Menu,Tray,Rename,%M_Close%,%M_Open%
        Menu,Tray,Icon,%A_Desktop%/Icon图集/MidMenu_Close.ico
        IsOn:=False
    }Else{ ;开启
        Menu,Tray,Rename,%M_Open%,%M_Close%
        Menu,Tray,Icon,%A_Desktop%/Icon图集/MidMenu_Open.ico
        IsOn:=True
    }
Return
;===
M_MenuExit:
ExitApp
;========================显隐桌面图标
HideOrShowDesktopIcons()
{
	ControlGet, class, Hwnd,, SysListView321, ahk_class Progman
	If (class ="")
		ControlGet, class, Hwnd,, SysListView321, ahk_class WorkerW
	If DllCall("IsWindowVisible", UInt,class)
		WinHide, ahk_id %class%
	Else
		WinShow, ahk_id %class%
}
