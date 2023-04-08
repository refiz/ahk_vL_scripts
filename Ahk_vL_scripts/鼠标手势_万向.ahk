;更多手势
#NoEnv
#SingleInstance, Force

CoordMode, Mouse, Screen

Global IsOn:=True
Global H_Open:="Open"
Global H_Close:="Close"
Global Gestures := {"None":""
  , "W" : 1, "X" : 2
  , "D" : 3, "A" : 4
  , "E" : 5, "Q" : 6
  , "Z" : 7, "C" : 8
  , "AD": 9, "DA":10
,"WX":11, "XW":12} ;存储可识别的手势

Menu,Tray,Icon,%A_Desktop%/Icon图集/MouseGestures_Open.ico
Menu,Tray,NoStandard
Menu,Tray,Add,%H_Close%,H_Toggle
Menu,Tray,Default,%H_Close%
Menu,Tray,Click,2
Menu,Tray,Add,&Exit,H_MenuExit

#If IsOn
  Ctrl & RButton::
  Direction:=LastDirection:=Gesture:=""

  MouseGetPos, BX, BY
  While GetKeyState("RButton", "P")
  {
    Sleep,10
    MouseGetPos, EX, EY
    Distance:= Sqrt((EX-BX)**2+(EY-BY)**2) ;终末坐标对角线,用于减少误差
    If (Distance >= 10) ;识别的灵敏度
      Direction:= Calculate(EX-BX, EY-BY) ;计算本次方向
    LastDirection:= Gesture?SubStr(Gesture,StrLen(Gesture),1):Direction ;记录上次增加的方向,第一次记录Direction
    If (!Gesture)
      Gesture:=Direction ;记录第一次方向
    If ((Direction!=LastDirection)&&Distance>=10) ;方向改变且超出一定距离
      Gesture.=Direction ;记录后续方向
    If (Direction!=LastDirection||Distance>=5) ;如果方向出现转折或一定超出距离则更新坐标
      BX:= EX, BY:= EY ;更新坐标
  }

  If Gestures.HasKey(Gesture)
    Gosub, %Gesture%
  Else
    Send,{RButton}
Return
#If
  ;================================Label
;===========斜向
E:
  ; GetToolTip("备忘录",1000)
  ; Run,%A_Desktop%/备忘录.txt
  GetToolTip("最大化窗口",1000)
  WinGetTitle, WinTitle, A
  WinMaximize, %WinTitle%
return
Z:
  GetToolTip("小化窗口",1000)
  WinGetTitle, WinTitle, A
  Send,#{Down}
 ;WinMinimize, %WinTitle%
return
Q:
  ; GetToolTip("BLBL",1000)
  ; Run,https://www.bilibili.com/
return
C:
  ; GetToolTip("AHK",1000)
  ; Run,https://www.autoahk.com/help/autohotkey/zh-cn/docs/settings.htm
return
QC:
Return
CQ:
Return
;===========平向
W:
  GetToolTip("显示桌面",1000)
  WinMinimizeAll
return
A:
  GetToolTip("前删",1000)
  Send,{BS}
return
D:
  GetToolTip("后删",1000)
  Send,{Delete}
return
X:
  GetToolTip("换行",1000)
  Send,{Enter}
return
AD:
  GetToolTip("剪切",1000)
  Send,^x
Return
DA:
  GetToolTip("撤销",1000)
  Send,^z
Return
WX:
  ; GetToolTip("复制",1000)
  ; Send,^c
Return
XW:
  ; GetToolTip("粘贴",1000)
  ; Send,^v
Return

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
;=============================Function
Calculate(X, Y) ;参数为向量,得出轨迹
{ 	
  Result:= ACos(X/Sqrt((X**2)+(Y**2)))*(45/ATan(1))
  Result:= Y<0 ? Result : 360-Result	
Return, ["" , "E" , "W", "Q" , "A" , "Z" , "X" , "C" , "D"][Ceil((Result-22.5)/45)+1] ;范围[2-9]
}

GetToolTip(String,Time) ;显示ToolTip，参数显示的文本和显示的持续时间
{
  ToolTip,%String%
  SetTimer,RemoveToolTip,-%Time%
}