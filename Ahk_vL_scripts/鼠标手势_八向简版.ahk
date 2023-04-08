;仅八向识别
#NoEnv
#SingleInstance,Force

CoordMode, Mouse, Screen

Global IsOn:=True
Global H_Open:="Open"
Global H_Close:="Close"

Menu,Tray,Icon,%A_Desktop%/Icon图集/MouseGestures_Open.ico
Menu,Tray,NoStandard
Menu,Tray,Add,%H_Close%,H_Toggle
Menu,Tray,Default,%H_Close%
Menu,Tray,Click,2
Menu,Tray,Add,&Exit,H_MenuExit

; GroupAdd,Browser,Ahk_Exe msEdge.exe
; #IfWinActive, Ahk_Group, Browser
#If IsOn
  ~Ctrl & RButton::
  Direction:=""
  MouseGetPos, BX, BY
  While GetKeyState("RButton", "P")
  {
    MouseGetPos, EX, EY
    Distance := Sqrt((EX-BX)**2+(EY-BY)**2) ;终末坐标对角线
    If (Distance>=20)
      Direction := Calculate(EX-BX, EY-BY) ;计算方向
  }

  If Direction
    Gosub,%Direction%
  Else
    Send,{RButton}
Return
#If
  ; #IfWinNotActive
;=========================================Function
Calculate(X, Y) ;参数为向量,得出轨迹
{ 	
  Result := ACos(X/Sqrt((X**2)+(Y**2)))*(45/ATan(1))
  Result := Y<0 ? Result : 360-Result	
Return, ["" , "↗" , "U", "↖" , "L" , "↙" , "D" , "↘" , "R"][Ceil((Result-22.5)/45)+1] ;范围[2-9]
}

GetToolTip(String,Time) ;显示ToolTip，参数显示的文本和显示的持续时间
{
  ToolTip,%String%
  SetTimer,RemoveToolTip,-%Time%
}
;==========================================Label
RemoveToolTip:
  ToolTip
Return

H_MenuExit:
ExitApp

H_Toggle:
  If(IsOn) ;关闭
  {
    Menu,Tray,Rename,%H_Close%,%H_Open%
    Menu,Tray,Icon,%A_Desktop%/Icon图集/MouseGestures_Close.ico
    IsOn:=False
  }Else{ ;开启
    Menu,Tray,Rename,%H_Open%,%H_Close%
    Menu,Tray,Icon,%A_Desktop%/Icon图集/MouseGestures_Open.ico
    IsOn:=True
  }
Return

↗:
  GetToolTip("最大化窗口",1000)
  WinGetTitle, WinTitle, A
  WinMaximize, %WinTitle%
return
↙:
  GetToolTip("最小化窗口",1000)
  WinGetTitle, WinTitle, A
  WinMinimize, %WinTitle%
return
↖:
  GetToolTip("复制",1000)
  Send,^c
return
↘:
  GetToolTip("粘贴",1000)
  Send,^v
return

R:
  GetToolTip("撤销",1000)
  Send,^z
return
U:
  GetToolTip("显示桌面",1000)
  WinMinimizeAll
return
L:
  GetToolTip("删除",1000)
  Send,{BS}
return
D:
  GetToolTip("换行",1000)
  Send,{Enter}
return