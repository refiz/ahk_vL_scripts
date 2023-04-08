; ahkVersion@1.1.34.03
; @daohe
#NoEnv
#SingleInstance, Force

SetBatchLines, -1 ;可选，更丝滑
CoordMode, Mouse, Screen
CoordMode, ToolTip, Screen

;所需要的坐标变量
Global Begin_x
Global Begin_y
Global End_x
Global End_y
Global Scope_x := 0 ;赋初始值，用于判断
Global Scope_y := 0
;
Global IsRange := False

^RButton::
    IsRange := False
Return

^LButton::
    IsRange := True
    Gui,Destroy
    Sleep,10
    MouseGetPos, Begin_x, Begin_y
    while IsRange
    {
        MouseGetPos, End_x, End_y
        Scope_x:=Abs(Begin_x-End_x)
        Scope_y:=Abs(Begin_y-End_y)

        ToolTip, % Begin_x ", " Begin_y "`n" End_x "," End_y "`n" Scope_x " x " Scope_y 
        Sleep, 10

        If (Begin_x == End_x){
            Continue
        }
        ;计算gui坐标
        x:= End_x<Begin_x?End_x:Begin_x
        y:= End_y<Begin_y?End_y:Begin_y

        Gui,Color,00C5CD ;自定义gui颜色
        Gui,+AlwaysOnTop +Border -Caption ;窗口样式调整
        Gui, Show, X%x% Y%y% W%Scope_x% H%Scope_y%,Rect ;设定窗口坐标、宽度及标题
        WinSet,Transparent,120,Rect ;调整gui透明度

    }
    ToolTip
return

^PrintScreen::
    ;前提是有选区操作
    If (!Scope_x && !Scope_y){
        Return
    }
    Gui,Destroy
    Send,#+s
    Sleep,1000
    MouseMove,Begin_x,Begin_y,5
    Send,{Click Down}
    MouseMove,End_x,End_y,5
    Send,{Click Up}
    Sleep,200
    Send,{Enter}
Return