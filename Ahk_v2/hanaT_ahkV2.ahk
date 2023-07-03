#Requires AutoHotkey v2.0
#SingleInstance Force
#Hotstring EndChars `t `n.'

TraySetIcon A_Desktop "/Icon图集/Customize.ico"

CoordMode "ToolTip", "Screen"
CoordMode "Pixel", "Screen"
CoordMode "Mouse", "Screen"

; 获取窗口信息
+Pause::
{
    CoordMode "Mouse", "Window"
    MouseGetPos &PosX, &PosY
    CoordMode "Mouse", "Screen"
    MouseGetPos &xpos, &ypos
    global ThisColor := PixelGetColor(xpos, ypos, "Slow")
    ToolTip "S:" xpos A_Space ypos "`nW: " PosX A_Space PosY "`n" ThisColor "`nC:" WinGetClass("A") "`nT:" WinGetTitle("A") "`nI:" WinGetID("A"), xpos, ypos, 1
    fn := RemoveToolTip.Bind(1)
    ; 清除Tip
    SetTimer fn, -4000
    ; 启用热键
    global ColorThief := true
    ; 关闭热键
    SetTimer CloseColorChief, -6000
}

CloseColorChief()
{
    global ColorThief := false
}
RemoveToolTip(Wieght)
{
    ToolTip , , , Wieght
}

ColorThief := false
#HotIf ColorThief = true
; 颜色神偷
+BS::
{
    global
    If A_TimeSincePriorHotkey > 6000
        ThisColor := ""
    If ThisColor
    {
        A_ClipBoard := SubStr(ThisColor, -6)
        ToolTip "颜色已偷", , , 1
        fn := RemoveToolTip.Bind(1)
        SetTimer fn, -2000
        ThisColor := ""
    }
    ColorThief := false
}
#HotIf

; markdown 及其他快捷键
; 加粗
^b::
{
    A_Clipboard := ""
    Send "^c"
    if A_Clipboard = ""
        return
    else
    {
        A_Clipboard := "**" A_Clipboard "**"
        Send "^v"
        A_Clipboard := ""
    }
}

