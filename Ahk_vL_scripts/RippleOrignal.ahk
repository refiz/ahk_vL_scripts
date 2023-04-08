; by mright at  https://autohotkey.com/boards/viewtopic.php?f=6&t=8963&p=176651#p176651
; modded by Drugwash 2017.10.18 for reverse animation, variable idle timer, variable pen width
#NoEnv
#SingleInstance Force
#KeyHistory 0
ListLines Off
SetBatchLines, -1
SetKeyDelay, -1, -1
SetMouseDelay, -1
SetWinDelay, -1
SetControlDelay, -1
CoordMode Mouse, Screen
Setup()

~LButton::ShowRipple(LeftClickRippleColor)
~MButton::ShowRipple(MiddleClickRippleColor)
~RButton::ShowRipple(RightClickRippleColor,, 1)
~LControl Up::ShowRipple(MouseIdleRippleColor)

Setup()
{
    Global
    RippleWinSize := 200
    RippleStep := 10
    RippleMinSize := 10
    RippleMaxSize := RippleWinSize - 20
    RippleAlphaMax := 0x60
    RippleAlphaStep := RippleAlphaMax // ((RippleMaxSize - RippleMinSize) / RippleStep)
    RippleVisible := False
    LeftClickRippleColor := 0xff0000    ;左键点击的波纹颜色（0xff0000表示红色）
    MiddleClickRippleColor := 0xff7f00  ;中键点击的波纹颜色（0xff7f00表示橙色）
    RightClickRippleColor := 0x0000ff   ;右键点击的波纹颜色（0x0000ff表示蓝色）
    MouseIdleRippleColor := 0x008000    ;左Ctrl键弹起时的波纹颜色（0x008000表示栗色）
    MouseIdleTimer := 5000
    PenWidth := 4                       ;波纹的宽度
    Rev := 0                            ;是否反转动画（默认值 0 表示由小到大），值为 1 时由大到小
    
    DllCall("LoadLibrary", Str, "gdiplus.dll")
    VarSetCapacity(buf, 16, 0)
    NumPut(1, buf)
    DllCall("gdiplus\GdiplusStartup", UIntP, pToken, UInt, &buf, UInt, 0)
    
    Gui Ripple: -Caption +LastFound +AlwaysOnTop +ToolWindow +Owner +E0x80000
    Gui Ripple: Show, NA, RippleWin
    hRippleWin := WinExist("RippleWin")
    hRippleDC := DllCall("GetDC", UInt, 0)
    VarSetCapacity(buf, 40, 0)
    NumPut(40, buf, 0)
    NumPut(RippleWinSize, buf, 4)
    NumPut(RippleWinSize, buf, 8)
    NumPut(1, buf, 12, "ushort")
    NumPut(32, buf, 14, "ushort")
    NumPut(0, buf, 16)
    hRippleBmp := DllCall("CreateDIBSection", UInt, hRippleDC, UInt, &buf, UInt, 0, UIntP, ppvBits, UInt, 0, UInt, 0)
    DllCall("ReleaseDC", UInt, 0, UInt, hRippleDC)
    hRippleDC := DllCall("CreateCompatibleDC", UInt, 0)
    DllCall("SelectObject", UInt, hRippleDC, UInt, hRippleBmp)
    DllCall("gdiplus\GdipCreateFromHDC", UInt, hRippleDC, UIntP, pRippleGraphics)
    DllCall("gdiplus\GdipSetSmoothingMode", UInt, pRippleGraphics, Int, 4)
    
    MouseGetPos _lastX, _lastY
    SetTimer MouseIdleTimer, %MouseIdleTimer%
    Return

MouseIdleTimer:
    MouseGetPos _x, _y
    if (_x == _lastX and _y == _lastY)
        ShowRipple(MouseIdleRippleColor, _interval:=20)
    else
        _lastX := _x, _lastY := _y
    Return
}

ShowRipple(_color, _interval:=10, _rs:=0)
{
    Global
    if (RippleVisible)
    	Return
    RippleColor := _color
    RippleDiameter := _rs ? RippleMaxSize : RippleMinSize
    RippleAlpha := RippleAlphaMax
    RippleVisible := True
    Rev := _rs

    MouseGetPos _pointerX, _pointerY
    SetTimer RippleTimer, % _interval
    Return

RippleTimer:
    DllCall("gdiplus\GdipGraphicsClear", UInt, pRippleGraphics, Int, 0)
    RippleDiameter := Rev ? RippleDiameter - RippleStep : RippleDiameter + RippleStep
    if (Rev && (RippleDiameter > RippleMinSize)) OR (!Rev && (RippleDiameter < RippleMaxSize)) {
        DllCall("gdiplus\GdipCreatePen1", Int, ((RippleAlpha -= RippleAlphaStep) << 24) | RippleColor, float, PenWidth, Int, 2, UIntP, pRipplePen)
        DllCall("gdiplus\GdipDrawEllipse", UInt, pRippleGraphics, UInt, pRipplePen, float, 1, float, 1, float, RippleDiameter - 1, float, RippleDiameter - 1)
        DllCall("gdiplus\GdipDeletePen", UInt, pRipplePen)
    }
    else {
        RippleVisible := False
        SetTimer RippleTimer, Off
    }

    VarSetCapacity(buf, 8)
    NumPut(_pointerX - RippleDiameter // 2, buf, 0)
    NumPut(_pointerY - RippleDiameter // 2, buf, 4)
    DllCall("UpdateLayeredWindow", UInt, hRippleWin, UInt, 0, UInt, &buf, Int64p, (RippleDiameter + 5) | (RippleDiameter + 5) << 32, UInt, hRippleDC, Int64p, 0, UInt, 0, UIntP, 0x1FF0000, UInt, 2)
    Return
}