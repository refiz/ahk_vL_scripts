#Requires AutoHotkey v2.0
#SingleInstance Force
#Hotstring EndChars `t `n.';

TraySetIcon A_Desktop "/Icon图集/Customize.ico"

CoordMode "ToolTip", "Screen"
CoordMode "Pixel", "Screen"
CoordMode "Mouse", "Screen"

!h:: Send "{Left}"
!j:: Send "{Down}"
!k:: Send "{Up}"
!l:: Send "{Right}"
!;::
+!L:: Send "{End}"
!+;:: Send "{End};"
!+.:: Send "{End},"
+!H:: Send "{Home}"
+Enter:: Send "{Home}{Enter}{Up}"
^Enter:: Send "{End}{Enter}"
![:: Send "^[" ; vim 映射esc
!.:: ; 匿名函数
{
    Send "{Raw} => {"
    Send "{Enter}"
}
::;jq:: ; jQuery
{
    Send "$(`'`'){Left 2}"
}
::;divi::---
::;timenow::
{
    SendInput FormatTime(, "yyyy/MM/dd_HH/mm:ss/tt")
}
::;co:: ; 生成方法注释
{
    SendInput "// param: `n// ret:   `n// desc:  {Up 2}"
}
::;no:: ; 生成三种样式的 CommonJs 导入语句
{
    if GetKeyState('Space', 'P') { ; 如果空格作为结束符，使用默认名app
        Send "const app = require('');{Left 3}"
        return
    } if GetKeyState(';', 'P') {
        Send "const = require('');{Left 14}"
        if KeyWait('Space', 'D T10') { ; 跳到require内
            Send "{Right 11}"
            return
        }
    } else { ; 其他endchars
        Send "const = require('');{Left 14}"
        ih := InputHook("V T5 L10 C", "{Enter};{Tab}")
        ih.Start()
        ih.Wait()
        Send "{BS}{Space}{Right 11}" ih.Input
        Sleep 100
        Send "{End}{Enter}"
        return
    }
}

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
    SetTimer fn, -4000 ; 清除Tip
    global ColorThief := true ; 启用热键
    SetTimer CloseColorChief, -6000 ; 关闭热键
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

^b:: ; 加粗
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
*<^<!LButton::
{
    CoordMode "Mouse", "Screen"
    MouseGetPos(&px, &py)
    WinGetPos(&wx, &wy, , , 'A')
    dx := wx - px, dy := wy - py
    SetWinDelay -1
    While GetKeyState("LButton", "P")
    {
        MouseGetPos(&nx, &ny)
        WinMove(nx + dx, ny + dy, , , "A")
    }
}


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

T_Gui := ""
^!q:: ; 窗口透明度调整(GUI)
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
    MySlider.OnEvent("Change", OnSliderChange)
    ; 背景
    T_Gui.BackColor := "1D2021"
    T_Gui.Show("X200 y100")
}

OnSliderChange(MySlider, Info) {
    try
        WinSetTransparent(MySlider.Value, ThisTitle)
    catch TargetError as e
    {
        MsgBox "TargetNotFound" ; 窗口已关闭
        T_Gui.Destroy()
    }
}

!q:: ; 显隐桌面图标
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

; ================= 音量管理
^Ins:: SetVolume("Up")
^Del:: SetVolume("Down")
^PrintScreen:: SetVolume("Mute")

SetVolume(LPARAM) {
    static WM_APPCOMMAND := 0x319
    static APPCOMMAND_VOLUME_MUTE := 0x80000
    static APPCOMMAND_VOLUME_UP := 0xA0000
    static APPCOMMAND_VOLUME_DOWN := 0x90000

    switch LPARAM {
        case "Up": APPCOMMAND_VOLUME_TYPE := APPCOMMAND_VOLUME_UP
        case "Down": APPCOMMAND_VOLUME_TYPE := APPCOMMAND_VOLUME_DOWN
        case "Mute": APPCOMMAND_VOLUME_TYPE := APPCOMMAND_VOLUME_MUTE
    }
    HWorkerW := WinGetID("ahk_class WorkerW")
    DllCall("SendMessage", "UInt", HWorkerW, "UInt", WM_APPCOMMAND, "UInt", 0, "UInt", APPCOMMAND_VOLUME_TYPE)
}

; ================= 窗口操作
; ^CtrlBreak::SetWin("Max")
^PgUp:: SetWin("Min")
^PgDn:: SetWin("Close")

SetWin(MPARAM) {
    ThisTitle := WinGetTitle("A")
    try
        switch MPARAM {
            ; case "Max": WinMaximize ThisTitle
            case "Min": WinMinimize ThisTitle
            case "Close": WinClose ThisTitle
        }
    catch TargetError as e
        MsgBox e.What ": WindowNotFound"
}

; ~;:: ; 无需输入结束符便可触发
; {
;     ih := InputHook("V T5 L8 C", "{space}.;", "jq")
;     ih.Start()
;     ih.Wait()
;     switch ih.EndReason
;     {
;         case "Max":
;             MsgBox '输入 "' ih.Input '" 过长'
;         case "Timeout":
;             MsgBox '输入 "' ih.Input '" 超时'
;         case "EndKey":
;             switch ih.Input {
;             }
;         default:
;             switch ih.Input
;             {
;                 case "jq": Send "{backspace 3}$(`'`'){Left 2}"
;             }
;     }
; }