; jQuery
::xjq::
{
    Send "{Raw}$(`"  `")"
    Send "{Left}{Left}{Left}"
}

::xlink::Send "[](){Left}{Left}{Left}"

::ximage::
{
    Send "{Raw}![]()"
    Send "{Left}{Left}{Left}"
}

::xdivi::Send "---"

; ================= 窗口操作
^PgUp::
{
    ThisTitle := WinGetTitle("A")
    try
        WinMinimize ThisTitle
    catch TargetError as e
        MsgBox e.What ": WindowNotFound"
}
^PgDn::
{
    ThisTitle := WinGetTitle("A")
    try
        WinClose ThisTitle
    catch TargetError as e
        MsgBox e.What ": windowNotFound"
}

^;:: Send "{Right}"

::xTimeNow::
{
    CurrentDateTime := FormatTime(, "YYYY/MM/dd_HH:mm:ss_tt")
    SendInput CurrentDateTime
}

F1::SoundSetVolume "+2"
!F1::SoundSetVolume "-2"


XButton2:: Send "^c"
XButton1:: Send "^v"
^XButton2:: Send "{Volume_Up}"
^XButton1:: Send "{Volume_Down}"
<!XButton1::AltTabMenu
#XButton2:: Send "^1{PgDn}"
#Xbutton1::
{
    try {
        if ImageSearch(&W_X, &W_Y, A_ScreenWidth / 4, 0, A_ScreenWidth, A_ScreenHeight / 4, "*50" A_Desktop "/脚本搜索图/CloudMusicLikeBtn,jpg")
            BlockInput("MouseMove")
        MouseGetPos &PosX, &PosY
        Sleep(10)
        MouseClick "Left", W_x + 10, W_Y + 10
        BlockInput "MouseMoveOff"
    }
    catch ValueError as e
        MsgBox e.Message ": image nonexistence or not found"
}

; ; 轻松拖拽窗口
; *<^<!LButton::
; {
;     CoordMode "Mouse", "Screen"
;     MouseGetPos &MouseStartX, &MouseStartY, &MouseWin
;     WinGetPos &OriginalPosX, &OriginalPosY, , , "ahk_id" MouseWin
;     MinMax := WinGetMinMax(MouseWin)
;     ThisTitle := WinGetTitle("A")
;     ; 双击切换窗口最大最小化状态
;     if A_ThisHotkey = A_PriorHotkey and A_TimeSincePriorHotkey < 200
;     {
;         State := WinGetMinMax(ThisTitle)
;         if State = 1
;             Send "#{Down}"
;         else
;             WinMaximize(ThisTitle)
;     }
;     ; 轻松拖拽
;     if MinMax = 0 and ThisTitle
;     {
;         fn := WatchMouse.Bind(MouseStartX, MouseStartY, MouseWin, originalPosX, OriginalPosY)
;         SetTimer(fn, 100)

;     }
; }

; WatchMouse(MouseStartX, MouseStartY, MouseWin, OriginalPosX, OriginalPosY)
; {
    
;     fn := WatchMouse.Bind(MouseStartX, MouseStartY, MouseWin, originalPosX, OriginalPosY)
;     if !GetKeyState("LButton", "P")
;     {
;         SetTimer fn,0
;     }
;     CoordMode "Mouse", "Window"
;     MouseGetPos &MouseX, &MouseY
;     WinGetPos &WinX, &WinY, , , "ahk_id" MouseWin
;     WinMove WinX + MouseX - MouseStartX, WinY + MouseY - MouseStartY, , , "ahk_id" MouseWin
;     MouseStartX := MouseX
;     MouseStartY := MouseY
; }

; 窗口置顶
!`::
{
    ThisTitle := WinGetTitle("A")
    try
        WinSetAlwaysOnTop(-1, ThisTitle)
    catch TargetError as e
        MsgBox e.What ": can't get window"
    catch OSError as e
        MsgBox e.Wait ": can't apply"
    else
    {
        ToolTip SubStr(ThisTitle, 0, 12) "已更新喵~", , , 1
        fn := RemoveToolTip.Bind(1)
        SetTimer fn, -1500
    }
}

; 窗口透明度调整
T_Gui := ""
^!q::
{
    global
    ThisTitle := SubStr(WinGetTitle("A"), 1, 30)
    if T_Gui != ""
    {
        T_Gui.Destroy()
        T_Gui := ""
        return
    }
    global T_Gui := Gui("+AlwaysOnTop +Border -Caption")
    MySlider := T_Gui.Add("Slider", "ToolTip Range0-255 AltSubmit ", 255)
    TitleInfo := T_Gui.Add("Text", "w120 r3.5", ThisTitle)
    ; 字体样式
    TitleInfo.SetFont("cffcba8 s12", "新宋体")
    MySlider.OnEvent("Change", Ctrl_Change)
    ; 背景
    T_Gui.BackColor := "1D2021"
    T_Gui.Show("X200 y100")
}

Ctrl_Change(MySlider, Info) {
    try
        WinSetTransparent(MySlider.Value, ThisTitle)
    catch TargetError as e
    {
        ; 窗口已关闭
        MsgBox "TargetNotFound"
        T_Gui.Destroy()
    }
}

; 显隐桌面
!q::
{
    ; 获取FolderView的id
    HWorkerW := WinGetID("ahk_class WorkerW")
    HDefView := DllCall("FindWindowEx", "UInt", HWorkerW, "UInt", 0, "Str", "SHELLDLL_DefView", "UInt", 0)
    HListView := DllCall("FindWindowEx", "UInt", HDefView, "UInt", 0, "Str", "SysListView32", "UInt", 0)
    ; 检查显隐状态
    if DllCall("IsWindowVisible", "UInt", HListView) {
        DllCall("ShowWindow", "UInt", HListView, "UInt", 0)
    }
    else {
        DllCall("ShowWindow", "UInt", HListView, "UInt", 5)
    }
}